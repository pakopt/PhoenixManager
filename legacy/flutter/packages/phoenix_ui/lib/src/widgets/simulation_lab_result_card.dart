import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';

class SimulationLabResultCard extends StatelessWidget {
  const SimulationLabResultCard({required this.report, super.key});

  final SimulationLabReport report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = report.result;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Resultados',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${report.elapsedMs} ms'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text('xG: ${report.matchPresetLabel}'),
                  visualDensity: VisualDensity.compact,
                ),
                Chip(
                  label: Text('Eco: ${report.economyPresetLabel}'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label: 'Dias',
                  value: '${result.daysSimulated}',
                ),
                _MetricChip(
                  label: 'Jogos',
                  value: '${result.matchesPlayed}',
                ),
                _MetricChip(
                  label: 'Eventos',
                  value: '${result.eventsPublished}',
                ),
                _MetricChip(
                  label: 'Transferências',
                  value: '${report.transferCount}',
                ),
                _MetricChip(
                  label: 'Jovens',
                  value: '${report.youthPlayersGenerated}',
                ),
                _MetricChip(
                  label: 'Plantéis',
                  value: '${report.totalPlayers}',
                ),
                _MetricChip(
                  label: 'Golos',
                  value: '${report.totalGoals}',
                ),
                _MetricChip(
                  label: 'G/J',
                  value: report.averageGoalsPerMatch.toStringAsFixed(2),
                ),
                _MetricChip(
                  label: 'xG/J',
                  value: report.averageXgPerMatch.toStringAsFixed(2),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${result.startDate} → ${result.endDate}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (result.seasonComplete) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Época da liga concluída',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (report.standings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Classificação', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...report.standings.map(
                (row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${row.position}.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                      Expanded(child: Text(row.clubName)),
                      Text(
                        '${row.points} pts',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${row.won}V ${row.drawn}E ${row.lost}D',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (report.finances.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Finanças', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ...report.finances.map(
                (row) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(row.clubName),
                  subtitle: Text(
                    'Receita ${MoneyFormat.compact(row.seasonRevenue)} · '
                    'Despesas ${MoneyFormat.compact(row.seasonExpenses)}',
                  ),
                  trailing: Text(
                    MoneyFormat.compact(row.balance),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            if (report.transfers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Transferências (amostra)',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              ...report.transfers.map(
                (row) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    row.isFree ? Icons.person_off : Icons.swap_horiz,
                    size: 20,
                  ),
                  title: Text(row.playerName),
                  subtitle: Text('→ ${row.toClubName}'),
                  trailing: Text(
                    row.isFree ? 'Livre' : MoneyFormat.compact(row.fee),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}
