import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MatchDetailScreen express mode shows flash icon', (tester) async {
    final controller = GameController();
    await controller.initializeMenu();
    await controller.quickPlay();

    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (controller.isReady) {
        break;
      }
    }
    expect(controller.isReady, isTrue);

    final output = controller.advanceExpressRound();
    expect(output, isNotNull);

    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailScreen(
          session: controller.session!,
          output: output!,
          expressMode: true,
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.flash_on), findsWidgets);
    // Placar animado (contagem até resultado final)
    expect(find.textContaining(' - '), findsWidgets);
  });
}
