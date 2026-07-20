import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/club_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';

/// Mini classificação estilo FootSim — cartão com resumo + # / Clube / J / DG / Pts.
class MiniStandings extends StatelessWidget {
  const MiniStandings({
    required this.session,
    this.radius = 2,
    this.onOpenFull,
    super.key,
  });

  final GameSession session;
  final int radius;
  final VoidCallback? onOpenFull;

  @override
  Widget build(BuildContext context) {
    final standings = session.standings;
    if (standings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Sem dados de tabela.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PhoenixColors.muted,
                ),
          ),
        ),
      );
    }

    final userIndex = standings.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );
    final start = userIndex < 0
        ? 0
        : (userIndex - radius).clamp(0, standings.length - 1);
    final end = userIndex < 0
        ? (radius * 2 + 1).clamp(0, standings.length)
        : (userIndex + radius + 1).clamp(0, standings.length);
    final slice = standings.sublist(start, end);

    final userEntry = userIndex >= 0 ? standings[userIndex] : null;
    final summary = userEntry == null
        ? null
        : '${userIndex + 1}.º lugar · ${userEntry.points} pts · '
            '${userEntry.played} jogos';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpenFull,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E88E5).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF42A5F5),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Liga Phoenix',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: PhoenixColors.negative
                                        .withValues(alpha: 0.95),
                                  ),
                        ),
                        if (summary != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            summary,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: PhoenixColors.muted,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onOpenFull != null)
                    const Icon(Icons.chevron_right, color: PhoenixColors.muted),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: PhoenixColors.cardBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '#',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PhoenixColors.muted,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'CLUBE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: PhoenixColors.muted,
                        ),
                  ),
                ),
                _MiniStat('J'),
                _MiniStat('DG'),
                _MiniStat('PTS'),
              ],
            ),
          ),
          for (var i = 0; i < slice.length; i++)
            _MiniRow(
              position: start + i + 1,
              club: session.registry.getClub(slice[i].clubId),
              clubName: session.clubName(slice[i].clubId),
              points: slice[i].points,
              played: slice[i].played,
              goalDifference: slice[i].goalDifference,
              isUser: slice[i].clubId == GameSession.userClubId,
              onTap: () => ClubDetailScreen.open(
                context,
                session: session,
                clubId: slice[i].clubId,
              ),
            ),
          if (onOpenFull != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOpenFull,
                child: const Text('Ver tabela'),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: PhoenixColors.muted,
            ),
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({
    required this.position,
    required this.club,
    required this.clubName,
    required this.points,
    required this.played,
    required this.goalDifference,
    required this.isUser,
    required this.onTap,
  });

  final int position;
  final Club? club;
  final String clubName;
  final int points;
  final int played;
  final int goalDifference;
  final bool isUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = club?.displayShortName ?? clubName;
    final gdSign = goalDifference >= 0 ? '+' : '';
    final accent =
        isUser ? PhoenixColors.negative : PhoenixColors.textPrimary;

    return Material(
      color: isUser
          ? PhoenixColors.negative.withValues(alpha: 0.14)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isUser ? PhoenixColors.negative : PhoenixColors.muted,
                  ),
                ),
              ),
              if (club != null) ...[
                ClubCrest(club: club!, size: 20, showBorder: false),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
                    color: accent,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$played',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser
                        ? PhoenixColors.negative.withValues(alpha: 0.85)
                        : PhoenixColors.muted,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$gdSign$goalDifference',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isUser
                        ? PhoenixColors.negative.withValues(alpha: 0.85)
                        : PhoenixColors.muted,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '$points',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
