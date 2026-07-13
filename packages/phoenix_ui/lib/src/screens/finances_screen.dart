import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/widgets/common_widgets.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final finance = session.userFinance;
    final breakdown = session.salaryBreakdown;
    final transfers = session.clubTransfers;
    final ffpLimit = session.context.economyConfig.finance.ffpWageRatioLimit;
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Finanças', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (finance != null) ...[
            Row(
              children: [
                StatChip(
                  label: 'Saldo',
                  value: MoneyFormat.compact(finance.balance),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                StatChip(
                  label: 'Salários/mês',
                  value: MoneyFormat.compact(finance.monthlyWages),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatChip(
                  label: 'Receita época',
                  value: MoneyFormat.compact(finance.seasonRevenue),
                ),
                const SizedBox(width: 8),
                StatChip(
                  label: 'Despesas época',
                  value: MoneyFormat.compact(finance.seasonExpenses),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Despesas salariais mensais',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.squad.length} jogadores · '
                      '${session.userStaff.length} staff · '
                      '${session.userCoach != null ? '1 treinador' : 'sem treinador'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SalaryRow(
                      label: 'Jogadores',
                      amount: breakdown.players,
                      total: breakdown.total,
                      color: theme.colorScheme.primary,
                    ),
                    _SalaryRow(
                      label: 'Staff',
                      amount: breakdown.staff,
                      total: breakdown.total,
                      color: theme.colorScheme.secondary,
                    ),
                    _SalaryRow(
                      label: 'Treinador',
                      amount: breakdown.coach,
                      total: breakdown.total,
                      color: theme.colorScheme.tertiary,
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total mensal',
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          MoneyFormat.compact(breakdown.total),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Rácio salarial / receita (FFP)'),
                subtitle: Text(
                  '${(finance.wageToRevenueRatio * 100).toStringAsFixed(1)}% '
                  '(limite ${(ffpLimit * 100).toStringAsFixed(0)}%)',
                ),
                trailing: Icon(
                  finance.wageToRevenueRatio > ffpLimit
                      ? Icons.warning_amber
                      : Icons.check_circle_outline,
                  color: finance.wageToRevenueRatio > ffpLimit
                      ? Colors.orange
                      : Colors.green,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Transferências', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (transfers.isEmpty)
            const Text('Nenhuma transferência registada.')
          else
            ...transfers.take(12).map(
                  (transfer) => ListTile(
                    leading: Icon(
                      transfer.isFree ? Icons.person_off : Icons.swap_horiz,
                    ),
                    title: Text(
                      session.registry.getPlayer(transfer.playerId)?.name ??
                          transfer.playerId.value,
                    ),
                    subtitle: Text(
                      '${session.clubName(transfer.fromClubId)} → '
                      '${session.clubName(transfer.toClubId)} · ${transfer.date}',
                    ),
                    trailing: transfer.isFree
                        ? const Text('Livre')
                        : Text(MoneyFormat.compact(transfer.fee)),
                  ),
                ),
        ],
      ),
    );
  }
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String label;
  final int amount;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = total <= 0 ? 0.0 : (amount / total * 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(
                '${MoneyFormat.compact(amount)} '
                '(${pct.toStringAsFixed(0)}%)',
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total <= 0 ? 0 : (amount / total).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
