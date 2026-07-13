import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:phoenix_ui/phoenix_ui.dart';
import 'package:phoenix_ui/src/game/save_storage.dart';

/// Captura screenshots Play Store — usar com test_driver/store_screenshots_driver.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots for Play Console', (tester) async {
    final storage = SaveStorage();
    for (var i = 0; i < SaveStorage.maxSlots; i++) {
      await storage.clearSlot(i);
    }

    final controller = GameController(saveStorage: storage);
    await tester.pumpWidget(createPhoenixManagerApp(controller: controller));

    await _waitFor(
      tester,
      find.text('Project Phoenix Manager'),
      reason: 'menu carreira',
    );
    await _shot(binding, tester, 'menu-carreira', convertSurface: true);

    await tester.tap(find.text('Jogar agora'));
    await _waitUntilReady(tester, controller);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _waitFor(
      tester,
      find.textContaining('Simular jornada'),
      reason: 'dashboard',
    );
    await _shot(binding, tester, 'dashboard');

    await tester.tap(find.byIcon(Icons.groups_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _shot(binding, tester, 'plantel');

    await tester.tap(find.byIcon(Icons.leaderboard_outlined).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await _shot(binding, tester, 'classificacao');

    await tester.tap(find.byIcon(Icons.home_outlined).first);
    await tester.pumpAndSettle();
    final simLabel = find.text('Simular jornada (Express)');
    if (simLabel.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(simLabel, 400);
      await tester.ensureVisible(simLabel);
      await tester.tap(
        find.ancestor(of: simLabel, matching: find.byType(FilledButton)),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle(const Duration(seconds: 8));
      final home = find.byIcon(Icons.home_outlined);
      if (home.evaluate().isNotEmpty) {
        await tester.tap(home.first);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      await _shot(binding, tester, 'express');
    }
  });
}

Future<void> _shot(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name, {
  bool convertSurface = false,
}) async {
  if (Platform.isAndroid && convertSurface) {
    await binding.convertFlutterSurfaceToImage();
  }
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}

Future<void> _waitFor(
  WidgetTester tester,
  Finder finder, {
  required String reason,
  int seconds = 90,
}) async {
  for (var i = 0; i < seconds * 2; i++) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Timeout à espera de $reason');
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
