import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';

/// Linha de calendário / resultado no estilo dashboard FootSim.
class FixtureListTile extends StatelessWidget {
  const FixtureListTile({
    required this.fixture,
    required this.session,
    this.onTap,
    this.dense = false,
    super.key,
  });

  final MatchFixture fixture;
  final GameSession session;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final homeClub = session.registry.getClub(fixture.homeClubId);
    final awayClub = session.registry.getClub(fixture.awayClubId);
    final home = homeClub?.displayShortName ??
        homeClub?.name ??
        session.clubName(fixture.homeClubId);
    final away = awayClub?.displayShortName ??
        awayClub?.name ??
        session.clubName(fixture.awayClubId);
    final isUser = fixture.involvesClub(GameSession.userClubId);
    final played = fixture.isPlayed;
    final competition = session.competitionName(fixture.competitionId);
    final pad = dense ? 10.0 : 12.0;
    final crestSize = dense ? 22.0 : 26.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: played ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: EdgeInsets.symmetric(horizontal: pad, vertical: pad),
          decoration: BoxDecoration(
            color: isUser
                ? PhoenixColors.seed.withValues(alpha: 0.08)
                : PhoenixColors.card.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isUser
                  ? PhoenixColors.seed.withValues(alpha: 0.28)
                  : PhoenixColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  DateFormatUtil.gameDate(fixture.date),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: PhoenixColors.muted,
                      ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (homeClub != null) ...[
                          ClubCrest(
                            club: homeClub,
                            size: crestSize,
                            showBorder: false,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            home,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: isUser
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: PhoenixColors.textPrimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            'vs',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: PhoenixColors.muted),
                          ),
                        ),
                        if (awayClub != null) ...[
                          ClubCrest(
                            club: awayClub,
                            size: crestSize,
                            showBorder: false,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            away,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: isUser
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: PhoenixColors.textPrimary,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      competition,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: PhoenixColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              if (played)
                Text(
                  '${fixture.homeScore}–${fixture.awayScore}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PhoenixColors.textPrimary,
                      ),
                )
              else
                const Icon(
                  Icons.schedule,
                  size: 18,
                  color: PhoenixColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
