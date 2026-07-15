import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:phoenix_ui/src/widgets/cup_bracket_panel.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Classificação',
              style: Theme.of(context).textTheme.titleLarge,
            ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              isLeague ? 'Liga Phoenix' : 'Taça Phoenix',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: isLeague
                ? _LeagueTable(session: session)
                : _CupStandings(
                    session: session,
                    onOpenMatch: (fixture) => _openMatch(context, session, fixture),
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
    final userIndex = table.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              SizedBox(
                width: 28,
                child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                flex: 4,
                child: Text('Clube', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text('J', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Text('DG', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const Divider(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: table.length,
            itemBuilder: (context, index) {
              final entry = table[index];
              final club = session.registry.getClub(entry.clubId);
              final isUser = entry.clubId == GameSession.userClubId;
              final played = entry.won + entry.drawn + entry.lost;

              final clubName = club?.name ?? entry.clubId.value;
              final gdSign = entry.goalDifference >= 0 ? '+' : '';
              final row = Semantics(
                label:
                    '${index + 1}. $clubName — $played jogos, ${entry.points} pontos, '
                    'diferença $gdSign${entry.goalDifference}',
                excludeSemantics: true,
                child: Container(
                  color: isUser
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : null,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text('${index + 1}'),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          clubName,
                          style: TextStyle(
                            fontWeight:
                                isUser ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text('$played', textAlign: TextAlign.center),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.points}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '$gdSign${entry.goalDifference}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (index == userIndex) {
                return KeyedSubtree(key: _userRowKey, child: row);
              }
              return row;
            },
          ),
        ),
      ],
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
