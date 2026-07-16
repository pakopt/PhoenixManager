import 'dart:io';

import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';

/// Gera arte SVG do motor PSE para o site (`docs/site/motor-pse.svg`).
///
/// Uso: `dart run bin/export_site_engine_svg.dart`
Future<void> main() async {
  final root = Directory.current.path;
  final outSvg = File('$root/docs/site/motor-pse.svg');
  await outSvg.parent.create(recursive: true);

  final context = await AppBootstrap().boot(worldId: 'site-engine-art');
  final lab = SimulationLab(context: context);
  final season = lab.runUntilSeasonEnd();

  final fixture = context.registry.fixtures.values.first;
  final match = context.matchSimulator.simulate(fixture);
  final home = context.registry.getClub(match.fixture.homeClubId);
  final away = context.registry.getClub(match.fixture.awayClubId);

  const competitionId = CompetitionId('liga-phoenix');
  final standings = context.competitionManager.standings(competitionId);
  final top = standings.take(4).toList();

  final svg = _buildSvg(
    days: season.daysSimulated,
    matches: season.matchesPlayed,
    events: season.eventsPublished,
    seasonComplete: season.seasonComplete,
    homeName: home?.name ?? 'Casa',
    awayName: away?.name ?? 'Fora',
    homeScore: match.result.homeScore,
    awayScore: match.result.awayScore,
    homeXg: match.result.homeStats.xg,
    awayXg: match.result.awayStats.xg,
    homeShots: match.result.homeStats.shots,
    awayShots: match.result.awayStats.shots,
    durationMs: match.result.durationMs,
    segments: match.result.segments.length,
    standings: [
      for (final row in top)
        (
          name: context.registry.getClub(row.clubId)?.name ?? row.clubId.value,
          pts: row.points,
          played: row.played,
        ),
    ],
  );

  await outSvg.writeAsString(svg);
  stdout.writeln('OK  ${outSvg.path}');

  // PNG via Chrome headless (melhor qualidade que qlmanage).
  final outPng = File('$root/docs/site/motor-pse.png');
  final chromeCandidates = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium',
  ];
  String? chrome;
  for (final c in chromeCandidates) {
    if (File(c).existsSync()) {
      chrome = c;
      break;
    }
  }
  if (chrome != null) {
    final uri = Uri.file(outSvg.path).toString();
    final shot = await Process.run(chrome, [
      '--headless=new',
      '--disable-gpu',
      '--hide-scrollbars',
      '--window-size=1200,720',
      '--screenshot=${outPng.path}',
      uri,
    ]);
    if (shot.exitCode == 0 && outPng.existsSync() && outPng.lengthSync() > 1000) {
      stdout.writeln('OK  ${outPng.path}');
    } else {
      stdout.writeln('AVISO: Chrome headless falhou (exit ${shot.exitCode}).');
    }
  } else {
    stdout.writeln('AVISO: Chrome não encontrado — fica só o SVG.');
  }
}

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _buildSvg({
  required int days,
  required int matches,
  required int events,
  required bool seasonComplete,
  required String homeName,
  required String awayName,
  required int homeScore,
  required int awayScore,
  required double homeXg,
  required double awayXg,
  required int homeShots,
  required int awayShots,
  required int durationMs,
  required int segments,
  required List<({String name, int pts, int played})> standings,
}) {
  final standingLines = StringBuffer();
  for (var i = 0; i < standings.length; i++) {
    final s = standings[i];
    final y = 548 + i * 36;
    standingLines.writeln('''
    <text x="64" y="$y" fill="#c5cae9" font-size="18" font-family="ui-sans-serif, system-ui, sans-serif">${i + 1}. ${_esc(s.name)}</text>
    <text x="980" y="$y" fill="#81c784" font-size="18" font-family="ui-sans-serif, system-ui, sans-serif" text-anchor="end">${s.pts} pts · ${s.played}J</text>''');
  }

  return '''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="720" viewBox="0 0 1200 720">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0a0e14"/>
      <stop offset="100%" stop-color="#141b2d"/>
    </linearGradient>
  </defs>
  <rect width="1200" height="720" fill="url(#bg)"/>
  <text x="600" y="64" fill="#ffffff" font-size="36" font-weight="700" text-anchor="middle" font-family="ui-sans-serif, system-ui, sans-serif">Phoenix Simulation Engine</text>
  <text x="600" y="98" fill="#9aa0a6" font-size="18" text-anchor="middle" font-family="ui-sans-serif, system-ui, sans-serif">PSE · Laboratório headless · época ${seasonComplete ? 'completa' : 'em curso'}</text>

  <rect x="48" y="130" width="270" height="110" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="72" y="168" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">DIAS</text>
  <text x="72" y="210" fill="#ffffff" font-size="40" font-weight="700" font-family="ui-sans-serif, system-ui, sans-serif">$days</text>

  <rect x="338" y="130" width="270" height="110" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="362" y="168" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">JOGOS</text>
  <text x="362" y="210" fill="#ffffff" font-size="40" font-weight="700" font-family="ui-sans-serif, system-ui, sans-serif">$matches</text>

  <rect x="628" y="130" width="270" height="110" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="652" y="168" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">EVENTOS</text>
  <text x="652" y="210" fill="#ffffff" font-size="40" font-weight="700" font-family="ui-sans-serif, system-ui, sans-serif">$events</text>

  <rect x="918" y="130" width="234" height="110" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="942" y="168" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">MATCH ENGINE</text>
  <text x="942" y="210" fill="#81c784" font-size="28" font-weight="700" font-family="ui-sans-serif, system-ui, sans-serif">${durationMs}ms</text>

  <rect x="48" y="268" width="1104" height="180" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="72" y="308" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">EXEMPLO DE PARTIDA · $segments segmentos</text>
  <text x="600" y="370" fill="#ffffff" font-size="32" font-weight="700" text-anchor="middle" font-family="ui-sans-serif, system-ui, sans-serif">${_esc(homeName)}  $homeScore-$awayScore  ${_esc(awayName)}</text>
  <text x="600" y="412" fill="#c5cae9" font-size="18" text-anchor="middle" font-family="ui-sans-serif, system-ui, sans-serif">xG ${homeXg.toStringAsFixed(2)}–${awayXg.toStringAsFixed(2)} · remates $homeShots–$awayShots</text>

  <rect x="48" y="472" width="1104" height="200" rx="16" fill="#1a2332" stroke="#2a3548"/>
  <text x="72" y="508" fill="#9aa0a6" font-size="14" font-family="ui-sans-serif, system-ui, sans-serif">CLASSIFICAÇÃO (topo)</text>
  $standingLines
</svg>
''';
}
