import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';
import 'package:phoenix_ui/src/widgets/staff_labels.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

class StaffPanel extends StatelessWidget {
  const StaffPanel({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staff = session.userStaff;
    final bonuses = session.staffBonuses;
    final wageBill = session.staffMonthlyWages;

    final grouped = <String, List<StaffMember>>{};
    for (final member in staff) {
      grouped.putIfAbsent(member.role.departmentPt, () => []).add(member);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _SummaryTile(label: 'Membros', value: '${staff.length}'),
            const SizedBox(width: 8),
            _SummaryTile(
              label: 'Salários staff',
              value: MoneyFormat.compact(wageBill),
            ),
            const SizedBox(width: 8),
            _SummaryTile(
              label: 'Nível médio',
              value: staff.isEmpty
                  ? '—'
                  : (staff.map((s) => s.level).reduce((a, b) => a + b) /
                          staff.length)
                      .round()
                      .toString(),
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
                  'Impacto no PSE',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '+${(bonuses.trainingChanceBonus * 100).toStringAsFixed(1)}% '
                  'chance treino · −${bonuses.injuryDaysReduction} dias lesão · '
                  '+${bonuses.youthPaBonus} PA intake · '
                  '+${bonuses.moraleDailyBoost} moral/dia · '
                  '−${(bonuses.injuryChanceReduction * 100).toStringAsFixed(1)}% risco lesão',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (staff.isEmpty)
          const EmptyState(
            icon: Icons.groups_outlined,
            message: 'Sem staff atribuído ao clube.',
          )
        else
          for (final dept in staffDepartmentOrder)
          if (grouped.containsKey(dept)) ...[
            Text(dept, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...grouped[dept]!.map(
              (member) => _StaffCard(member: member),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

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
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  const _StaffCard({required this.member});

  final StaffMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(member.role.icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        member.role.labelPt,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '€${member.salary}/m',
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            PlayerStatBar(
              label: 'Nível',
              value: member.level,
              max: 100,
            ),
          ],
        ),
      ),
    );
  }
}
