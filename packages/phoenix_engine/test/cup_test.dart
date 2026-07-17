import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('CupScheduler', () {
    test('seeds semi-finals 1v4 and 2v3 by reputation', () {
      const competition = Competition(
        id: CompetitionId('taca-test'),
        name: 'Taça Test',
        type: CompetitionType.cup,
        seasonYear: 2026,
        participantClubIds: [
          ClubId('club-phoenix'),
          ClubId('club-union'),
          ClubId('club-riverside'),
          ClubId('club-highland'),
        ],
        rules: CompetitionRules(doubleRoundRobin: false),
        knockoutSemiFinalDate: GameDate(year: 2026, month: 9, day: 26),
        knockoutFinalDate: GameDate(year: 2026, month: 10, day: 24),
      );

      const seeded = [
        ClubId('club-phoenix'),
        ClubId('club-union'),
        ClubId('club-riverside'),
        ClubId('club-highland'),
      ];

      final fixtures = const CupScheduler().generateSemiFinals(
        competition: competition,
        semiFinalDate: GameDate(year: 2026, month: 9, day: 26),
        seededClubIds: seeded,
      );

      expect(fixtures.length, 2);
      expect(fixtures[0].homeClubId, const ClubId('club-phoenix'));
      expect(fixtures[0].awayClubId, const ClubId('club-highland'));
      expect(fixtures[1].homeClubId, const ClubId('club-union'));
      expect(fixtures[1].awayClubId, const ClubId('club-riverside'));
    });
  });

  group('Cup bracket', () {
    test('draw goes to higher reputation club', () {
      final registry = WorldRegistry(
        clubs: {
          const ClubId('a'): const Club(
            id: ClubId('a'),
            name: 'A',
            cityId: CityId('c1'),
            reputation: 80,
          ),
          const ClubId('b'): const Club(
            id: ClubId('b'),
            name: 'B',
            cityId: CityId('c1'),
            reputation: 60,
          ),
        },
      );

      const fixture = MatchFixture(
        id: MatchId('sf1'),
        competitionId: CompetitionId('cup'),
        round: 1,
        homeClubId: ClubId('b'),
        awayClubId: ClubId('a'),
        date: GameDate(year: 2026, month: 9, day: 26),
      );

      final winner = resolveCupWinner(
        fixture: fixture.withResult(homeScore: 1, awayScore: 1),
        registry: registry,
      );
      expect(winner, const ClubId('a'));
    });
  });

  group('CompetitionManager cup', () {
    test('schedules semis and generates final after both played', () {
      final registry = WorldRegistry(
        clubs: {
          const ClubId('club-phoenix'): const Club(
            id: ClubId('club-phoenix'),
            name: 'Phoenix FC',
            cityId: CityId('c1'),
            reputation: 78,
          ),
          const ClubId('club-union'): const Club(
            id: ClubId('club-union'),
            name: 'Union City',
            cityId: CityId('c1'),
            reputation: 71,
          ),
          const ClubId('club-riverside'): const Club(
            id: ClubId('club-riverside'),
            name: 'Riverside SC',
            cityId: CityId('c1'),
            reputation: 65,
          ),
          const ClubId('club-highland'): const Club(
            id: ClubId('club-highland'),
            name: 'Highland Athletic',
            cityId: CityId('c1'),
            reputation: 58,
          ),
        },
        competitions: {
          const CompetitionId('taca-phoenix'): const Competition(
            id: CompetitionId('taca-phoenix'),
            name: 'Taça Phoenix',
            type: CompetitionType.cup,
            seasonYear: 2026,
            participantClubIds: [
              ClubId('club-phoenix'),
              ClubId('club-union'),
              ClubId('club-riverside'),
              ClubId('club-highland'),
            ],
            rules: CompetitionRules(doubleRoundRobin: false),
            knockoutSemiFinalDate: GameDate(year: 2026, month: 9, day: 26),
            knockoutFinalDate: GameDate(year: 2026, month: 10, day: 24),
          ),
        },
      );

      final manager = CompetitionManager(registry: registry);
      final semis = manager.scheduleCup(
        competitionId: const CompetitionId('taca-phoenix'),
      );

      expect(semis.length, 2);
      expect(registry.fixtures.length, 2);

      manager.recordResult(
        semis[0].withResult(homeScore: 2, awayScore: 0),
      );
      expect(registry.fixtures.values.where((f) => f.round == 2).length, 0);

      manager.recordResult(
        semis[1].withResult(homeScore: 1, awayScore: 0),
      );

      final finals =
          registry.fixtures.values.where((f) => f.round == 2).toList();
      expect(finals.length, 1);
      expect(finals.first.date, const GameDate(year: 2026, month: 10, day: 24));

      manager.recordResult(finals.first.withResult(homeScore: 3, awayScore: 1));
      expect(
        manager.cupWinner(const CompetitionId('taca-phoenix')),
        finals.first.homeClubId,
      );
      expect(manager.isSeasonComplete(const CompetitionId('taca-phoenix')), isTrue);
    });
  });

  group('AppBootstrap cup', () {
    test('boot schedules league and cup fixtures', () async {
      final context = await AppBootstrap().boot();
      final registry = context.registry;

      final leagueCount = registry.fixtures.values
          .where((f) => f.competitionId == const CompetitionId('liga-phoenix'))
          .length;
      final cupCount = registry.fixtures.values
          .where((f) => f.competitionId == const CompetitionId('taca-phoenix'))
          .length;

      expect(leagueCount, 30);
      expect(cupCount, 2);
      expect(registry.competitions.containsKey(const CompetitionId('taca-phoenix')),
          isTrue);
    });
  });
}
