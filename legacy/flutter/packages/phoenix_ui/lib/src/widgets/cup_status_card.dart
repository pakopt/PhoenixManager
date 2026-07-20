import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/cup_bracket_snapshot.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';

class CupStatusCard extends StatelessWidget {
  const CupStatusCard({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bracket = session.cupBracket;
    final champion = session.cupWinner;
    final next = session.nextCupFixture;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  session.competitionName(GameSession.cupCompetitionId),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (champion != null)
              _ChampionRow(session: session, championId: champion)
            else if (next != null)
              _NextCupMatchRow(session: session, fixture: next)
            else if (session.isUserEliminatedFromCup)
              _EliminatedRow(session: session)
            else
              _ProgressRow(session: session, bracket: bracket),
          ],
        ),
      ),
    );
  }
}

class _ChampionRow extends StatelessWidget {
  const _ChampionRow({
    required this.session,
    required this.championId,
  });

  final GameSession session;
  final ClubId championId;

  @override
  Widget build(BuildContext context) {
    final isUser = championId == GameSession.userClubId;
    final club = session.registry.getClub(championId);
    final name = club?.displayShortName ?? session.clubName(championId);
    return Row(
      children: [
        Icon(
          Icons.emoji_events,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        if (club != null) ...[
          ClubCrest(club: club, size: 28, showBorder: false),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'Campeões da Taça!' : 'Taça concluída',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        if (isUser)
          const Chip(
            label: Text('Título'),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }
}

class _NextCupMatchRow extends StatelessWidget {
  const _NextCupMatchRow({
    required this.session,
    required this.fixture,
  });

  final GameSession session;
  final MatchFixture fixture;

  @override
  Widget build(BuildContext context) {
    final round = session.cupRoundLabel(fixture);
    final homeClub = session.registry.getClub(fixture.homeClubId);
    final awayClub = session.registry.getClub(fixture.awayClubId);
    final home =
        homeClub?.displayShortName ?? session.clubName(fixture.homeClubId);
    final away =
        awayClub?.displayShortName ?? session.clubName(fixture.awayClubId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Próximo jogo · $round',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (homeClub != null) ...[
              ClubCrest(club: homeClub, size: 24, showBorder: false),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                home,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'vs',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
            if (awayClub != null) ...[
              ClubCrest(club: awayClub, size: 24, showBorder: false),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                away,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatUtil.gameDate(fixture.date),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}

class _EliminatedRow extends StatelessWidget {
  const _EliminatedRow({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finalMatch = session.cupBracket.finalMatch;
    final waitingFinal = finalMatch != null &&
        !finalMatch.isPlayed &&
        !finalMatch.fixture.involvesClub(GameSession.userClubId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.block, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 8),
            Text(
              'Eliminados',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          waitingFinal
              ? 'A aguardar a final da taça.'
              : 'Época de taça terminada para o clube.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.session,
    required this.bracket,
  });

  final GameSession session;
  final CupBracketSnapshot bracket;

  @override
  Widget build(BuildContext context) {
    if (bracket.semiFinals.isEmpty && bracket.finalMatch == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Taça por sortear',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'O sorteio das eliminatórias ainda não foi feito.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    final playedSemis = bracket.semiFinals.where((s) => s.isPlayed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bracket.hasFinal ? 'Final agendada' : 'Meias-finais ($playedSemis/2)',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        ...bracket.semiFinals.map(
          (slot) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _MatchLine(session: session, slot: slot),
          ),
        ),
        if (bracket.finalMatch != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _MatchLine(
              session: session,
              slot: bracket.finalMatch!,
              label: 'Final',
            ),
          ),
      ],
    );
  }
}

class _MatchLine extends StatelessWidget {
  const _MatchLine({
    required this.session,
    required this.slot,
    this.label,
  });

  final GameSession session;
  final CupMatchSlot slot;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final fixture = slot.fixture;
    final roundLabel = label ?? session.cupRoundLabel(fixture);
    final home = session.clubName(fixture.homeClubId);
    final away = session.clubName(fixture.awayClubId);

    final text = slot.isPlayed
        ? '$roundLabel · $home ${fixture.homeScore}-${fixture.awayScore} $away'
        : '$roundLabel · $home vs $away · ${DateFormatUtil.gameDate(fixture.date)}';

    return Text(text, style: Theme.of(context).textTheme.bodySmall);
  }
}
