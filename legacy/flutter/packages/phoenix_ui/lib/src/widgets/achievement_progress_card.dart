import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

class AchievementProgressCard extends StatelessWidget {
  const AchievementProgressCard({
    required this.session,
    this.onTap,
    super.key,
  });

  final GameSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = session.unlockedAchievementCount;
    final total = session.achievementEntries.length;
    final progress = total == 0 ? 0.0 : unlocked / total;

    if (unlocked == 0 && onTap == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.military_tech, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Conquistas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$unlocked/$total',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
              if (onTap != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Ver todas no ecrã Clube',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
