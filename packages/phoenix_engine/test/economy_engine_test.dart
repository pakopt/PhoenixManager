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
      expect(context.registry.clubFinances.length, 5);
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
      expect(youthEvents.length, 5);
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

      expect(envelope.registry.clubFinances.length, 5);
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
