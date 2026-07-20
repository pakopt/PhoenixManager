import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:phoenix_ui/src/game/simulation_lab_presets.dart';

enum SimulationLabMode {
  untilSeasonEnd('Até fim de época'),
  seasons('Épocas'),
  days('Dias');

  const SimulationLabMode(this.label);
  final String label;
}

/// Input for a headless lab run (must be isolate-safe).
class SimulationLabParams {
  const SimulationLabParams({
    required this.worldId,
    required this.mode,
    this.amount = 1,
    this.maxDays = 400,
    this.seed = 42,
    this.matchPreset = SimulationLabMatchPreset.defaultPreset,
    this.economyPreset = SimulationLabEconomyPreset.defaultPreset,
  });

  final String worldId;
  final SimulationLabMode mode;
  final int amount;
  final int maxDays;
  final int seed;
  final SimulationLabMatchPreset matchPreset;
  final SimulationLabEconomyPreset economyPreset;
}

class SimulationLabStandingRow {
  const SimulationLabStandingRow({
    required this.position,
    required this.clubName,
    required this.points,
    required this.won,
    required this.drawn,
    required this.lost,
  });

  final int position;
  final String clubName;
  final int points;
  final int won;
  final int drawn;
  final int lost;
}

class SimulationLabFinanceRow {
  const SimulationLabFinanceRow({
    required this.clubName,
    required this.balance,
    required this.seasonRevenue,
    required this.seasonExpenses,
  });

  final String clubName;
  final int balance;
  final int seasonRevenue;
  final int seasonExpenses;
}

class SimulationLabTransferRow {
  const SimulationLabTransferRow({
    required this.playerName,
    required this.toClubName,
    required this.fee,
    required this.isFree,
  });

  final String playerName;
  final String toClubName;
  final int fee;
  final bool isFree;
}

/// Read-only snapshot after a lab run — no engine references.
class SimulationLabReport {
  const SimulationLabReport({
    required this.result,
    required this.elapsedMs,
    required this.standings,
    required this.finances,
    required this.transfers,
    required this.transferCount,
    required this.youthPlayersGenerated,
    required this.totalPlayers,
    required this.matchPresetLabel,
    required this.economyPresetLabel,
    required this.totalGoals,
    required this.averageGoalsPerMatch,
    required this.averageXgPerMatch,
  });

  final SimulationLabResult result;
  final int elapsedMs;
  final List<SimulationLabStandingRow> standings;
  final List<SimulationLabFinanceRow> finances;
  final List<SimulationLabTransferRow> transfers;
  final int transferCount;
  final int youthPlayersGenerated;
  final int totalPlayers;
  final String matchPresetLabel;
  final String economyPresetLabel;
  final int totalGoals;
  final double averageGoalsPerMatch;
  final double averageXgPerMatch;

  String get modeSummary {
    if (result.seasonComplete) {
      return 'Época concluída';
    }
    return '${result.daysSimulated} dias simulados';
  }

  String? get championName =>
      standings.isEmpty ? null : standings.first.clubName;
}

/// Lightweight row for comparing multiple lab runs.
class SimulationLabRunSummary {
  const SimulationLabRunSummary({
    required this.runAt,
    required this.matchPresetLabel,
    required this.economyPresetLabel,
    required this.modeSummary,
    required this.averageGoalsPerMatch,
    required this.averageXgPerMatch,
    required this.transferCount,
    required this.youthPlayersGenerated,
    required this.elapsedMs,
    required this.matchesPlayed,
    this.championName,
  });

  factory SimulationLabRunSummary.fromReport(SimulationLabReport report) {
    return SimulationLabRunSummary(
      runAt: DateTime.now(),
      matchPresetLabel: report.matchPresetLabel,
      economyPresetLabel: report.economyPresetLabel,
      modeSummary: report.modeSummary,
      averageGoalsPerMatch: report.averageGoalsPerMatch,
      averageXgPerMatch: report.averageXgPerMatch,
      transferCount: report.transferCount,
      youthPlayersGenerated: report.youthPlayersGenerated,
      elapsedMs: report.elapsedMs,
      matchesPlayed: report.result.matchesPlayed,
      championName: report.championName,
    );
  }

  final DateTime runAt;
  final String matchPresetLabel;
  final String economyPresetLabel;
  final String modeSummary;
  final double averageGoalsPerMatch;
  final double averageXgPerMatch;
  final int transferCount;
  final int youthPlayersGenerated;
  final int elapsedMs;
  final int matchesPlayed;
  final String? championName;

  String get presetLabel => '$matchPresetLabel · $economyPresetLabel';
}
