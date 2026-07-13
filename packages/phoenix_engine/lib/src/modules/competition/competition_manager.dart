import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/competition/cup_scheduler.dart';
import 'package:phoenix_engine/src/modules/competition/league_scheduler.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Manages competitions, fixtures and league standings.
class CompetitionManager {
  CompetitionManager({
    required WorldRegistry registry,
    LeagueScheduler? scheduler,
    CupScheduler? cupScheduler,
    EventBus? eventBus,
  })  : _registry = registry,
        _scheduler = scheduler ?? const LeagueScheduler(),
        _cupScheduler = cupScheduler ?? const CupScheduler(),
        _eventBus = eventBus;

  final WorldRegistry _registry;
  final LeagueScheduler _scheduler;
  final CupScheduler _cupScheduler;
  final EventBus? _eventBus;

  WorldRegistry get registry => _registry;

  void initializeStandings(CompetitionId competitionId) {
    final competition = _registry.getCompetition(competitionId);
    if (competition == null) {
      throw StateError('Competition not found: $competitionId');
    }
    if (competition.type == CompetitionType.cup) {
      return;
    }

    _registry.standings[competitionId] = competition.participantClubIds
        .map((clubId) => StandingEntry(clubId: clubId))
        .toList();
  }

  List<MatchFixture> scheduleSeason({
    required CompetitionId competitionId,
    required GameDate seasonStart,
    int daysBetweenRounds = 7,
  }) {
    final competition = _registry.getCompetition(competitionId);
    if (competition == null) {
      throw StateError('Competition not found: $competitionId');
    }

    if (competition.type == CompetitionType.cup) {
      return scheduleCup(competitionId: competitionId);
    }

    final fixtures = _scheduler.generate(
      competition: competition,
      seasonStart: seasonStart,
      daysBetweenRounds: daysBetweenRounds,
    );

    for (final fixture in fixtures) {
      _registry.registerFixture(fixture);
    }

    initializeStandings(competitionId);
    return fixtures;
  }

  List<MatchFixture> scheduleCup({
    required CompetitionId competitionId,
  }) {
    final competition = _registry.getCompetition(competitionId);
    if (competition == null) {
      throw StateError('Competition not found: $competitionId');
    }
    final semiDate = competition.knockoutSemiFinalDate;
    final finalDate = competition.knockoutFinalDate;
    if (semiDate == null || finalDate == null) {
      throw StateError('Cup competition missing knockout dates: $competitionId');
    }

    final seeded = _seedClubs(competition.participantClubIds);
    final fixtures = _cupScheduler.generateSemiFinals(
      competition: competition,
      semiFinalDate: semiDate,
      seededClubIds: seeded,
    );

    for (final fixture in fixtures) {
      _registry.registerFixture(fixture);
    }
    return fixtures;
  }

  List<MatchFixture> matchesOnDate(GameDate date) =>
      _registry.fixturesOnDate(date);

  void recordResult(MatchFixture played) {
    if (!played.isPlayed || played.homeScore == null || played.awayScore == null) {
      throw ArgumentError('Fixture must have final score');
    }

    _registry.fixtures[played.id] = played;
    final competition = _registry.getCompetition(played.competitionId);
    if (competition?.type == CompetitionType.league) {
      _updateStandings(played);
    } else if (competition?.type == CompetitionType.cup) {
      _advanceCupIfRoundComplete(played.competitionId);
    }
  }

  List<StandingEntry> standings(CompetitionId competitionId) {
    final table = _registry.standings[competitionId];
    if (table == null) {
      return [];
    }
    return List<StandingEntry>.from(table)
      ..sort((a, b) {
        if (b.points != a.points) {
          return b.points.compareTo(a.points);
        }
        final gdA = a.goalDifference;
        final gdB = b.goalDifference;
        if (gdB != gdA) {
          return gdB.compareTo(gdA);
        }
        return b.goalsFor.compareTo(a.goalsFor);
      });
  }

  ClubId? cupWinner(CompetitionId competitionId) {
    final competition = _registry.getCompetition(competitionId);
    if (competition == null || competition.type != CompetitionType.cup) {
      return null;
    }
    final finalFixture = _registry.fixtures.values
        .where(
          (f) =>
              f.competitionId == competitionId &&
              f.round == 2 &&
              f.isPlayed,
        )
        .firstOrNull;
    if (finalFixture == null) {
      return null;
    }
    return resolveCupWinner(fixture: finalFixture, registry: _registry);
  }

  bool isSeasonComplete(CompetitionId competitionId) {
    final competitionFixtures = _registry.fixtures.values
        .where((f) => f.competitionId == competitionId);
    return competitionFixtures.isNotEmpty &&
        competitionFixtures.every((f) => f.isPlayed);
  }

