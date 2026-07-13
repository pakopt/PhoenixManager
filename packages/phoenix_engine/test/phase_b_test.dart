import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('LeagueScheduler', () {
    test('generates double round-robin for 4 clubs', () {
      const competition = Competition(
        id: CompetitionId('liga-test'),
        name: 'Test League',
        type: CompetitionType.league,
        seasonYear: 2026,
        participantClubIds: [
          ClubId('a'),
          ClubId('b'),
          ClubId('c'),
          ClubId('d'),
        ],
        rules: CompetitionRules(doubleRoundRobin: true),
      );

      final fixtures = const LeagueScheduler().generate(
        competition: competition,
        seasonStart: GameDate(year: 2026, month: 8, day: 1),
        daysBetweenRounds: 7,
      );

      expect(fixtures.length, 12);
      expect(fixtures.where((f) => f.isPlayed).length, 0);
    });
  });

  group('CompetitionManager', () {
    test('updates standings after match result', () {
      final registry = WorldRegistry(
        clubs: {
          const ClubId('a'): const Club(id: ClubId('a'), name: 'A', cityId: CityId('c1')),
          const ClubId('b'): const Club(id: ClubId('b'), name: 'B', cityId: CityId('c1')),
        },
        competitions: {
          const CompetitionId('liga'): const Competition(
            id: CompetitionId('liga'),
            name: 'Liga',
            type: CompetitionType.league,
            seasonYear: 2026,
            participantClubIds: [ClubId('a'), ClubId('b')],
            rules: CompetitionRules(doubleRoundRobin: false),
          ),
        },
      );

      final manager = CompetitionManager(registry: registry);
      manager.initializeStandings(const CompetitionId('liga'));

      const fixture = MatchFixture(
        id: MatchId('m1'),
        competitionId: CompetitionId('liga'),
        round: 1,
        homeClubId: ClubId('a'),
        awayClubId: ClubId('b'),
        date: GameDate(year: 2026, month: 8, day: 1),
      );
      registry.registerFixture(fixture);
      manager.recordResult(fixture.withResult(homeScore: 2, awayScore: 1));

      final table = manager.standings(const CompetitionId('liga'));
      expect(table.firstWhere((e) => e.clubId == const ClubId('a')).points, 3);
      expect(table.firstWhere((e) => e.clubId == const ClubId('b')).points, 0);
    });
  });
}
