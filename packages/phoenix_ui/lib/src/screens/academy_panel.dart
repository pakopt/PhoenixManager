import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';

class AcademyPanel extends StatelessWidget {
  const AcademyPanel({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;
    final config = session.youthConfig;
    final youth = session.academyPlayers;
    final wonderkids = session.wonderkids;
    final finance = session.userFinance;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            _SummaryTile(
              label: 'Nível academia',
              value: '${finance?.academyLevel ?? 2}',
            ),
            const SizedBox(width: 8),
            _SummaryTile(
              label: 'Jovens',
              value: '${youth.length}',
            ),
            const SizedBox(width: 8),
            _SummaryTile(
              label: 'Estrelas',
              value: '${wonderkids.length}',
              subtitle: 'PA-CA ≥ 15',
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
                  'Intake de fim de época (PSE)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Idades ${config.minAge}–${config.maxAge} · '
                  'CA base ${config.baseCa}±${config.caVariance} · '
                  'PA base ${config.basePa}+ tradição (${(config.traditionPaBonus * 100).toStringAsFixed(0)}%)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Intake base: ${config.baseIntakePerClub} jogadores/clube '
                  '(+ bónus tradição e nível academia).',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (session.recentYouthIntakes.isNotEmpty) ...[
          Text(
            'Intakes recentes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...session.recentYouthIntakes.map(
            (event) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.school),
                title: Text(
                  'Época ${event.seasonYear} · '
                  '${DateFormatUtil.gameDate(event.date)}',
                ),
                subtitle: Text(
                  '${event.players.length} jovens · '
                  'melhor PA ${event.players.map((p) => p.potentialAbility).reduce((a, b) => a > b ? a : b)}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Plantel jovem · ${youth.length}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (youth.isEmpty)
          const EmptyState(
            icon: Icons.school_outlined,
            message:
                'Sem jogadores na faixa etária da academia.\n'
                'Aguarda o intake de fim de época.',
          )
        else
          ...youth.map(
            (player) => _YouthPlayerCard(controller: controller, player: player),
          ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  final String label;
  final String value;
  final String? subtitle;

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
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouthPlayerCard extends StatelessWidget {
  const _YouthPlayerCard({required this.controller, required this.player});

  final GameController controller;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final gap = player.potentialAbility - player.currentAbility;
    final isWonderkid = gap >= 15;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isWonderkid
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlayerDetailScreen(
                controller: controller,
                playerId: player.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isWonderkid
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    child: Text('${player.currentAbility}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                player.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isWonderkid) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${player.age} anos · PA ${player.potentialAbility} · +$gap margem',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              PlayerStatBar(
                label: 'CA → PA',
                value: player.currentAbility,
                max: player.potentialAbility,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
