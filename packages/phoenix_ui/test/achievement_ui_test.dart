import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/simulation_lab_export.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('exportSimulationLabCsv', () {
    test('formats runs as csv header and rows', () {
      final csv = exportSimulationLabCsv([
        SimulationLabRunSummary(
          runAt: DateTime(2026, 1, 1),
          matchPresetLabel: 'Alto xG',
          economyPresetLabel: 'Padrão',
          modeSummary: 'Época concluída',
          averageGoalsPerMatch: 3.2,
          averageXgPerMatch: 2.8,
          transferCount: 4,
          youthPlayersGenerated: 8,
          elapsedMs: 120,
          matchesPlayed: 14,
          championName: 'Phoenix FC',
        ),
      ]);

      expect(csv, contains('goals_per_match'));
      expect(csv, contains('Alto xG'));
      expect(csv, contains('3.20'));
      expect(csv, contains('Phoenix FC'));
    });
  });

  group('GameController achievements', () {
    test('queues toast after contract renewal unlock', () async {
      final controller = GameController();
      await controller.boot(worldId: 'ach-controller-test');
      expect(controller.consumePendingAchievementUnlocks(), isEmpty);

      final player = controller.session!.squad.first;
      final error = await controller.renewContract(player.id);
      expect(error, isNull);

      final pending = controller.consumePendingAchievementUnlocks();
      expect(pending, contains(AchievementCatalog.contractRenewed));
    });
  });
}
