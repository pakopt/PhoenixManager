import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';

enum MatchOutcome { win, draw, loss }

class RecentFormEntry {
  const RecentFormEntry({
    required this.fixture,
    required this.outcome,
  });

  final MatchFixture fixture;
  final MatchOutcome outcome;

  String get label => switch (outcome) {
        MatchOutcome.win => 'V',
        MatchOutcome.draw => 'E',
        MatchOutcome.loss => 'D',
      };
}

abstract final class RecentForm {
  static List<RecentFormEntry> fromSession(GameSession session, {int limit = 5}) {
    final played = session.allFixtures
        .where(
          (f) => f.isPlayed && f.involvesClub(GameSession.userClubId),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return played
        .take(limit)
        .map(
          (fixture) => RecentFormEntry(
            fixture: fixture,
            outcome: _outcome(fixture),
          ),
        )
        .toList();
  }

  static MatchOutcome _outcome(MatchFixture fixture) {
    final home = fixture.homeScore!;
    final away = fixture.awayScore!;
    final isHome = fixture.homeClubId == GameSession.userClubId;
    final scored = isHome ? home : away;
    final conceded = isHome ? away : home;

    if (scored > conceded) {
      return MatchOutcome.win;
    }
    if (scored == conceded) {
      return MatchOutcome.draw;
    }
    return MatchOutcome.loss;
  }
}
