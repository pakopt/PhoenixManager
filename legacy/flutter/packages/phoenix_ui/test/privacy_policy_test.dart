import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/legal/app_privacy_policy.dart';
import 'package:phoenix_ui/src/screens/privacy_policy_screen.dart';

void main() {
  testWidgets('PrivacyPolicyScreen shows contact email', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPolicyScreen()),
    );

    expect(find.text('Política de Privacidade'), findsOneWidget);
    expect(find.text('Resumo'), findsOneWidget);
    expect(AppPrivacyPolicy.contactEmail, isNotEmpty);
  });
}
