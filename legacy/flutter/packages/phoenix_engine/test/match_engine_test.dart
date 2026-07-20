import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Match Engine B.2', () {
    late WorldRegistry registry;
    late MatchEngine engine;

    setUp(() {
      registry = WorldPackLoader().loadLigaPhoenixAlpha();
      CompetitionManager(registry: registry).scheduleSeason(
        competitionId: const CompetitionId('liga-phoenix'),
        seasonStart: GameDate(year: 2026, month: 8, day: 15),
      );
      engine = MatchEngine(
        registry: registry,
        config: const MatchEngineConfig(),
      );
    });

    MatchFixture firstFixture() => registry.fixtures.values.first;

    test('simulates exactly 45 segments', () {
      final output = engine.simulate(firstFixture(), worldSeed: 42);
      expect(output.result.segments.length, 45);
      expect(output.result.segments.first.startMinute, 0);
      expect(output.result.segments.last.endMinute, 90);
    });

    test('same seed produces same result (deterministic)', () {
      final fixture = firstFixture();
      final a = engine.simulate(fixture, worldSeed: 99);
      final b = engine.simulate(fixture, worldSeed: 99);
      expect(a.result.homeScore, b.result.homeScore);
      expect(a.result.awayScore, b.result.awayScore);
      expect(a.result.homeStats.xg, b.result.homeStats.xg);
    });

    test('xG accumulates when shots occur', () {
      final output = engine.simulate(firstFixture(), worldSeed: 42);
      final totalShots = output.result.homeStats.shots + output.result.awayStats.shots;
      final totalXg = output.result.homeStats.xg + output.result.awayStats.xg;
      if (totalShots > 0) {
        expect(totalXg, greaterThan(0));
      }
      expect(
        output.result.homeStats.possessionPct +
            output.result.awayStats.possessionPct,
        100,
      );
    });

    test('generates event-driven commentary', () {
      final output = engine.simulate(firstFixture(), worldSeed: 42);
      expect(output.result.commentary.length, 45);
      expect(output.result.highlights.length, lessThanOrEqualTo(45));
    });

    test('completes under 5ms SLA', () {
      final output = engine.simulate(firstFixture(), worldSeed: 42);
      expect(output.result.durationMs, lessThan(5));
    });

    test('score matches goal events in segments', () {
      final output = engine.simulate(firstFixture(), worldSeed: 42);
      final goalsInSegments = output.result.segments
          .expand((s) => s.events)
          .where((e) => e.type == MatchEventType.goal)
          .length;
      expect(
        output.result.homeScore + output.result.awayScore,
        goalsInSegments,
      );
    });
  });
}
