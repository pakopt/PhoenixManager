import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phoenix_ui/phoenix_ui.dart';
import 'package:phoenix_ui/src/game/save_storage.dart';

/// Verifica persistência real via SharedPreferences (macOS / Android / desktop).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('save persiste após reinício do controller (release storage)', (
    tester,
  ) async {
    final storage = SaveStorage();
    for (var i = 0; i < SaveStorage.maxSlots; i++) {
      await storage.clearSlot(i);
    }

    final controller = GameController(saveStorage: storage);
    await controller.initializeMenu();
    expect(controller.hasSave, isFalse);

    await controller.quickPlay();
    await _waitUntilReady(tester, controller);

    final match = controller.advanceExpressRound();
    expect(match, isNotNull, reason: 'Express deveria simular uma jornada');

    await controller.saveGame();
    final tickSaved = controller.session!.tick;
    final clubName = controller.session!.userClub.name;
    expect(await storage.hasSave(0), isTrue);

    // Simula fechar e reabrir a app (novo controller, mesmas prefs).
    final reloaded = GameController(saveStorage: storage);
    await reloaded.initializeMenu();
    expect(reloaded.hasSave, isTrue);
    expect(reloaded.slots[0].clubName, clubName);

    await reloaded.continueCareer(0);
    await _waitUntilReady(tester, reloaded);
    expect(reloaded.session!.tick, tickSaved);
    expect(reloaded.session!.userClub.name, clubName);
  });
}

Future<void> _waitUntilReady(
  WidgetTester tester,
  GameController controller,
) async {
  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (controller.isReady) {
      return;
    }
    if (controller.error != null) {
      fail('Boot falhou: ${controller.error}');
    }
  }
  fail('Timeout à espera do motor PSE');
}
