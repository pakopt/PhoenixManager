import 'package:phoenix_core/phoenix_core.dart';
import 'package:test/test.dart';

void main() {
  group('GameDate', () {
    test('addDays advances calendar correctly', () {
      const date = GameDate(year: 2026, month: 7, day: 15);
      expect(date.addDays(1), const GameDate(year: 2026, month: 7, day: 16));
      expect(date.addDays(20), const GameDate(year: 2026, month: 8, day: 4));
    });
  });

  group('SeededRng', () {
    test('same seed produces same sequence', () {
      final a = SeededRng(42);
      final b = SeededRng(42);
      expect(a.nextInt(1000), b.nextInt(1000));
      expect(a.nextInt(1000), b.nextInt(1000));
    });
  });
}
