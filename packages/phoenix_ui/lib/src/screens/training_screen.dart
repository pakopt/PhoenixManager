import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/screens/academy_panel.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Treinos', icon: Icon(Icons.fitness_center)),
                Tab(text: 'Academia', icon: Icon(Icons.school)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TrainingPanel(controller: controller),
                AcademyPanel(controller: controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingPanel extends StatefulWidget {
  const _TrainingPanel({required this.controller});

  final GameController controller;

  @override
  State<_TrainingPanel> createState() => _TrainingPanelState();
}

class _TrainingPanelState extends State<_TrainingPanel> {
  var _onlyTrainable = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final config = session.trainingConfig;
    final trainable = session.trainablePlayers;
    var squad = List<Player>.from(session.squad);
    squad.sort(
      (a, b) => (b.potentialAbility - b.currentAbility)
          .compareTo(a.potentialAbility - a.currentAbility),
    );
    if (_onlyTrainable) {
      final ids = trainable.map((p) => p.id).toSet();
      squad = squad.where((p) => ids.contains(p.id)).toList();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _SummaryTile(
                label: 'CA média',
                value: session.squadAverageCa.toStringAsFixed(1),
              ),
              const SizedBox(width: 8),
              _SummaryTile(
                label: 'Forma média',
                value: session.squadAverageForm.toStringAsFixed(0),
              ),
              const SizedBox(width: 8),
              _SummaryTile(
                label: 'Com margem',
                value: '${trainable.length}',
                subtitle: 'evolução',
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilterChip(
            label: Text('Só com margem de evolução (${trainable.length})'),
            selected: _onlyTrainable,
            onSelected: (v) => setState(() => _onlyTrainable = v),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sistema de treino (PSE)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Evolução diária automática off-screen. '
                    'Jogadores ≤${config.maxAgeForGrowth} anos com CA < PA '
                    'têm ${(config.dailyCaGainChance * 100).toStringAsFixed(0)}% '
                    'de progredir +${config.dailyCaGainMax} CA por dia.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pós-jogo: +${config.matchFormWinBoost} forma (vitória), '
                    '+${config.matchWinMoraleBoost} moral.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Plantel · ${squad.length} jogadores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (session.squad.isEmpty)
            const EmptyState(
              icon: Icons.groups_outlined,
              message: 'Plantel vazio.',
            )
          else if (squad.isEmpty)
            const EmptyState(
              icon: Icons.filter_alt_off,
              message: 'Nenhum jogador com margem de evolução.',
            )
          else
            ...squad.map(
              (player) => _PlayerTrainingCard(
                player: player,
                onTap: () {
                  UiFeedback.tap();
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PlayerDetailScreen(
                        controller: widget.controller,
                        playerId: player.id,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
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

class _PlayerTrainingCard extends StatelessWidget {
  const _PlayerTrainingCard({
    required this.player,
    required this.onTap,
  });

  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canGrow = player.currentAbility < player.potentialAbility;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    child: Text('${player.currentAbility}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${player.age} anos · PA ${player.potentialAbility}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (canGrow)
                    Tooltip(
                      message: 'Com margem de evolução',
                      child: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    )
                  else if (player.isInjured)
                    Tooltip(
                      message: 'Lesionado',
                      child: Icon(
                        Icons.healing,
                        color: Theme.of(context).colorScheme.error,
                        size: 20,
                      ),
                    ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              PlayerStatBar(
                label: 'CA → PA',
                value: player.currentAbility,
                max: player.potentialAbility,
              ),
              PlayerStatBar(
                label: 'Forma',
                value: player.form,
                max: 100,
                color: Colors.blueAccent,
              ),
              PlayerStatBar(
                label: 'Moral',
                value: player.morale,
                max: 100,
                color: Colors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
