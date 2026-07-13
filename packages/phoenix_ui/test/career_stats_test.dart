import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/career_stats.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

void main() {
  test('careerStats is zero at career start', () async {
    final context = await AppBootstrap().boot(worldId: 'career-stats-test');
    final session = GameSession(context);
    final stats = session.careerStats;

    expect(stats.played, 0);
    expect(stats.won, 0);
    expect(stats.seasonsManaged, 1);
    expect(stats.leagueTitles, 0);
    expect(stats.recordLabel, '0V 0E 0D');
  });

  test('careerStats counts played user fixtures', () async {
    final context = await AppBootstrap().boot(worldId: 'career-stats-win');
    final session = GameSession(context);

    final userFixture = session.leagueFixtures.firstWhere(
      (f) =>
          f.homeClubId == GameSession.userClubId ||
          f.awayClubId == GameSession.userClubId,
    );
    session.simulateFixture(userFixture);

    final stats = session.careerStats;
    expect(stats.played, 1);
    expect(stats.won + stats.drawn + stats.lost, 1);
    expect(stats.goalsFor, greaterThanOrEqualTo(0));
    expect(stats.goalsAgainst, greaterThanOrEqualTo(0));
  });
}
