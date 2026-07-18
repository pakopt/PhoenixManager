import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';

/// Banner do próximo jogo (centro do dashboard).
class MatchDayHero extends StatelessWidget {
  const MatchDayHero({
    required this.session,
    this.onGoToMatch,
    this.ctaLabel,
    super.key,
  });

  final GameSession session;
  final VoidCallback? onGoToMatch;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    final next = session.nextFixture;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PhoenixColors.heroGradientStart,
            PhoenixColors.heroGradientEnd,
          ],
        ),
        border: Border.all(
          color: PhoenixColors.seed.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: next == null
            ? _EmptySeason(session: session)
            : _MatchContent(
                session: session,
                onGoToMatch: onGoToMatch,
                ctaLabel: ctaLabel,
              ),
      ),
    );
  }
}

class _EmptySeason extends StatelessWidget {
  const _EmptySeason({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final message = session.isFullSeasonComplete
        ? 'Época concluída (liga e taça)'
        : session.isSeasonComplete
            ? 'Liga concluída · taça em curso'
            : 'Sem jogos agendados';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MATCH DAY',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: PhoenixColors.positive,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _MatchContent extends StatelessWidget {
  const _MatchContent({
    required this.session,
    this.onGoToMatch,
    this.ctaLabel,
  });

  final GameSession session;
  final VoidCallback? onGoToMatch;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    final next = session.nextFixture!;
    final homeClub = session.registry.getClub(next.homeClubId);
    final awayClub = session.registry.getClub(next.awayClubId);
    final home = homeClub?.displayShortName ??
        homeClub?.name ??
        session.clubName(next.homeClubId);
    final away = awayClub?.displayShortName ??
        awayClub?.name ??
        session.clubName(next.awayClubId);
    final competition = session.competitionName(next.competitionId);
    final cupSuffix = next.competitionId == GameSession.cupCompetitionId
        ? ' · ${session.cupRoundLabel(next)}'
        : '';
    final isHome = next.homeClubId == GameSession.userClubId;
    final opponent = isHome ? away : home;
    final venue = isHome ? 'Casa' : 'Fora';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'PRÓXIMO JOGO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PhoenixColors.positive,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PhoenixColors.seed.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                venue,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PhoenixColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          competition + cupSuffix,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PhoenixColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _ClubSide(
                club: homeClub,
                name: home,
                crestFirst: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'vs',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PhoenixColors.muted,
                    ),
              ),
            ),
            Expanded(
              child: _ClubSide(
                club: awayClub,
                name: away,
                crestFirst: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'vs $opponent · ${DateFormatUtil.gameDate(next.date)}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PhoenixColors.muted,
              ),
        ),
        if (onGoToMatch != null) ...[
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onGoToMatch,
              icon: const Icon(Icons.sports_soccer),
              label: Text(ctaLabel ?? 'Ir ao jogo'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ClubSide extends StatelessWidget {
  const _ClubSide({
    required this.club,
    required this.name,
    required this.crestFirst,
  });

  final Club? club;
  final String name;
  /// `true` = emblema à esquerda do nome (casa); `false` = emblema à direita (fora).
  final bool crestFirst;

  static const _crestSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final crest = club == null
        ? null
        : ClubCrest(club: club!, size: _crestSize, showBorder: true);

    final nameText = Flexible(
      child: Text(
        name,
        textAlign: crestFirst ? TextAlign.left : TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: PhoenixColors.textPrimary,
              height: 1.15,
            ),
      ),
    );

    final gap = crest == null ? const SizedBox.shrink() : const SizedBox(width: 12);

    return Row(
      mainAxisAlignment:
          crestFirst ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: crestFirst
          ? [
              if (crest != null) crest,
              gap,
              nameText,
            ]
          : [
              nameText,
              gap,
              if (crest != null) crest,
            ],
    );
  }
}
