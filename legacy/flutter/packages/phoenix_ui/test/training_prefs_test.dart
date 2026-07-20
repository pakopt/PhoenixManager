import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/game/training_prefs.dart';

void main() {
  test('TrainingSnapshot round-trip preserves week and player focus', () {
    final snap = TrainingSnapshot(
      weekFocus: {
        1: WeeklyTrainingFocus.physical,
        3: WeeklyTrainingFocus.defending,
        7: WeeklyTrainingFocus.rest,
      },
      playerFocus: {
        'p-1': PlayerTrainingFocus.finishing,
        'p-2': PlayerTrainingFocus.goalkeeping,
      },
    );

    final restored = TrainingSnapshot.fromMap(snap.toMap());
    expect(restored.focusForWeekday(1), WeeklyTrainingFocus.physical);
    expect(restored.focusForWeekday(3), WeeklyTrainingFocus.defending);
    expect(restored.focusForWeekday(7), WeeklyTrainingFocus.rest);
    expect(restored.focusForWeekday(2), WeeklyTrainingFocus.attacking);
    expect(restored.focusForPlayer('p-1'), PlayerTrainingFocus.finishing);
    expect(restored.focusForPlayer('p-2'), PlayerTrainingFocus.goalkeeping);
    expect(restored.focusForPlayer('missing'), PlayerTrainingFocus.general);
  });

  test('WeeklyTrainingFocus and PlayerTrainingFocus labels are PT', () {
    expect(WeeklyTrainingFocus.possession.labelPt, 'Posse');
    expect(PlayerTrainingFocus.goalkeeping.labelPt, 'Guarda-redes');
  });
}
