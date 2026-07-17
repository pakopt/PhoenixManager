import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/achievement_entry.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/util/date_format.dart';

class AchievementsPanel extends StatelessWidget {
  const AchievementsPanel({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final entries = List<AchievementEntry>.from(session.achievementEntries)
      ..sort((a, b) {
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return a.definition.title.compareTo(b.definition.title);
      });
    final unlocked = session.unlockedAchievementCount;
    final total = entries.length;
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Conquistas', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$unlocked de $total desbloqueadas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: total == 0 ? 0 : unlocked / total,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 16),
          ...entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AchievementTile(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.entry});

  final AchievementEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = entry.isUnlocked;

    return Semantics(
      label: unlocked
          ? '${entry.definition.title}, desbloqueada'
          : '${entry.definition.title}, por desbloquear',
      child: Card(
        color:
            unlocked ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: unlocked
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              unlocked ? Icons.check : Icons.lock_outline,
              color: unlocked ? Colors.white : theme.colorScheme.outline,
              size: 20,
            ),
          ),
          title: Text(
            entry.definition.title,
            style: TextStyle(
              fontWeight: unlocked ? FontWeight.w600 : FontWeight.normal,
              color: unlocked
                  ? null
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.definition.description),
              if (unlocked)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Desbloqueada · ${DateFormatUtil.gameDate(entry.unlocked!.unlockedOn)} · '
                    'Época ${entry.unlocked!.seasonYear}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Por desbloquear',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
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
