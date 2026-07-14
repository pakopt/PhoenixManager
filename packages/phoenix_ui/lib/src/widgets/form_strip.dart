import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/recent_form.dart';
import 'package:phoenix_ui/src/util/date_format.dart';

class FormStrip extends StatelessWidget {
  const FormStrip({
    required this.session,
    this.limit = 5,
    super.key,
  });

  final GameSession session;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final entries = session.recentForm(limit: limit);
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Forma recente',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final entry in entries.reversed)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FormBadge(outcome: entry.outcome),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...entries.map(
              (entry) => _ResultRow(session: session, entry: entry),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormBadge extends StatelessWidget {
  const _FormBadge({required this.outcome});

  final MatchOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (outcome) {
      MatchOutcome.win => (Colors.green.shade700, 'V'),
      MatchOutcome.draw => (Colors.orange.shade800, 'E'),
      MatchOutcome.loss => (Colors.red.shade700, 'D'),
    };

    return CircleAvatar(
      radius: 14,
      backgroundColor: color,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.session, required this.entry});

  final GameSession session;
  final RecentFormEntry entry;

  @override
  Widget build(BuildContext context) {
    final fixture = entry.fixture;
    final home = session.clubName(fixture.homeClubId);
    final away = session.clubName(fixture.awayClubId);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          _FormBadge(outcome: entry.outcome),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$home ${fixture.homeScore}-${fixture.awayScore} $away',
              style: theme.textTheme.bodySmall,
            ),
          ),
          Text(
            DateFormatUtil.gameDate(fixture.date),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
