import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:phoenix_ui/src/game/simulation_lab_presets.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';

/// Top-level entry for [Isolate.run] — boots a fresh world and returns metrics.
Future<SimulationLabReport> executeSimulationLab(SimulationLabParams params) async {
  final stopwatch = Stopwatch()..start();
  final context = await AppBootstrap().boot(
    worldId: params.worldId,
    configYaml: _configYaml(seed: params.seed),
    matchConfigYaml: params.matchPreset.yaml,
    economyConfigYaml: params.economyPreset.yaml,
  );
  final lab = SimulationLab(context: context);

  final SimulationLabResult result;
  switch (params.mode) {
    case SimulationLabMode.untilSeasonEnd:
      result = lab.runUntilSeasonEnd(maxDays: params.maxDays);
    case SimulationLabMode.seasons:
      result = lab.runSeasons(params.amount);
    case SimulationLabMode.days:
      result = lab.runDays(params.amount);
  }

  stopwatch.stop();
  return _buildReport(context, params, result, stopwatch.elapsedMilliseconds);
}

SimulationLabReport _buildReport(
  EngineContext context,
  SimulationLabParams params,
  SimulationLabResult result,
  int elapsedMs,
) {
  const competitionId = CompetitionId('liga-phoenix');
  final standings = context.competitionManager.standings(competitionId);
  final standingRows = <SimulationLabStandingRow>[];
  for (var i = 0; i < standings.length; i++) {
    final entry = standings[i];
    final club = context.registry.getClub(entry.clubId);
    standingRows.add(
      SimulationLabStandingRow(
        position: i + 1,
        clubName: club?.name ?? entry.clubId.value,
        points: entry.points,
        won: entry.won,
        drawn: entry.drawn,
        lost: entry.lost,
      ),
    );
  }

  final financeRows = context.registry.clubs.values.map((club) {
    final finance = context.registry.clubFinances[club.id];
    return SimulationLabFinanceRow(
      clubName: club.name,
      balance: finance?.balance ?? 0,
      seasonRevenue: finance?.seasonRevenue ?? 0,
      seasonExpenses: finance?.seasonExpenses ?? 0,
    );
  }).toList()
    ..sort((a, b) => b.balance.compareTo(a.balance));

  final allTransfers = context.registry.transfers;
  final transferPreview = allTransfers.take(8).map((transfer) {
    final player = context.registry.getPlayer(transfer.playerId);
    final toClub = context.registry.getClub(transfer.toClubId);
    return SimulationLabTransferRow(
      playerName: player?.name ?? transfer.playerId.value,
      toClubName: toClub?.name ?? transfer.toClubId.value,
      fee: transfer.fee,
      isFree: transfer.isFree,
    );
  }).toList();

  final youthCount = context.eventBus.history
      .whereType<YouthIntakeEvent>()
      .fold<int>(0, (sum, event) => sum + event.players.length);

  final matchEvents =
      context.eventBus.history.whereType<MatchPlayedEvent>().toList();
  var totalGoals = 0;
  var totalXg = 0.0;
  for (final event in matchEvents) {
    totalGoals += event.homeScore + event.awayScore;
    totalXg += event.homeXg + event.awayXg;
  }
  final matchCount = matchEvents.length;
  final averageGoals =
      matchCount == 0 ? 0.0 : totalGoals / matchCount;
  final averageXg = matchCount == 0 ? 0.0 : totalXg / matchCount;

  return SimulationLabReport(
    result: result,
    elapsedMs: elapsedMs,
    standings: standingRows,
    finances: financeRows,
    transfers: transferPreview,
    transferCount: allTransfers.length,
    youthPlayersGenerated: youthCount,
    totalPlayers: context.registry.players.length,
    matchPresetLabel: params.matchPreset.label,
    economyPresetLabel: params.economyPreset.label,
    totalGoals: totalGoals,
    averageGoalsPerMatch: averageGoals,
    averageXgPerMatch: averageXg,
  );
}

String _configYaml({required int seed}) => '''
engineVersion: 0.8.20
sport: football
defaultSeed: $seed
simulation:
  daysPerWeek: 7
  weeksPerSeason: 38
''';
