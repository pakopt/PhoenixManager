import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';

class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({
    required this.controller,
    required this.playerId,
    super.key,
  });

  final GameController controller;
  final PlayerId playerId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final session = controller.session!;
        final player = session.getPlayer(playerId);
        if (player == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Jogador')),
            body: const Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                message: 'Jogador não encontrado no plantel.',
              ),
            ),
          );
        }
        return _buildBody(context, session, player);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    GameSession session,
    Player player,
  ) {
    final theme = Theme.of(context);
    final value = const PlayerValueService().calculate(
      player,
      club: session.registry.getClub(player.clubId),
    );
    final gap = player.potentialAbility - player.currentAbility;
    final isYouth = player.age <= session.youthConfig.maxAge;
    final isWonderkid = gap >= 15;
    final canRenew = session.canRenewPlayer(player);
    final defaultOffer = canRenew ? session.renewalOfferFor(player.id) : null;
    final isExpiring = player.contractEndYear <= session.seasonYear + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(player.name),
        actions: [
          if (isWonderkid)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Tooltip(
                message: 'Wonderkid — alto potencial',
                child: Icon(Icons.star, color: Colors.amber),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.cardTheme.color ?? theme.colorScheme.surface,
                ],
              ),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  '${player.currentAbility}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Text('Current Ability'),
                const SizedBox(height: 4),
                Text(
                  'Potencial ${player.potentialAbility} · +$gap margem',
                  style: theme.textTheme.bodyMedium,
                ),
                if (isYouth)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Chip(
                      avatar: const Icon(Icons.school, size: 16),
                      label: Text(
                        isWonderkid ? 'Wonderkid' : 'Academia',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (canRenew && defaultOffer != null) ...[
            const SizedBox(height: 16),
            Card(
              color: isExpiring
                  ? theme.colorScheme.tertiaryContainer.withValues(alpha: 0.4)
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.assignment,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Renovação de contrato',
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isExpiring
                          ? 'Contrato expira em ${player.contractEndYear}'
                          : 'Contrato válido até ${player.contractEndYear}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Proposta (+${defaultOffer.extensionYears} anos): '
                      '${MoneyFormat.perMonth(defaultOffer.newSalary)} '
                      '(+${MoneyFormat.compact(defaultOffer.salaryIncrease)}) · '
                      'até ${defaultOffer.newContractEndYear}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        UiFeedback.tap();
                        _showRenewDialog(
                          context,
                          player,
                          defaultOffer.extensionYears,
                        );
                      },
                      icon: const Icon(Icons.edit_document),
                      label: const Text('Renovar contrato'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
          const SizedBox(height: 8),
          _InfoTile(label: 'Idade', value: '${player.age} anos'),
          _InfoTile(label: 'Clube', value: session.clubName(player.clubId)),
          _InfoTile(
            label: 'Estado',
            value: player.isInjured
                ? 'Lesionado (${player.injuredDaysRemaining} dias)'
                : 'Disponível',
          ),
          _InfoTile(label: 'Salário', value: MoneyFormat.perMonth(player.salary)),
          _InfoTile(
            label: 'Contrato até',
            value: '${player.contractEndYear}',
          ),
          _InfoTile(label: 'Valor mercado', value: MoneyFormat.compact(value)),
        ],
      ),
    );
  }

  Future<void> _showRenewDialog(
    BuildContext context,
    Player player,
    int defaultYears,
  ) async {
    final session = controller.session!;
    final config = session.contractConfig;
    var selectedYears = defaultYears;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final offer = session.renewalOfferFor(
              player.id,
              years: selectedYears,
            );
            return AlertDialog(
              title: Text('Renovar ${player.name}'),
              content: offer == null
                  ? const Text('Renovação indisponível')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Duração da extensão'),
                        const SizedBox(height: 8),
                        SegmentedButton<int>(
                          segments: [
                            for (var y = config.minExtensionYears;
                                y <= config.maxExtensionYears;
                                y++)
                              ButtonSegment(value: y, label: Text('$y anos')),
                          ],
                          selected: {selectedYears},
                          onSelectionChanged: (value) {
                            setState(() => selectedYears = value.first);
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Novo salário: €${offer.newSalary}/mês'),
                        Text('Aumento: +€${offer.salaryIncrease}/mês'),
                        Text('Válido até: ${offer.newContractEndYear}'),
                        Text(
                          'Moral +${config.moraleBoostOnRenewal} após assinatura',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: offer == null
                      ? null
                      : () => Navigator.pop(dialogContext, true),
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final error = await controller.renewContract(
      player.id,
      extensionYears: selectedYears,
    );
    if (!context.mounted) {
      return;
    }

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    await controller.saveGame();
    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contrato de ${player.name} renovado')),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