  /// Starts the next season after league and cup are complete.
  /// Returns an error message on failure, null on success.
  String? beginNextSeason({
    required CompetitionId leagueId,
    required CompetitionId cupId,
    required GameDate leagueSeasonStart,
  }) {
    if (!isSeasonComplete(leagueId)) {
      return 'A liga ainda não terminou';
    }
    if (!isSeasonComplete(cupId)) {
      return 'A taça ainda não terminou';
    }

    final league = _registry.getCompetition(leagueId);
    final cup = _registry.getCompetition(cupId);
    if (league == null || cup == null) {
      return 'Competição não encontrada';
    }

    _clearCompetitionData(leagueId);
    _clearCompetitionData(cupId);

    _registry.registerCompetition(_bumpSeasonYear(league));
    _registry.registerCompetition(_bumpSeasonYear(cup));

    scheduleSeason(
      competitionId: leagueId,
      seasonStart: leagueSeasonStart,
    );
    scheduleCup(competitionId: cupId);

    _eventBus?.publish(
      NewSeasonStartedEvent(
        seasonYear: league.seasonYear + 1,
        startDate: leagueSeasonStart,
      ),
    );

    return null;
  }

  Competition _bumpSeasonYear(Competition competition) {
    return competition.copyWith(
      seasonYear: competition.seasonYear + 1,
      knockoutSemiFinalDate: competition.knockoutSemiFinalDate != null
          ? _addYear(competition.knockoutSemiFinalDate!)
          : null,
      knockoutFinalDate: competition.knockoutFinalDate != null
          ? _addYear(competition.knockoutFinalDate!)
          : null,
    );
  }

  GameDate _addYear(GameDate date) =>
      GameDate(year: date.year + 1, month: date.month, day: date.day);

  void _clearCompetitionData(CompetitionId competitionId) {
    final matchIds = _registry.fixtures.entries
        .where((e) => e.value.competitionId == competitionId)
        .map((e) => e.key)
        .toList();
    for (final matchId in matchIds) {
      _registry.fixtures.remove(matchId);
      _registry.matchResults.remove(matchId);
    }
    _registry.standings.remove(competitionId);
  }

  List<ClubId> _seedClubs(List<ClubId> clubIds) {
    final sorted = List<ClubId>.from(clubIds)
      ..sort((a, b) {
        final repA = _registry.getClub(a)?.reputation ?? 0;
        final repB = _registry.getClub(b)?.reputation ?? 0;
        return repB.compareTo(repA);
      });
    return sorted;
  }

  void _advanceCupIfRoundComplete(CompetitionId competitionId) {
    final competition = _registry.getCompetition(competitionId);
    if (competition == null) {
      return;
    }

    final roundFixtures = _registry.fixtures.values
        .where((f) => f.competitionId == competitionId && f.round == 1)
        .toList()
      ..sort((a, b) => a.id.value.compareTo(b.id.value));
    if (roundFixtures.length < 2 ||
        roundFixtures.any((f) => !f.isPlayed)) {
      return;
    }

    final finalExists = _registry.fixtures.values.any(
      (f) => f.competitionId == competitionId && f.round == 2,
    );
    if (finalExists) {
      return;
    }

    final finalDate = competition.knockoutFinalDate;
    if (finalDate == null) {
      return;
    }

    final winner1 = resolveCupWinner(fixture: roundFixtures[0], registry: _registry);
    final winner2 = resolveCupWinner(fixture: roundFixtures[1], registry: _registry);

    final finalFixture = _cupScheduler.generateFinal(
      competition: competition,
      finalDate: finalDate,
      homeClubId: winner1,
      awayClubId: winner2,
    );
    _registry.registerFixture(finalFixture);
  }

  void _updateStandings(MatchFixture fixture) {
    final competition = _registry.getCompetition(fixture.competitionId);
    if (competition == null) {
      return;
    }

    final table = _registry.standings[fixture.competitionId];
    if (table == null) {
      return;
    }

    final homeScore = fixture.homeScore!;
    final awayScore = fixture.awayScore!;
    final rules = competition.rules;

    for (var i = 0; i < table.length; i++) {
      final entry = table[i];
      if (entry.clubId == fixture.homeClubId) {
        final won = homeScore > awayScore;
        final drawn = homeScore == awayScore;
        final points = won
            ? rules.pointsWin
            : drawn
                ? rules.pointsDraw
                : rules.pointsLoss;
        table[i] = entry.applyResult(
          scored: homeScore,
          conceded: awayScore,
          pointsEarned: points,
          won: won,
          drawn: drawn,
        );
      } else if (entry.clubId == fixture.awayClubId) {
        final won = awayScore > homeScore;
        final drawn = homeScore == awayScore;
        final points = won
            ? rules.pointsWin
            : drawn
                ? rules.pointsDraw
                : rules.pointsLoss;
        table[i] = entry.applyResult(
          scored: awayScore,
          conceded: homeScore,
          pointsEarned: points,
          won: won,
          drawn: drawn,
        );
      }
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
