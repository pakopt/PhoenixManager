import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phoenix_ui/src/game/simulation_lab_export.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';

class SimulationLabCompareCard extends StatelessWidget {
  const SimulationLabCompareCard({
    required this.runs,
    required this.onClear,
    super.key,
  });

  final List<SimulationLabRunSummary> runs;
  final VoidCallback onClear;

  Future<void> _copyCsv(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: exportSimulationLabCsv(runs)));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CSV copiado para a área de transferência')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Comparar corridas',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Copiar CSV',
                  onPressed: () => _copyCsv(context),
                  icon: const Icon(Icons.copy),
                ),
                TextButton(onPressed: onClear, child: const Text('Limpar')),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Presets')),
                  DataColumn(label: Text('G/J'), numeric: true),
                  DataColumn(label: Text('xG/J'), numeric: true),
                  DataColumn(label: Text('Transf.'), numeric: true),
                  DataColumn(label: Text('Jovens'), numeric: true),
                  DataColumn(label: Text('ms'), numeric: true),
                  DataColumn(label: Text('Campeão')),
                ],
                rows: [
                  for (var i = 0; i < runs.length; i++)
                    DataRow(
                      cells: [
                        DataCell(Text('${i + 1}')),
                        DataCell(
                          SizedBox(
                            width: 120,
                            child: Text(
                              runs[i].presetLabel,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(runs[i].averageGoalsPerMatch.toStringAsFixed(2)),
                        ),
                        DataCell(
                          Text(runs[i].averageXgPerMatch.toStringAsFixed(2)),
                        ),
                        DataCell(Text('${runs[i].transferCount}')),
                        DataCell(Text('${runs[i].youthPlayersGenerated}')),
                        DataCell(Text('${runs[i].elapsedMs}')),
                        DataCell(Text(runs[i].championName ?? '—')),
                      ],
                    ),
                ],
              ),
            ),
            if (runs.length >= 2) ...[
              const SizedBox(height: 8),
              _DeltaSummary(runs: runs),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeltaSummary extends StatelessWidget {
  const _DeltaSummary({required this.runs});

  final List<SimulationLabRunSummary> runs;

  @override
  Widget build(BuildContext context) {
    final best = runs.reduce(
      (a, b) =>
          a.averageGoalsPerMatch >= b.averageGoalsPerMatch ? a : b,
    );
    final worst = runs.reduce(
      (a, b) =>
          a.averageGoalsPerMatch <= b.averageGoalsPerMatch ? a : b,
    );
    final delta = best.averageGoalsPerMatch - worst.averageGoalsPerMatch;

    return Text(
      'Δ G/J: ${delta.toStringAsFixed(2)} (${worst.matchPresetLabel} → ${best.matchPresetLabel})',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
    );
  }
}
