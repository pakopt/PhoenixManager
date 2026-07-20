import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:phoenix_ui/src/game/simulation_lab_presets.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';
import 'package:phoenix_ui/src/game/simulation_lab_service.dart';

void main() {
  test('executeSimulationLab completes one season with standings', () async {
    final report = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-ui-test-${DateTime.now().millisecondsSinceEpoch}',
        mode: SimulationLabMode.untilSeasonEnd,
      ),
    );

    expect(report.result.daysSimulated, greaterThan(0));
    expect(report.result.matchesPlayed, greaterThan(0));
    expect(report.standings, isNotEmpty);
    expect(report.totalPlayers, greaterThan(0));
    expect(report.elapsedMs, greaterThanOrEqualTo(0));
  });

  test('executeSimulationLab runs multiple days', () async {
    final report = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-days-test-${DateTime.now().millisecondsSinceEpoch}',
        mode: SimulationLabMode.days,
        amount: 14,
      ),
    );

    expect(report.result.daysSimulated, 14);
    expect(report.result.endTick, report.result.startTick + 14);
  });

  test('high xG preset yields more goals than low xG preset', () async {
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final high = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-xg-high-$stamp',
        mode: SimulationLabMode.untilSeasonEnd,
        seed: 42,
        matchPreset: SimulationLabMatchPreset.highScoring,
      ),
    );
    final low = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-xg-low-$stamp',
        mode: SimulationLabMode.untilSeasonEnd,
        seed: 42,
        matchPreset: SimulationLabMatchPreset.lowScoring,
      ),
    );

    expect(high.averageGoalsPerMatch, greaterThan(low.averageGoalsPerMatch));
    expect(high.matchPresetLabel, 'Alto xG');
    expect(low.matchPresetLabel, 'Baixo xG');
  });

  test('generous economy preset allows more transfers than tight', () async {
    final stamp = DateTime.now().millisecondsSinceEpoch;

    final generous = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-eco-gen-$stamp',
        mode: SimulationLabMode.untilSeasonEnd,
        seed: 42,
        economyPreset: SimulationLabEconomyPreset.generous,
      ),
    );
    final tight = await executeSimulationLab(
      SimulationLabParams(
        worldId: 'lab-eco-tight-$stamp',
        mode: SimulationLabMode.untilSeasonEnd,
        seed: 42,
        economyPreset: SimulationLabEconomyPreset.tight,
      ),
    );

    expect(generous.transferCount, greaterThanOrEqualTo(tight.transferCount));
    expect(generous.economyPresetLabel, 'Generosa');
    expect(tight.economyPresetLabel, 'Apertada');
  });

  test('SimulationLabRunSummary captures champion from report', () {
    const report = SimulationLabReport(
      result: SimulationLabResult(
        daysSimulated: 100,
        startTick: 0,
        endTick: 100,
        startDate: GameDate(year: 2026, month: 8, day: 1),
        endDate: GameDate(year: 2027, month: 5, day: 1),
        eventsPublished: 50,
        matchesPlayed: 14,
        seasonComplete: true,
      ),
      elapsedMs: 42,
      standings: const [
        SimulationLabStandingRow(
          position: 1,
          clubName: 'Phoenix FC',
          points: 30,
          won: 9,
          drawn: 3,
          lost: 2,
        ),
      ],
      finances: const [],
      transfers: const [],
      transferCount: 3,
      youthPlayersGenerated: 8,
      totalPlayers: 12,
      matchPresetLabel: 'Alto xG',
      economyPresetLabel: 'Padrão',
      totalGoals: 40,
      averageGoalsPerMatch: 2.86,
      averageXgPerMatch: 2.5,
    );

    final summary = SimulationLabRunSummary.fromReport(report);
    expect(summary.championName, 'Phoenix FC');
    expect(summary.averageGoalsPerMatch, 2.86);
    expect(summary.presetLabel, 'Alto xG · Padrão');
  });
}
