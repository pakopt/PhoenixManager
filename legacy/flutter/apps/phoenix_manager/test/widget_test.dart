import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/phoenix_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots to loading or career menu', (tester) async {
    await tester.pumpWidget(createPhoenixManagerApp());
    await tester.pump();

    final hasMenu =
        find.text('Escolhe um slot de carreira').evaluate().isNotEmpty;
    final hasLoading =
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
    expect(hasMenu || hasLoading, isTrue);
  });
}
