import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameController.quickPlay', () {
    test('starts express career on first empty slot when no saves', () async {
      final controller = GameController();
      await controller.initializeMenu();
      expect(controller.hasSave, isFalse);

      await controller.quickPlay();

      expect(controller.isReady, isTrue);
      expect(controller.playMode, PlayMode.express);
      expect(controller.activeSlot, 0);
    });
  });
}
