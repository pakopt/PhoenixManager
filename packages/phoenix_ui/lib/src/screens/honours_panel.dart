import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/season_honour.dart';

class HonoursPanel extends StatelessWidget {
  const HonoursPanel({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final entries = session.seasonHonoursEntries;
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Palmarés', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${session.leagueTitlesWon} ligas · ${session.cupTitlesWon} taças',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ainda sem troféus',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vence a Liga ou a Taça Phoenix para entrar no palmarés.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _HonourSeasonCard(entry: entry),
              ),
            ),
        ],
      ),
    );
  }
}

class _HonourSeasonCard extends StatelessWidget {
  const _HonourSeasonCard({required this.entry});

  final SeasonHonourEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: entry.isDouble
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Época ${entry.seasonYear}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.isDouble) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Dobradinha'),
                    visualDensity: VisualDensity.compact,
                    avatar: Icon(
                      Icons.star,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.labels.map((label) {
                final isCup = label.contains('Taça');
                return Chip(
                  avatar: Icon(
                    isCup ? Icons.emoji_events : Icons.leaderboard,
                    size: 16,
                  ),
                  label: Text(label),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
