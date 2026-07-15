import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/app_version.dart';
import 'package:phoenix_ui/src/util/platform_chrome.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/screens/privacy_policy_screen.dart';
import 'package:phoenix_ui/src/screens/shell_screen.dart';
import 'package:phoenix_ui/src/screens/simulation_lab_screen.dart';
import 'package:phoenix_ui/src/widgets/save_slot_card.dart';

class CareerMenuScreen extends StatelessWidget {
  const CareerMenuScreen({required this.controller, super.key});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.12),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 56,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Project Phoenix Manager',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppVersion.engineLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escolhe um slot de carreira',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: controller.isBooting
                          ? null
                          : () => _quickPlay(context),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(
                        controller.hasSave ? 'Continuar carreira' : 'Jogar agora',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.hasSave
                          ? 'Retoma o save mais recente'
                          : 'Nova carreira Express no primeiro slot livre',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...controller.slots.map(
                      (meta) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SaveSlotCard(
                          meta: meta,
                          isLoading: controller.isBooting,
                          onContinue: meta.isEmpty
                              ? null
                              : () => _continue(context, meta.index),
                          onNewCareer: meta.isEmpty
                              ? () => _newCareer(context, meta.index)
                              : () => _confirmOverwrite(context, meta.index),
                          onDelete: meta.isEmpty
                              ? null
                              : () => _confirmDelete(context, meta.index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Modo de jogo', style: theme.textTheme.titleSmall),
                        IconButton(
                          icon: const Icon(Icons.help_outline, size: 20),
                          tooltip: 'Diferença Express vs Diretor',
                          onPressed: () => _showPlayModeHelp(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<PlayMode>(
                      segments: const [
                        ButtonSegment(
                          value: PlayMode.express,
                          label: Text('Express'),
                          icon: Icon(Icons.flash_on),
                        ),
                        ButtonSegment(
                          value: PlayMode.director,
                          label: Text('Diretor'),
                          icon: Icon(Icons.manage_accounts),
                        ),
                      ],
                      selected: {controller.playMode},
                      onSelectionChanged: (selection) {
                        controller.setPlayMode(selection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.playMode.description,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: controller.isBooting
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SimulationLabScreen(),
                                ),
                              );
                            },
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Simulation Lab'),
                    ),
                    Text(
                      'Balanceamento headless — não afecta saves',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    if (controller.isBooting) ...[
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                    if (controller.error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        controller.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => PrivacyPolicyScreen.open(context),
                      icon: Icon(
                        Icons.privacy_tip_outlined,
                        size: 18,
                        color: theme.colorScheme.outline,
                      ),
                      label: Text(
                        'Privacidade',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                    if (PhoenixPlatformChrome.isDesktop) ...[
                      const SizedBox(height: 4),
                      TextButton.icon(
                        onPressed: () => _confirmQuit(context),
                        icon: Icon(
                          Icons.logout,
                          size: 18,
                          color: theme.colorScheme.outline,
                        ),
                        label: Text(
                          'Sair do jogo',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _confirmQuit(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair do jogo?'),
        content: const Text('A app será fechada. Guarda a carreira antes, se precisares.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (ok == true) {
      PhoenixPlatformChrome.quitApp();
    }
  }

  static void _showPlayModeHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modos de jogo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.flash_on),
              title: const Text('Express'),
              subtitle: Text(PlayMode.express.description),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Diretor'),
              subtitle: Text(PlayMode.director.description),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _continue(BuildContext context, int slot) async {
    await controller.continueCareer(slot);
    if (context.mounted && controller.isReady) {
      _goToGame(context);
    }
  }

  Future<void> _quickPlay(BuildContext context) async {
    await controller.quickPlay();
    if (context.mounted && controller.isReady) {
      _goToGame(context);
    }
  }

  Future<void> _newCareer(BuildContext context, int slot) async {
    await controller.startNewCareer(slot);
    if (context.mounted && controller.isReady) {
      _goToGame(context);
    }
  }

  Future<void> _confirmOverwrite(BuildContext context, int slot) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Substituir save?'),
        content: Text(
          'O slot ${slot + 1} já tem uma carreira. '
          'Queres iniciar uma nova e substituir o save existente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nova carreira'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await controller.deleteSlot(slot);
      await _newCareer(context, slot);
    }
  }

  Future<void> _confirmDelete(BuildContext context, int slot) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar save?'),
        content: Text(
          'Tens a certeza que queres apagar o slot ${slot + 1}? '
          'Esta acção não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await controller.deleteSlot(slot);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Slot ${slot + 1} apagado')),
        );
      }
    }
  }

  void _goToGame(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ShellScreen(controller: controller),
      ),
    );
  }
}
