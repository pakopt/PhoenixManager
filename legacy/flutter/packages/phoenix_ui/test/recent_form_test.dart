import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/recent_form.dart';

void main() {
  test('recentForm is empty before any match', () async {
    final context = await AppBootstrap().boot(worldId: 'form-empty-test');
    final session = GameSession(context);

    expect(session.recentForm(), isEmpty);
  });

  test('recentForm records win after user match', () async {
    final context = await AppBootstrap().boot(worldId: 'form-win-test');
    final session = GameSession(context);

    final userFixture = session.leagueFixtures.firstWhere(
      (f) =>
          f.homeClubId == GameSession.userClubId ||
          f.awayClubId == GameSession.userClubId,
    );
    session.simulateFixture(userFixture);

    expect(session.recentForm(), isNotEmpty);
    expect(session.recentForm().first.fixture.id, userFixture.id);
  });

  test('isTransferWindowOpen follows config months', () async {
    final context = await AppBootstrap().boot(worldId: 'transfer-window-test');
    final session = GameSession(context);
    final month = session.currentDate.month;
    final expected = session.transferConfig.isWindowOpen(month);

    expect(session.isTransferWindowOpen, expected);
  });
}
