import 'package:phoenix_core/phoenix_core.dart';

/// Generates round-robin league calendars — competition-agnostic.
class LeagueScheduler {
  const LeagueScheduler();

  List<MatchFixture> generate({
    required Competition competition,
    required GameDate seasonStart,
    required int daysBetweenRounds,
  }) {
    final clubs = List<ClubId>.from(competition.participantClubIds);
    if (clubs.length < 2) {
      return [];
    }

    if (clubs.length.isOdd) {
      clubs.add(const ClubId('bye-club'));
    }

    final rounds = _roundRobinRounds(clubs);
    final fixtures = <MatchFixture>[];
    var roundNumber = 1;
    var date = seasonStart;

    for (final round in rounds) {
      for (final pairing in round) {
        if (pairing.$1.value == 'bye-club' || pairing.$2.value == 'bye-club') {
          continue;
        }
        fixtures.add(
          MatchFixture(
            id: MatchId(
              '${competition.id.value}-r$roundNumber-${pairing.$1.value}-${pairing.$2.value}',
            ),
            competitionId: competition.id,
            round: roundNumber,
            homeClubId: pairing.$1,
            awayClubId: pairing.$2,
            date: date,
          ),
        );
      }
      roundNumber += 1;
      date = date.addDays(daysBetweenRounds);
    }

    if (competition.rules.doubleRoundRobin) {
      final returnLegStart = roundNumber;
      for (var i = 0; i < rounds.length; i++) {
        final round = rounds[i];
        for (final pairing in round) {
          if (pairing.$1.value == 'bye-club' || pairing.$2.value == 'bye-club') {
            continue;
          }
          fixtures.add(
            MatchFixture(
              id: MatchId(
                '${competition.id.value}-r$roundNumber-${pairing.$2.value}-${pairing.$1.value}',
              ),
              competitionId: competition.id,
              round: roundNumber,
              homeClubId: pairing.$2,
              awayClubId: pairing.$1,
              date: date,
            ),
          );
        }
        roundNumber += 1;
        date = date.addDays(daysBetweenRounds);
      }
      assert(roundNumber == returnLegStart + rounds.length);
    }

    return fixtures;
  }

  List<List<(ClubId, ClubId)>> _roundRobinRounds(List<ClubId> clubs) {
    final n = clubs.length;
    final fixed = clubs.first;
    final rotating = clubs.sublist(1);
    final rounds = <List<(ClubId, ClubId)>>[];

    for (var round = 0; round < n - 1; round++) {
      final pairings = <(ClubId, ClubId)>[];
      final left = [fixed, ...rotating.sublist(0, rotating.length ~/ 2)];
      final right = rotating.sublist(rotating.length ~/ 2).reversed.toList();

      for (var i = 0; i < left.length; i++) {
        pairings.add((left[i], right[i]));
      }

      rounds.add(pairings);
      rotating.insert(0, rotating.removeLast());
    }

    return rounds;
  }
}
