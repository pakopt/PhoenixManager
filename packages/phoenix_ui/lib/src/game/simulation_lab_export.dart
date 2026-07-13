import 'package:phoenix_ui/src/game/simulation_lab_report.dart';

/// Formats lab run history as CSV for clipboard export.
String exportSimulationLabCsv(List<SimulationLabRunSummary> runs) {
  final buffer = StringBuffer()
    ..writeln(
      'run,xg_preset,economy_preset,goals_per_match,xg_per_match,'
      'transfers,youth,ms,champion',
    );

  for (var i = 0; i < runs.length; i++) {
    final run = runs[i];
    buffer.writeln(
      '${i + 1},'
      '${_csv(run.matchPresetLabel)},'
      '${_csv(run.economyPresetLabel)},'
      '${run.averageGoalsPerMatch.toStringAsFixed(2)},'
      '${run.averageXgPerMatch.toStringAsFixed(2)},'
      '${run.transferCount},'
      '${run.youthPlayersGenerated},'
      '${run.elapsedMs},'
      '${_csv(run.championName ?? '')}',
    );
  }

  return buffer.toString();
}

String _csv(String value) {
  if (value.contains(',') || value.contains('"')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
