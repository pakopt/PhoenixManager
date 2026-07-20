import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('CompetitionManager beginNextSeason', () {
    test('advances season year and reschedules league and cup', () async {
      final context = await AppBootstrap().boot(worldId: 'season-rollover-test');
      final manager = context.competitionManager;
      final registry = context.registry;

      _playAllFixtures(manager, registry);

      expect(
        manager.isSeasonComplete(const CompetitionId('liga-phoenix')),
        isTrue,
      );
      expect(
        manager.isSeasonComplete(const CompetitionId('taca-phoenix')),
        isTrue,
      );

      final error = manager.beginNextSeason(
        leagueId: const CompetitionId('liga-phoenix'),
        cupId: const CompetitionId('taca-phoenix'),
        leagueSeasonStart: const GameDate(year: 2027, month: 8, day: 15),
      );

      expect(error, isNull);
      expect(
        registry.getCompetition(const CompetitionId('liga-phoenix'))!.seasonYear,
        2027,
      );
      expect(
        registry.getCompetition(const CompetitionId('taca-phoenix'))!.seasonYear,
        2027,
      );
      expect(
        registry
            .getCompetition(const CompetitionId('taca-phoenix'))!
            .knockoutSemiFinalDate,
        const GameDate(year: 2027, month: 9, day: 26),
      );

      final leagueFixtures = registry.fixtures.values
          .where((f) => f.competitionId == const CompetitionId('liga-phoenix'))
          .toList();
      final cupFixtures = registry.fixtures.values
          .where((f) => f.competitionId == const CompetitionId('taca-phoenix'))
          .toList();

      expect(leagueFixtures.length, 30);
      expect(cupFixtures.length, 2);
      expect(leagueFixtures.every((f) => !f.isPlayed), isTrue);
      expect(cupFixtures.every((f) => !f.isPlayed), isTrue);
      expect(manager.standings(const CompetitionId('liga-phoenix')).length, 6);
    });
  });
}

void _playAllFixtures(CompetitionManager manager, WorldRegistry registry) {
  var safety = 0;
  while (safety < 20) {
    final pending =
        registry.fixtures.values.where((f) => !f.isPlayed).toList();
    if (pending.isEmpty) {
      break;
    }
    for (final fixture in pending) {
      manager.recordResult(fixture.withResult(homeScore: 2, awayScore: 1));
    }
    safety += 1;
  }
}
