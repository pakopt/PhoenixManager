import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:test/test.dart';

void main() {
  group('PSE Alpha v0.1 / v0.2', () {
    late EngineContext context;

    setUp(() async {
      context = await AppBootstrap().boot(worldId: 'test-world');
    });

    test('boot loads Liga Phoenix with 6 clubs and players', () {
      expect(context.registry.clubs.length, 6);
      expect(context.registry.players.length, 6 * 16);
      expect(context.registry.fixtures.isNotEmpty, isTrue);
    });

    test('boot generates full staff roster for every club', () {
      expect(context.registry.staff.length, 6 * StaffRole.values.length);
      final phoenixStaff =
          context.registry.staffQuery.getByClubId(const ClubId('club-phoenix'));
      expect(phoenixStaff.length, StaffRole.values.length);
      expect(
        phoenixStaff.any((s) => s.name == 'Dr. Miguel Ramos'),
        isTrue,
      );
    });

    test('SquadQueryService uses clubId SSOT', () {
      const clubId = ClubId('club-phoenix');
      final squad = context.registry.squadQuery.getByClubId(clubId);
      expect(squad.length, 16);
      expect(squad.every((p) => p.clubId == clubId), isTrue);
    });

    test('tickOneDay advances Digital Twin by one day', () {
      final before = context.simulationEngine.worldState;
      final after = context.simulationEngine.tickOneDay();

      expect(after.tick, before.tick + 1);
      expect(after.currentDate, before.currentDate.addDays(1));
    });

    test('WorldState + registry round-trip through SaveManager', () {
      context.simulationEngine.tickOneDay();
      final state = context.simulationEngine.worldState;

      final json = context.saveManager.save(state: state, registry: context.registry);
      final envelope = context.saveManager.deserializeEnvelope(json);

      expect(envelope.world.tick, state.tick);
      expect(envelope.registry.clubs.length, context.registry.clubs.length);
      expect(envelope.registry.players.length, context.registry.players.length);
    });

    test('WorldRegistry.replaceWith loads save in-place', () {
      context.simulationEngine.tickDays(14);
      final json = context.saveManager.save(
        state: context.simulationEngine.worldState,
        registry: context.registry,
      );
      final tickBefore = context.simulationEngine.worldState.tick;

      context.simulationEngine.tickDays(7);
      expect(context.simulationEngine.worldState.tick, greaterThan(tickBefore));

      final envelope = context.saveManager.deserializeEnvelope(json);
      context.registry.replaceWith(envelope.registry);
      context.worldManager.loadState(envelope.world);

      expect(context.simulationEngine.worldState.tick, tickBefore);
    });

    test('EventBus receives DayAdvancedEvent on tick', () {
      var events = 0;
      context.eventBus.subscribe<DayAdvancedEvent>((_) => events++);

      context.simulationEngine.tickOneDay();
      expect(events, 1);
    });

    test('simulates match on fixture date', () {
      final firstFixture = context.registry.fixtures.values.first;
      final daysUntil = _daysBetween(
        context.simulationEngine.worldState.currentDate,
        firstFixture.date,
      );

      context.simulationEngine.tickDays(daysUntil);

      final played = context.registry.getFixture(firstFixture.id);
      expect(played?.isPlayed, isTrue);
      expect(played?.homeScore, isNotNull);
    });

    test('completes Liga Phoenix season headless', () {
      final lab = SimulationLab(context: context);
      final result = lab.runUntilSeasonEnd();

      expect(result.seasonComplete, isTrue);
      expect(result.matchesPlayed, 32);
      expect(
        context.competitionManager.standings(const CompetitionId('liga-phoenix')).length,
        6,
      );
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
