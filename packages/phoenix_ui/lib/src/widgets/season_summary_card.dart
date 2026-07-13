import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/game/season_summary.dart';
import 'package:phoenix_ui/src/game/season_honour.dart';

class SeasonSummaryCard extends StatelessWidget {
  const SeasonSummaryCard({
    required this.session,
    required this.summary,
    super.key,
  });

  final GameSession session;
  final SeasonSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = summary.leagueEntry;
    final finance = summary.finance;

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_circle,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    summary.isFullyComplete
                        ? 'Resumo da época ${summary.seasonYear}'
                        : 'Época ${summary.seasonYear} · parcial',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (summary.isFullyComplete)
                  Chip(
                    label: const Text('Concluída'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              icon: Icons.leaderboard,
              label: 'Liga Phoenix',
              value:
                  '${summary.leaguePosition}º · ${entry.points} pts · '
                  '${entry.won}V ${entry.drawn}E ${entry.lost}D · '
                  'DG ${entry.goalDifference >= 0 ? '+' : ''}${entry.goalDifference}',
            ),
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.emoji_events_outlined,
              label: 'Taça Phoenix',
              value: _cupLine(session),
            ),
            if (summary.honoursThisSeason.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                icon: Icons.emoji_events,
                label: 'Troféus',
                value: summary.honoursThisSeason
                    .map(SeasonHonourLabels.label)
                    .join(' · '),
              ),
            ],
            if (finance != null) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Finanças',
                value:
                    'Saldo ${MoneyFormat.compact(finance.balance)} · '
                    'Receitas ${MoneyFormat.compact(finance.seasonRevenue)} · '
                    'Despesas ${MoneyFormat.compact(finance.seasonExpenses)}',
              ),
            ],
            if (summary.youthIntakeCount > 0) ...[
              const SizedBox(height: 8),
              _SummaryRow(
                icon: Icons.school_outlined,
                label: 'Academia',
                value: '${summary.youthIntakeCount} jovens integrados',
              ),
            ],
            if (summary.achievementsThisSeason.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Conquistas (${summary.achievementsThisSeason.length})',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: summary.achievementsThisSeason.map((unlocked) {
                  final title =
                      session.achievementTitle(unlocked.id);
                  return Chip(
                    label: Text(title),
                    avatar: const Icon(Icons.military_tech, size: 16),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _cupLine(GameSession session) {
    final outcome = summary.cupOutcomeLabel(session);
    if (summary.cupWinnerId != null &&
        summary.cupOutcome != CupSeasonOutcome.champion) {
      return '$outcome · Campeão: ${session.clubName(summary.cupWinnerId!)}';
    }
    return outcome;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(value, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
