import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';

/// Aggregated career record for the user club — computed from played fixtures.
class CareerStats {
  const CareerStats({
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.seasonsManaged,
    required this.leagueTitles,
    required this.cupTitles,
  });

  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int seasonsManaged;
  final int leagueTitles;
  final int cupTitles;

  int get goalDifference => goalsFor - goalsAgainst;

  int get points => won * 3 + drawn;

  double get winRate => played <= 0 ? 0 : won / played;

  String get recordLabel => '${won}V ${drawn}E ${lost}D';

  static CareerStats fromSession(GameSession session) {
    var won = 0;
    var drawn = 0;
    var lost = 0;
    var goalsFor = 0;
    var goalsAgainst = 0;

    for (final fixture in session.allFixtures) {
      if (!fixture.isPlayed || !fixture.involvesClub(GameSession.userClubId)) {
        continue;
      }

      final home = fixture.homeScore!;
      final away = fixture.awayScore!;
      final isHome = fixture.homeClubId == GameSession.userClubId;
      final scored = isHome ? home : away;
      final conceded = isHome ? away : home;

      goalsFor += scored;
      goalsAgainst += conceded;

      if (scored > conceded) {
        won += 1;
      } else if (scored == conceded) {
        drawn += 1;
      } else {
        lost += 1;
      }
    }

    return CareerStats(
      played: won + drawn + lost,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      seasonsManaged: session.seasonYear - 2026 + 1,
      leagueTitles: session.leagueTitlesWon,
      cupTitles: session.cupTitlesWon,
    );
  }
}
