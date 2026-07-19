import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/club_detail_screen.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';
import 'package:phoenix_ui/src/widgets/cup_bracket_panel.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

/// Número de clubes na zona de despromoção (estilo FootSim).
int standingsRelegationCount(int tableSize) {
  if (tableSize >= 20) return 4;
  if (tableSize >= 16) return 3;
  if (tableSize >= 10) return 2;
  return 0;
}

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({required this.session, super.key});

  final GameSession session;

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final isLeague = _tabIndex == 0;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ScreenPageHeader(
            title: 'Classificação',
            subtitle: 'Liga Phoenix e Taça',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Liga')),
                ButtonSegment(value: 1, label: Text('Taça')),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (selection) {
                setState(() => _tabIndex = selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: isLeague
                ? _LeagueTable(session: session)
                : _CupStandings(
                    session: session,
                    onOpenMatch: (fixture) =>
                        _openMatch(context, session, fixture),
                  ),
          ),
        ],
      ),
    );
  }

  void _openMatch(
    BuildContext context,
    GameSession session,
    MatchFixture fixture,
  ) {
    final result = session.registry.matchResults[fixture.id];
    if (result == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MatchDetailScreen(
          session: session,
          output: MatchSimulationOutput(fixture: fixture, result: result),
        ),
      ),
    );
  }
}

class _LeagueTable extends StatefulWidget {
  const _LeagueTable({required this.session});

  final GameSession session;

  @override
  State<_LeagueTable> createState() => _LeagueTableState();
}

class _LeagueTableState extends State<_LeagueTable> {
  final _userRowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToUser());
  }

  void _scrollToUser() {
    final ctx = _userRowKey.currentContext;
    if (ctx == null) {
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.35,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final table = session.standings;
    if (table.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        message: 'Sem dados de classificação.',
      );
    }

    final userIndex = table.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );
    final relegationCount = standingsRelegationCount(table.length);
    final relegationFrom = relegationCount == 0
        ? table.length
        : table.length - relegationCount;

    final userEntry = userIndex >= 0 ? table[userIndex] : null;
    final userSummary = userEntry == null
        ? null
        : '${userIndex + 1}.º lugar · ${userEntry.points} pts · '
            '${userEntry.played} jogos';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _LeagueHeaderCard(
          leagueName: 'Liga Phoenix',
          userSummary: userSummary,
        ),
        const SizedBox(height: 12),
        if (relegationCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: PhoenixColors.negative,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Despromoção',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: PhoenixColors.negative,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const minTableWidth = 560.0;
              final tableWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TableHeader(),
                      const Divider(height: 1, color: PhoenixColors.cardBorder),
                      for (var index = 0; index < table.length; index++) ...[
                        if (index == relegationFrom && relegationCount > 0)
                          Container(
                            height: 2,
                            color:
                                PhoenixColors.negative.withValues(alpha: 0.85),
                          ),
                        KeyedSubtree(
                          key: index == userIndex
                              ? _userRowKey
                              : ValueKey(index),
                          child: _StandingRow(
                            position: index + 1,
                            entry: table[index],
                            session: session,
                            isUser: table[index].clubId ==
                                GameSession.userClubId,
                            inRelegation: index >= relegationFrom,
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                        child: Text(
                          'A mostrar 1–${table.length} de ${table.length} clubes',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PhoenixColors.muted,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LeagueHeaderCard extends StatelessWidget {
  const _LeagueHeaderCard({
    required this.leagueName,
    this.userSummary,
  });

  final String leagueName;
  final String? userSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFF42A5F5),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leagueName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PhoenixColors.negative.withValues(alpha: 0.95),
                        ),
                  ),
                  if (userSummary != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      userSummary!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: PhoenixColors.muted,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: PhoenixColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: PhoenixColors.muted,
          letterSpacing: 0.3,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: style)),
          Expanded(flex: 5, child: Text('CLUBE', style: style)),
          _StatCell('J', style: style),
          _StatCell('V', style: style),
          _StatCell('E', style: style),
          _StatCell('D', style: style),
          _StatCell('GM', style: style),
          _StatCell('GS', style: style),
          _StatCell('DG', style: style),
          _StatCell('PTS', style: style, bold: true),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.position,
    required this.entry,
    required this.session,
    required this.isUser,
    required this.inRelegation,
  });

  final int position;
  final StandingEntry entry;
  final GameSession session;
  final bool isUser;
  final bool inRelegation;

  @override
  Widget build(BuildContext context) {
    final club = session.registry.getClub(entry.clubId);
    final clubName =
        club?.displayShortName ?? club?.name ?? entry.clubId.value;
    final gdSign = entry.goalDifference >= 0 ? '+' : '';
    final highlight = isUser
        ? PhoenixColors.negative.withValues(alpha: 0.14)
        : Colors.transparent;
    final accent = isUser
        ? PhoenixColors.negative
        : (inRelegation ? PhoenixColors.negative : PhoenixColors.textPrimary);
    final mutedAccent = isUser
        ? PhoenixColors.negative.withValues(alpha: 0.85)
        : PhoenixColors.textSecondary;

    return Material(
      color: highlight,
      child: InkWell(
        onTap: () => ClubDetailScreen.open(
          context,
          session: session,
          clubId: entry.clubId,
        ),
        child: Semantics(
          button: true,
          label:
              '$position. $clubName — ${entry.played} jogos, ${entry.points} pontos, '
              'diferença $gdSign${entry.goalDifference}. Abrir ficha do clube.',
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '$position',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isUser || inRelegation
                          ? PhoenixColors.negative
                          : PhoenixColors.muted,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Row(
                    children: [
                      if (club != null) ...[
                        ClubCrest(
                          club: club,
                          size: 22,
                          showBorder: false,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          clubName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isUser ? FontWeight.w700 : FontWeight.w500,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatCell('${entry.played}', color: mutedAccent),
                _StatCell('${entry.won}', color: mutedAccent),
                _StatCell('${entry.drawn}', color: mutedAccent),
                _StatCell('${entry.lost}', color: mutedAccent),
                _StatCell('${entry.goalsFor}', color: mutedAccent),
                _StatCell('${entry.goalsAgainst}', color: mutedAccent),
                _StatCell(
                  '$gdSign${entry.goalDifference}',
                  color: mutedAccent,
                ),
                _StatCell(
                  '${entry.points}',
                  color: accent,
                  bold: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell(
    this.text, {
    this.style,
    this.color,
    this.bold = false,
  });

  final String text;
  final TextStyle? style;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style ??
            TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: color ?? PhoenixColors.textSecondary,
            ),
      ),
    );
  }
}

class _CupStandings extends StatelessWidget {
  const _CupStandings({
    required this.session,
    required this.onOpenMatch,
  });

  final GameSession session;
  final void Function(MatchFixture fixture) onOpenMatch;

  @override
  Widget build(BuildContext context) {
    final bracket = session.cupBracket;

    if (bracket.semiFinals.isEmpty) {
      return const EmptyState(
        icon: Icons.emoji_events_outlined,
        message: 'Sem jogos de taça agendados.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        if (session.isCupComplete && session.cupWinner != null)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.emoji_events,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Campeão'),
              subtitle: Text(session.clubName(session.cupWinner!)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => ClubDetailScreen.open(
                context,
                session: session,
                clubId: session.cupWinner!,
              ),
            ),
          ),
        const SizedBox(height: 8),
        CupBracketPanel(
          session: session,
          bracket: bracket,
          onMatchTap: onOpenMatch,
        ),
      ],
    );
  }
}
