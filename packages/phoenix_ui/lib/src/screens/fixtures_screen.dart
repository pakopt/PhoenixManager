import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
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

class _LeagueList extends StatelessWidget {
  const _LeagueList({
    required this.fixtures,
    required this.session,
    required this.onOpenMatch,
  });

  final List<MatchFixture> fixtures;
  final GameSession session;
  final void Function(MatchFixture fixture) onOpenMatch;

  @override
  Widget build(BuildContext context) {
    if (fixtures.isEmpty) {
      return const EmptyState(
        icon: Icons.calendar_month,
        message: 'Sem jogos de liga agendados.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        final fixture = fixtures[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: FixtureTile(
            fixture: fixture,
            session: session,
            onTap: fixture.isPlayed ? () => onOpenMatch(fixture) : null,
          ),
        );
      },
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
