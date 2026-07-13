import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:phoenix_ui/src/widgets/common_widgets.dart';
import 'package:phoenix_ui/src/widgets/cup_bracket_panel.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

class FixturesScreen extends StatefulWidget {
  const FixturesScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<FixturesScreen> createState() => _FixturesScreenState();
}

class _FixturesScreenState extends State<FixturesScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final isLeague = _tabIndex == 0;
    final fixtures =
        isLeague ? session.leagueFixtures : session.cupFixtures;
    final title =
        isLeague ? 'Liga Phoenix' : 'Taça Phoenix';

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Calendário',
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
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: isLeague
                ? _LeagueList(
                    key: ValueKey('league-$_tabIndex'),
                    fixtures: fixtures,
                    session: session,
                    onOpenMatch: (f) => _openMatch(context, session, f),
                  )
                : _CupView(
                    session: session,
                    onOpenMatch: (f) => _openMatch(context, session, f),
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

class _LeagueList extends StatefulWidget {
  const _LeagueList({
    super.key,
    required this.fixtures,
    required this.session,
    required this.onOpenMatch,
  });

  final List<MatchFixture> fixtures;
  final GameSession session;
  final void Function(MatchFixture fixture) onOpenMatch;

  @override
  State<_LeagueList> createState() => _LeagueListState();
}

class _LeagueListState extends State<_LeagueList> {
  var _onlyMine = false;
  final _nextFixtureKey = GlobalKey();

  List<MatchFixture> get _visibleFixtures {
    if (!_onlyMine) {
      return widget.fixtures;
    }
    return widget.fixtures
        .where((f) => f.involvesClub(GameSession.userClubId))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNext());
  }

  @override
  void didUpdateWidget(covariant _LeagueList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fixtures != widget.fixtures) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNext());
    }
  }

  void _scrollToNext() {
    final ctx = _nextFixtureKey.currentContext;
    if (ctx == null) {
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.25,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixtures = _visibleFixtures;

    if (widget.fixtures.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_month,
        message: 'Sem jogos de liga agendados.',
      );
    }

    final nextUnplayedIdx = fixtures.indexWhere((f) => !f.isPlayed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: FilterChip(
            label: Text(
              _onlyMine
                  ? 'Só os meus jogos (${fixtures.length})'
                  : 'Só os meus jogos',
            ),
            selected: _onlyMine,
            onSelected: (selected) {
              setState(() => _onlyMine = selected);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToNext();
              });
            },
          ),
        ),
        if (_onlyMine && fixtures.isEmpty)
          const Expanded(
            child: EmptyState(
              icon: Icons.filter_alt_off,
              message: 'Nenhum jogo teu nesta competição.',
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: fixtures.length,
              itemBuilder: (context, index) {
                final fixture = fixtures[index];
                final tile = Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FixtureTile(
                    fixture: fixture,
                    session: widget.session,
                    onTap: fixture.isPlayed
                        ? () => widget.onOpenMatch(fixture)
                        : null,
                  ),
                );
                if (index == nextUnplayedIdx) {
                  return KeyedSubtree(key: _nextFixtureKey, child: tile);
                }
                return tile;
              },
            ),
          ),
      ],
    );
  }
}

class _CupView extends StatelessWidget {
  const _CupView({
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
        CupBracketPanel(
          session: session,
          bracket: bracket,
          onMatchTap: onOpenMatch,
        ),
      ],
    );
  }
}
