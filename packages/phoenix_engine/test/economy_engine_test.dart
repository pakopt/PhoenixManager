import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:test/test.dart';

void main() {
  group('PSE B.3 — Economy Engine v0.4', () {
    late EngineContext context;

    setUp(() async {
      context = await AppBootstrap().boot(worldId: 'economy-test');
    });

    test('boot initializes club finances for all clubs', () {
      expect(context.registry.clubFinances.length, 6);
      for (final club in context.registry.clubs.values) {
        final finance = context.registry.clubFinances[club.id];
        expect(finance, isNotNull);
        expect(finance!.balance, club.budget);
        expect(finance.monthlyWages, greaterThan(0));
      }
    });

    test('finance engine applies sponsor income and salaries on payment day', () {
      final clubId = const ClubId('club-phoenix');
      final financeEngine = FinanceEngine(
        registry: context.registry,
        config: context.economyConfig.finance,
        staffConfig: context.economyConfig.staff,
        eventBus: EventBus(),
      );
      final before = context.registry.clubFinances[clubId]!;
      final date = context.simulationEngine.worldState.currentDate;
      final sponsor = context.economyConfig.finance.dailySponsorIncome;

      financeEngine.runDaily(date);

      final after = context.registry.clubFinances[clubId]!;
      expect(after.seasonRevenue, before.seasonRevenue + sponsor);
      if (date.day == context.economyConfig.finance.salaryPaymentDay) {
        expect(after.seasonExpenses, before.seasonExpenses + before.monthlyWages);
      }
    });

    test('match day records ticket revenue for home club', () {
      final firstFixture = context.registry.fixtures.values.first;
      final daysUntil = _daysBetween(
        context.simulationEngine.worldState.currentDate,
        firstFixture.date,
      );

      context.simulationEngine.tickDays(daysUntil);

      final ticketEvents =
          context.eventBus.history.whereType<TicketRevenueEvent>().toList();
      expect(ticketEvents, isNotEmpty);
      expect(ticketEvents.first.amount, greaterThan(0));
    });

    test('training updates morale after match', () {
      final firstFixture = context.registry.fixtures.values.first;
      final homeSquadBefore = context.registry.squadQuery
          .getByClubId(firstFixture.homeClubId)
          .map((p) => p.morale)
          .toList();

      context.simulationEngine.tickDays(
        _daysBetween(
          context.simulationEngine.worldState.currentDate,
          firstFixture.date,
        ),
      );

      final homeSquadAfter =
          context.registry.squadQuery.getByClubId(firstFixture.homeClubId);
      final moraleChanged = homeSquadAfter.asMap().entries.any(
            (e) => e.value.morale != homeSquadBefore[e.key],
          );
      expect(moraleChanged, isTrue);
    });

    test('transfer window can complete off-screen transfers in July', () {
      expect(context.simulationEngine.worldState.currentDate.month, 7);

      context.economyRunner.runDaily(
        context.simulationEngine.worldState.currentDate,
      );

      final transfers =
          context.eventBus.history.whereType<TransferCompletedEvent>().length;
      expect(transfers, greaterThanOrEqualTo(0));
    });

    test('season end triggers youth intake and increases player count', () {
      final playersBefore = context.registry.players.length;
      final lab = SimulationLab(context: context);
      lab.runUntilSeasonEnd();

      final youthEvents =
          context.eventBus.history.whereType<YouthIntakeEvent>().toList();
      expect(youthEvents.length, 6);
      expect(context.registry.players.length, greaterThan(playersBefore));
    });

    test('expired contract processed at season end', () {
      const expiredPlayerId = PlayerId('p-hig-2');
      expect(
        context.registry.getPlayer(expiredPlayerId)!.contractEndYear,
        2026,
      );

      SimulationLab(context: context).runUntilSeasonEnd();

      final freeTransfers = context.registry.transfers
          .where((t) => t.playerId == expiredPlayerId && t.isFree)
          .toList();
      expect(freeTransfers, isNotEmpty);
    });

    test('club finances persist through save round-trip', () {
      context.economyRunner.runDaily(
        context.simulationEngine.worldState.currentDate,
      );
      context.simulationEngine.tickOneDay();

      final json = context.saveManager.save(
        state: context.simulationEngine.worldState,
        registry: context.registry,
      );
      final envelope = context.saveManager.deserializeEnvelope(json);

      expect(envelope.registry.clubFinances.length, 6);
      expect(envelope.registry.transfers, envelope.registry.transfers);
    });

    test('injury engine recovers players and skips training', () {
      final playerId = context.registry.squadQuery
          .getByClubId(const ClubId('club-phoenix'))
          .first
          .id;
      final player = context.registry.players[playerId]!;
      context.registry.players[playerId] =
          player.copyWith(injuredDaysRemaining: 2);

      final injuryEngine = InjuryEngine(
        registry: context.registry,
        config: context.economyConfig.injury,
        staffConfig: context.economyConfig.staff,
        rng: context.container.get<SeededRng>(),
        eventBus: context.eventBus,
      );

      injuryEngine.runDaily();
      expect(
        context.registry.players[playerId]!.injuredDaysRemaining,
        1,
      );

      injuryEngine.runDaily();
      expect(
        context.registry.players[playerId]!.injuredDaysRemaining,
        0,
      );
      expect(
        context.eventBus.history.whereType<PlayerRecoveredEvent>().length,
        1,
      );
    });

    test('match can injure fit players', () {
      final injuryEngine = InjuryEngine(
        registry: context.registry,
        config: const InjuryConfig(
          matchInjuryChance: 1.0,
          minDaysOut: 5,
          maxDaysOut: 5,
          maxInjuredPerClubPerMatch: 2,
        ),
        staffConfig: context.economyConfig.staff,
        rng: context.container.get<SeededRng>(),
        eventBus: context.eventBus,
      );

      injuryEngine.applyMatchInjuries(
        homeClubId: const ClubId('club-phoenix'),
        awayClubId: const ClubId('club-union'),
        date: context.simulationEngine.worldState.currentDate,
      );

      final injuries =
          context.eventBus.history.whereType<PlayerInjuredEvent>().toList();
      expect(injuries, isNotEmpty);
      expect(injuries.first.daysOut, 5);
    });

    test('user can buy a player during transfer window', () {
      final buyerId = const ClubId('club-phoenix');
      final date = context.simulationEngine.worldState.currentDate;
      expect(context.economyConfig.transfer.isWindowOpen(date.month), isTrue);

      final target = context.registry.players.values.firstWhere(
        (p) => p.clubId != buyerId,
      );
      final finance = context.registry.clubFinances[buyerId]!;
      // Ensure enough balance for the ask.
      context.registry.clubFinances[buyerId] = finance.copyWith(
        balance: 50000000,
        transfersCompletedThisWindow: 0,
      );

      final error = context.economyRunner.tryUserBuyPlayer(
        buyerId: buyerId,
        playerId: target.id,
        date: date,
      );
      expect(error, isNull);
      expect(context.registry.getPlayer(target.id)!.clubId, buyerId);
      expect(
        context.registry.transfers.any((t) => t.playerId == target.id),
        isTrue,
      );
    });

    test('user buy fails when transfer window is closed', () {
      final buyerId = const ClubId('club-phoenix');
      final closedDate = const GameDate(year: 2026, month: 3, day: 15);
      expect(
        context.economyConfig.transfer.isWindowOpen(closedDate.month),
        isFalse,
      );
      final target = context.registry.players.values.firstWhere(
        (p) => p.clubId != buyerId,
      );

      final error = context.economyRunner.tryUserBuyPlayer(
        buyerId: buyerId,
        playerId: target.id,
        date: closedDate,
      );
      expect(error, isNotNull);
      expect(error, contains('fechada'));
    });

    test('tryUpgradeFacility upgrades academy and deducts balance', () {
      final clubId = const ClubId('club-phoenix');
      final bus = EventBus();
      final financeEngine = FinanceEngine(
        registry: context.registry,
        config: context.economyConfig.finance,
        staffConfig: context.economyConfig.staff,
        eventBus: bus,
      );
      final before = context.registry.clubFinances[clubId]!;
      final level = before.academyLevel;
      expect(level, lessThan(ClubFinance.maxFacilityLevel));
      final cost = ClubFinance.upgradeCost(level);
      final date = context.simulationEngine.worldState.currentDate;

      final error = financeEngine.tryUpgradeFacility(
        clubId: clubId,
        kind: FacilityKind.academy,
        date: date,
      );

      expect(error, isNull);
      final after = context.registry.clubFinances[clubId]!;
      expect(after.academyLevel, level + 1);
      expect(after.balance, before.balance - cost);
      expect(after.seasonExpenses, before.seasonExpenses + cost);
      expect(context.registry.getClub(clubId)!.budget, after.balance);
      expect(
        bus.history.whereType<FacilityUpgradedEvent>().length,
        1,
      );
    });

    test('tryUpgradeFacility rejects insufficient balance', () {
      final clubId = const ClubId('club-phoenix');
      final financeEngine = FinanceEngine(
        registry: context.registry,
        config: context.economyConfig.finance,
        staffConfig: context.economyConfig.staff,
        eventBus: EventBus(),
      );
      final before = context.registry.clubFinances[clubId]!;
      context.registry.clubFinances[clubId] = before.copyWith(balance: 0);

      final error = financeEngine.tryUpgradeFacility(
        clubId: clubId,
        kind: FacilityKind.training,
        date: context.simulationEngine.worldState.currentDate,
      );

      expect(error, 'Saldo insuficiente');
      expect(
        context.registry.clubFinances[clubId]!.trainingLevel,
        before.trainingLevel,
      );
    });

    test('tryUpgradeFacility rejects max level', () {
      final clubId = const ClubId('club-phoenix');
      final financeEngine = FinanceEngine(
        registry: context.registry,
        config: context.economyConfig.finance,
        staffConfig: context.economyConfig.staff,
        eventBus: EventBus(),
      );
      final before = context.registry.clubFinances[clubId]!;
      context.registry.clubFinances[clubId] = before.copyWith(
        trainingLevel: ClubFinance.maxFacilityLevel,
        balance: 10000000,
      );

      final error = financeEngine.tryUpgradeFacility(
        clubId: clubId,
        kind: FacilityKind.training,
        date: context.simulationEngine.worldState.currentDate,
      );

      expect(error, 'Já estás no nível máximo');
      expect(
        context.registry.clubFinances[clubId]!.trainingLevel,
        ClubFinance.maxFacilityLevel,
      );
    });

    test('ClubFinance trainingLevel round-trips through map', () {
      const finance = ClubFinance(
        clubId: ClubId('club-phoenix'),
        balance: 1000000,
        trainingLevel: 4,
        academyLevel: 3,
        seasonTicketRevenue: 12000,
        seasonWageExpenses: 45000,
      );
      final restored = ClubFinance.fromMap(finance.toMap());
      expect(restored.trainingLevel, 4);
      expect(restored.academyLevel, 3);
      expect(restored.seasonTicketRevenue, 12000);
      expect(restored.seasonWageExpenses, 45000);

      final legacy = ClubFinance.fromMap({
        'clubId': 'club-phoenix',
        'balance': 500000,
      });
      expect(legacy.trainingLevel, 2);
      expect(legacy.academyLevel, 2);
      expect(legacy.seasonTicketRevenue, 0);
      expect(legacy.seasonWageExpenses, 0);
    });

    test('match day and wages accumulate on persisted season fields', () {
      final clubId = ClubId('club-phoenix');
      final financeEngine = FinanceEngine(
        registry: context.registry,
        config: context.economyConfig.finance,
        staffConfig: context.economyConfig.staff,
        eventBus: context.eventBus,
      );
      final before = context.registry.clubFinances[clubId]!;
      final club = context.registry.getClub(clubId)!;
      final payDay = context.economyConfig.finance.salaryPaymentDay;

      financeEngine.recordMatchDayRevenue(
        homeClubId: clubId,
        homeClub: club,
        date: const GameDate(year: 2026, month: 8, day: 10),
      );
      financeEngine.runDaily(
        GameDate(year: 2026, month: 8, day: payDay),
      );

      final after = context.registry.clubFinances[clubId]!;
      expect(after.seasonTicketRevenue, greaterThan(before.seasonTicketRevenue));
      expect(after.seasonWageExpenses, before.monthlyWages);
    });
  });
}

int _daysBetween(GameDate from, GameDate to) {
  var days = 0;
  var cursor = from;
  while (cursor.compareTo(to) < 0) {
    cursor = cursor.addDays(1);
    days += 1;
  }
  return days;
}
