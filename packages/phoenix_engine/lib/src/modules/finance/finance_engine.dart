import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Manages club finances — salaries, ticket revenue, sponsors, FFP.
class FinanceEngine {
  FinanceEngine({
    required WorldRegistry registry,
    required FinanceConfig config,
    required StaffConfig staffConfig,
    required EventBus eventBus,
  })  : _registry = registry,
        _config = config,
        _staffConfig = staffConfig,
        _eventBus = eventBus;

  final WorldRegistry _registry;
  final FinanceConfig _config;
  final StaffConfig _staffConfig;
  final EventBus _eventBus;

  void initializeFromClubs() {
    for (final club in _registry.clubs.values) {
      final wages = _monthlyWages(club.id);
      _registry.clubFinances[club.id] = ClubFinance.fromClub(
        club,
        monthlyWages: wages,
      );
    }
  }

  int runDaily(GameDate date) {
    var transactions = 0;
    for (final club in _registry.clubs.values) {
      var finance = _registry.clubFinances[club.id];
      if (finance == null) {
        continue;
      }

      // Daily sponsor income
      finance = finance.copyWith(
        balance: finance.balance + _config.dailySponsorIncome,
        seasonRevenue: finance.seasonRevenue + _config.dailySponsorIncome,
      );
      transactions += 1;

      // Monthly salary payment
      if (date.day == _config.salaryPaymentDay) {
        finance = finance.copyWith(
          balance: finance.balance - finance.monthlyWages,
          seasonExpenses: finance.seasonExpenses + finance.monthlyWages,
          seasonWageExpenses: finance.seasonWageExpenses + finance.monthlyWages,
        );
        _eventBus.publish(
          SalariesPaidEvent(clubId: club.id, amount: finance.monthlyWages, date: date),
        );
        transactions += 1;
      }

      _registry.clubFinances[club.id] = finance;
      _syncClubBudget(club.id, finance.balance);
    }
    return transactions;
  }

  void recordMatchDayRevenue({
    required ClubId homeClubId,
    required Club homeClub,
    required GameDate date,
  }) {
    final finance = _registry.clubFinances[homeClubId];
    if (finance == null) {
      return;
    }

    final attendance =
        (homeClub.stadiumCapacity * _config.attendanceRate).round();
    final revenue = attendance * _config.ticketPricePerSeat;

    final updated = finance.copyWith(
      balance: finance.balance + revenue,
      seasonRevenue: finance.seasonRevenue + revenue,
      seasonTicketRevenue: finance.seasonTicketRevenue + revenue,
    );
    _registry.clubFinances[homeClubId] = updated;
    _syncClubBudget(homeClubId, updated.balance);

    _eventBus.publish(
      TicketRevenueEvent(
        clubId: homeClubId,
        amount: revenue,
        attendance: attendance,
        date: date,
      ),
    );
  }

  void applyTransferFee({
    required ClubId buyerId,
    required ClubId sellerId,
    required int fee,
  }) {
    if (fee <= 0) {
      return;
    }

    final buyerFinance = _registry.clubFinances[buyerId];
    final sellerFinance = _registry.clubFinances[sellerId];
    if (buyerFinance == null || sellerFinance == null) {
      return;
    }

    _registry.clubFinances[buyerId] = buyerFinance.copyWith(
      balance: buyerFinance.balance - fee,
      seasonExpenses: buyerFinance.seasonExpenses + fee,
    );
    _registry.clubFinances[sellerId] = sellerFinance.copyWith(
      balance: sellerFinance.balance + fee,
      seasonRevenue: sellerFinance.seasonRevenue + fee,
    );
    _syncClubBudget(buyerId, _registry.clubFinances[buyerId]!.balance);
    _syncClubBudget(sellerId, _registry.clubFinances[sellerId]!.balance);
  }

  bool isFfpBreaching(ClubId clubId) {
    final finance = _registry.clubFinances[clubId];
    if (finance == null) {
      return false;
    }
    return finance.wageToRevenueRatio > _config.ffpWageRatioLimit;
  }

  void refreshMonthlyWages(ClubId clubId) {
    final finance = _registry.clubFinances[clubId];
    if (finance == null) {
      return;
    }
    final wages = _monthlyWages(clubId);
    _registry.clubFinances[clubId] = finance.copyWith(monthlyWages: wages);
  }

  /// Melhora centro de treinos ou academia. Devolve mensagem de erro ou `null`.
  String? tryUpgradeFacility({
    required ClubId clubId,
    required FacilityKind kind,
    required GameDate date,
  }) {
    final finance = _registry.clubFinances[clubId];
    if (finance == null) {
      return 'Dados financeiros indisponíveis';
    }

    final current = finance.levelFor(kind);
    if (current >= ClubFinance.maxFacilityLevel) {
      return 'Já estás no nível máximo';
    }

    final cost = ClubFinance.upgradeCost(current);
    if (finance.balance < cost) {
      return 'Saldo insuficiente';
    }

    final nextLevel = current + 1;
    final updated = switch (kind) {
      FacilityKind.training => finance.copyWith(
          balance: finance.balance - cost,
          seasonExpenses: finance.seasonExpenses + cost,
          trainingLevel: nextLevel,
        ),
      FacilityKind.academy => finance.copyWith(
          balance: finance.balance - cost,
          seasonExpenses: finance.seasonExpenses + cost,
          academyLevel: nextLevel,
        ),
    };

    _registry.clubFinances[clubId] = updated;
    _syncClubBudget(clubId, updated.balance);
    _eventBus.publish(
      FacilityUpgradedEvent(
        clubId: clubId,
        kind: kind,
        newLevel: nextLevel,
        cost: cost,
        date: date,
      ),
    );
    return null;
  }

  int _monthlyWages(ClubId clubId) {
    final playerWages = _registry.squadQuery
        .getByClubId(clubId)
        .fold<int>(0, (sum, p) => sum + p.salary);
    final staffWages = _registry.staffQuery
        .getByClubId(clubId)
        .fold<int>(0, (sum, s) => sum + s.salary);
    final club = _registry.getClub(clubId);
    final coachWage = club?.coachId != null
        ? (_registry.getCoach(club!.coachId!)?.reputation ?? 0) *
            _staffConfig.coachWagePerReputation
        : 0;
    return playerWages + staffWages + coachWage;
  }

  void _syncClubBudget(ClubId clubId, int balance) {
    final club = _registry.getClub(clubId);
    if (club != null) {
      _registry.clubs[clubId] = club.copyWith(budget: balance);
    }
  }
}
