import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/util/date_format.dart';

void main() {
  group('DateFormatUtil', () {
    test('gameDate formats ISO strings', () {
      expect(
        DateFormatUtil.gameDate('2026-08-15'),
        '15 Ago 2026',
      );
    });

    test('gameDate formats GameDate', () {
      expect(
        DateFormatUtil.gameDate(const GameDate(year: 2026, month: 8, day: 15)),
        '15 Ago 2026',
      );
    });

    test('relative returns agora for recent saves', () {
      expect(
        DateFormatUtil.relative(DateTime.now()),
        'agora',
      );
    });
  });
}
