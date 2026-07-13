import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/util/money_format.dart';

void main() {
  group('MoneyFormat', () {
    test('compact formats millions and thousands', () {
      expect(MoneyFormat.compact(2500000), '€2.5M');
      expect(MoneyFormat.compact(45000), '€45K');
      expect(MoneyFormat.compact(500), '€500');
    });

    test('perMonth suffix', () {
      expect(MoneyFormat.perMonth(25000), '€25K/mês');
    });
  });
}
