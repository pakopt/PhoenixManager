import 'dart:io';

import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';

/// Headless runner — advances days and optionally simulates to season end.
Future<void> main(List<String> args) async {
  final context = await AppBootstrap().boot();
  final daysArg = args
      .cast<String?>()
      .whereType<String>()
      .where((a) => int.tryParse(a) != null);
  final days = daysArg.isEmpty ? 1 : int.parse(daysArg.first);

  if (args.contains('--match')) {
    final fixture = context.registry.fixtures.values.first;
    final output = context.matchSimulator.simulate(fixture);
    final home = context.registry.getClub(output.fixture.homeClubId);
    final away = context.registry.getClub(output.fixture.awayClubId);
    stdout.writeln(
      '${home?.name} ${output.result.homeScore}-${output.result.awayScore} ${away?.name}',
    );
    stdout.writeln(
      'Posse: ${output.result.homeStats.possessionPct}% - '
      '${output.result.awayStats.possessionPct}%',
    );
    stdout.writeln(
      'Remates: ${output.result.homeStats.shots} (${output.result.homeStats.xg.toStringAsFixed(2)} xG) - '
      '${output.result.awayStats.shots} (${output.result.awayStats.xg.toStringAsFixed(2)} xG)',
    );
    stdout.writeln('Segmentos: ${output.result.segments.length} | ${output.result.durationMs}ms');
    stdout.writeln('Highlights (${output.result.highlights.length}):');
    for (final line in output.result.highlights.take(8)) {
      stdout.writeln('  $line');
    }
    return;
  }

  if (args.contains('--economy')) {
    final lab = SimulationLab(context: context);
    final result = lab.runUntilSeasonEnd();
    stdout.writeln(
      'Economy season — days=${result.daysSimulated} matches=${result.matchesPlayed}',
    );

    for (final club in context.registry.clubs.values) {
      final finance = context.registry.clubFinances[club.id];
      stdout.writeln(
        '${club.name}: saldo=${finance?.balance} receita=${finance?.seasonRevenue} '
        'despesas=${finance?.seasonExpenses}',
      );
    }

    final transfers = context.registry.transfers;
    stdout.writeln('Transferências: ${transfers.length}');
    for (final transfer in transfers.take(5)) {
      final player = context.registry.getPlayer(transfer.playerId);
      stdout.writeln(
        '  ${player?.name ?? transfer.playerId.value} → '
        '${transfer.toClubId.value} (${transfer.fee}€${transfer.isFree ? ', livre' : ''})',
      );
    }

    final youthCount = context.eventBus.history
        .whereType<YouthIntakeEvent>()
        .fold<int>(0, (sum, e) => sum + e.players.length);
    stdout.writeln('Jovens formados: $youthCount');
    stdout.writeln('Jogadores totais: ${context.registry.players.length}');
    return;
  }

  if (args.contains('--season')) {
    final lab = SimulationLab(context: context);
    final result = lab.runUntilSeasonEnd();
    stdout.writeln(
      'Season complete=${result.seasonComplete} days=${result.daysSimulated} '
      'matches=${result.matchesPlayed}',
    );
    final standings = context.competitionManager.standings(
      const CompetitionId('liga-phoenix'),
    );
    for (var i = 0; i < standings.length; i++) {
      final entry = standings[i];
      final club = context.registry.getClub(entry.clubId);
      stdout.writeln(
        '${i + 1}. ${club?.name ?? entry.clubId.value} — '
        '${entry.points}pts (${entry.won}V ${entry.drawn}E ${entry.lost}D)',
      );
    }
    return;
  }

  context.simulationEngine.tickDays(days);
  final state = context.simulationEngine.worldState;
  stdout.writeln('PSE v0.4 — tick=${state.tick} date=${state.currentDate}');

  if (args.contains('--save')) {
    final payload = context.saveManager.save(
      state: state,
      registry: context.registry,
    );
    stdout.writeln('Save payload bytes: ${payload.length}');
  }
}
