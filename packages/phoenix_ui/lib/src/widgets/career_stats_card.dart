import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/career_stats.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

class CareerStatsCard extends StatelessWidget {
  const CareerStatsCard({
    required this.session,
    this.compact = false,
    super.key,
  });

  final GameSession session;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stats = session.careerStats;
    final theme = Theme.of(context);

    if (stats.played == 0 &&
        stats.leagueTitles == 0 &&
        stats.cupTitles == 0 &&
        compact) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estatísticas de carreira',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (compact)
              _CompactGrid(stats: stats)
            else
              _FullGrid(stats: stats),
          ],
        ),
      ),
    );
  }
}

class _CompactGrid extends StatelessWidget {
  const _CompactGrid({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Jogos', value: '${stats.played}')),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(label: 'Vitórias', value: '${stats.won}')),
        const SizedBox(width: 8),
        Expanded(
          child: _StatBox(
            label: 'Troféus',
            value: '${stats.leagueTitles + stats.cupTitles}',
          ),
        ),
      ],
    );
  }
}

class _FullGrid extends StatelessWidget {
  const _FullGrid({required this.stats});

  final CareerStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Épocas', value: '${stats.seasonsManaged}')),
            const SizedBox(width: 8),
            Expanded(child: _StatBox(label: 'Jogos', value: '${stats.played}')),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                label: 'Vitórias',
                value: '${(stats.winRate * 100).round()}%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _StatBox(label: 'Record', value: stats.recordLabel)),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                label: 'Golos',
                value: '${stats.goalsFor}-${stats.goalsAgainst}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatBox(
                label: 'Troféus',
                value: '${stats.leagueTitles}L ${stats.cupTitles}T',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
