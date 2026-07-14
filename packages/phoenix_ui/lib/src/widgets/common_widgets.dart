import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';

class ClubHeader extends StatelessWidget {
  const ClubHeader({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final club = session.userClub;
    final finance = session.userFinance;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.cardTheme.color ?? theme.colorScheme.surface,
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                club.name.characters.first,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${DateFormatUtil.gameDate(session.currentDate)} · '
                    'Jornada ${session.tick}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (finance != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormat.compact(finance.balance),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Orçamento',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({
    required this.label,
    required this.value,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FixtureTile extends StatelessWidget {
  const FixtureTile({
    required this.fixture,
    required this.session,
    this.onTap,
    this.roundLabel,
    super.key,
  });

  final MatchFixture fixture;
  final GameSession session;
  final VoidCallback? onTap;
  final String? roundLabel;

  @override
  Widget build(BuildContext context) {
    final home = session.clubName(fixture.homeClubId);
    final away = session.clubName(fixture.awayClubId);
    final isUserMatch = fixture.involvesClub(GameSession.userClubId);
    final played = fixture.isPlayed;

    return Card(
      color: isUserMatch
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: ListTile(
        onTap: played ? onTap : null,
        leading: Text(
          DateFormatUtil.gameDate(fixture.date),
          style: Theme.of(context).textTheme.labelMedium,
        ),
        title: Text('$home vs $away'),
        subtitle: roundLabel != null ? Text(roundLabel!) : null,
        trailing: played
            ? Text(
                '${fixture.homeScore} - ${fixture.awayScore}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : const Icon(Icons.schedule, size: 18),
      ),
    );
  }
}
