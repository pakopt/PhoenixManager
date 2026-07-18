import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/club_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

/// Mini classificação centrada no clube do utilizador.
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
      return const SectionCard(
        title: 'Classificação',
        child: Text('Sem dados de tabela.'),
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

    return SectionCard(
      title: 'Classificação',
      trailing: onOpenFull == null
          ? null
          : TextButton(
              onPressed: onOpenFull,
              child: const Text('Ver'),
            ),
      child: Column(
        children: [
          for (var i = 0; i < slice.length; i++)
            _Row(
              position: start + i + 1,
              club: session.registry.getClub(slice[i].clubId),
              clubName: session.clubName(slice[i].clubId),
              points: slice[i].points,
              played: slice[i].played,
              isUser: slice[i].clubId == GameSession.userClubId,
              onTap: () => ClubDetailScreen.open(
                context,
                session: session,
                clubId: slice[i].clubId,
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.position,
    required this.club,
    required this.clubName,
    required this.points,
    required this.played,
    required this.isUser,
    required this.onTap,
  });

  final int position;
  final Club? club;
  final String clubName;
  final int points;
  final int played;
  final bool isUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = club?.displayShortName ?? clubName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isUser
                ? PhoenixColors.seed.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$position',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isUser ? PhoenixColors.positive : PhoenixColors.muted,
                  ),
                ),
              ),
              if (club != null) ...[
                ClubCrest(club: club!, size: 22, showBorder: false),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
                    color: PhoenixColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$played J',
                style: const TextStyle(
                  fontSize: 11,
                  color: PhoenixColors.muted,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$points',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color:
                      isUser ? PhoenixColors.positive : PhoenixColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
