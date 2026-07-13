import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/game/save_slot.dart';
import 'package:phoenix_ui/src/screens/boot_screen.dart';
import 'package:phoenix_ui/src/screens/dashboard_screen.dart';
import 'package:phoenix_ui/src/screens/finances_screen.dart';
import 'package:phoenix_ui/src/screens/fixtures_screen.dart';
import 'package:phoenix_ui/src/screens/market_screen.dart';
import 'package:phoenix_ui/src/screens/privacy_policy_screen.dart';
import 'package:phoenix_ui/src/screens/squad_screen.dart';
import 'package:phoenix_ui/src/screens/standings_screen.dart';
import 'package:phoenix_ui/src/screens/club_screen.dart';
import 'package:phoenix_ui/src/screens/training_screen.dart';
import 'package:phoenix_ui/src/widgets/content_width.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  int _clubInitialTab = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
      _showPendingAchievementToasts();
    }
  }

  void _showPendingAchievementToasts() {
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    for (final id in widget.controller.consumePendingAchievementUnlocks()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.military_tech),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conquista: ${session.achievementTitle(id)}',
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'Ver',
            onPressed: _openAchievementsTab,
          ),
        ),
      );
    }
  }

  void _openAchievementsTab() {
    setState(() {
      _clubInitialTab = 3;
      _index = 7;
    });
  }

  void _selectDestination(int value) {
    setState(() {
      if (value == 7 && _index != 7) {
        _clubInitialTab = 0;
      }
      _index = value;
    });
  }

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Início'),
    (Icons.groups_outlined, Icons.groups, 'Plantel'),
    (Icons.fitness_center_outlined, Icons.fitness_center, 'Treinos'),
    (Icons.calendar_month_outlined, Icons.calendar_month, 'Jogos'),
    (Icons.leaderboard_outlined, Icons.leaderboard, 'Tabela'),
    (Icons.swap_horiz_outlined, Icons.swap_horiz, 'Mercado'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finanças'),
    (Icons.shield_outlined, Icons.shield, 'Clube'),
  ];

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final pages = [
      DashboardScreen(
        controller: widget.controller,
        onOpenAchievements: _openAchievementsTab,
      ),
      SquadScreen(controller: widget.controller),
      TrainingScreen(controller: widget.controller),
      FixturesScreen(controller: widget.controller),
      StandingsScreen(session: session),
      MarketScreen(session: session),
      FinancesScreen(session: session),
      ClubScreen(
        key: ValueKey('club-tab-$_clubInitialTab'),
        session: session,
        initialTab: _clubInitialTab,
      ),
    ];

    final body = ContentWidth(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: pages[_index],
        ),
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: wide
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Menu do jogo',
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              )
            : null,
        title: Text(session.userClub.name),
        actions: [
          Chip(
            avatar: Icon(
              widget.controller.playMode == PlayMode.express
                  ? Icons.flash_on
                  : Icons.manage_accounts,
              size: 16,
            ),
            label: Text(
              '${widget.controller.playMode.label} · S${widget.controller.activeSlot + 1}',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: wide ? null : _GameDrawer(controller: widget.controller),
      body: wide
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _selectDestination,
                  extended: MediaQuery.sizeOf(context).width >= 1100,
                  labelType: MediaQuery.sizeOf(context).width >= 1100
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2),
                        label: Text(d.$3),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            )
          : body,
      endDrawer: wide ? _GameDrawer(controller: widget.controller) : null,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _selectDestination,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                for (final d in _destinations)
                  NavigationDestination(
                    icon: Icon(d.$1),
                    selectedIcon: Icon(d.$2),
                    label: d.$3,
                  ),
              ],
            ),
    );
  }
}

class _GameDrawer extends StatelessWidget {
  const _GameDrawer({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  session.userClub.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${session.currentDate} · Jornada ${session.tick}',
                  style: const TextStyle(color: Colors.white70),
                ),
                Text(
                  'Slot ${controller.activeSlot + 1}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Modo Express'),
            subtitle: Text(controller.playMode.description),
            value: controller.playMode == PlayMode.express,
            onChanged: (_) => controller.togglePlayMode(),
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Guardar carreira'),
            subtitle: controller.lastSavedAt != null
                ? Text('Último: ${controller.lastSavedAt}')
                : null,
            onTap: () => _pickSaveSlot(context),
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Carregar save'),
            onTap: () => _pickLoadSlot(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Project Phoenix Manager'),
            subtitle: const Text('PSE v0.8.0-alpha'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacidade'),
            onTap: () {
              Navigator.pop(context);
              PrivacyPolicyScreen.open(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Menu principal'),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => BootScreen(controller: controller),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickSaveSlot(BuildContext context) async {
    final slot = await showDialog<int>(
      context: context,
      builder: (ctx) => _SlotPickerDialog(
        title: 'Guardar em que slot?',
        slots: controller.slots,
        defaultSlot: controller.activeSlot,
      ),
    );
    if (slot == null || !context.mounted) {
      return;
    }
    await controller.saveGame(slot);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Carreira guardada no slot ${slot + 1}')),
      );
    }
  }

  Future<void> _pickLoadSlot(BuildContext context) async {
    final filled = controller.slots.where((s) => !s.isEmpty).toList();
    if (filled.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum save encontrado')),
      );
      return;
    }
    final slot = await showDialog<int>(
      context: context,
      builder: (ctx) => _SlotPickerDialog(
        title: 'Carregar de que slot?',
        slots: controller.slots,
        defaultSlot: controller.activeSlot,
        onlyFilled: true,
      ),
    );
    if (slot == null || !context.mounted) {
      return;
    }
    final ok = await controller.loadGame(slot);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Save carregado do slot ${slot + 1}' : 'Falha ao carregar',
          ),
        ),
      );
    }
  }
}

class _SlotPickerDialog extends StatefulWidget {
  const _SlotPickerDialog({
    required this.title,
    required this.slots,
    required this.defaultSlot,
    this.onlyFilled = false,
  });

  final String title;
  final List<SaveSlotMeta> slots;
  final int defaultSlot;
  final bool onlyFilled;

  @override
  State<_SlotPickerDialog> createState() => _SlotPickerDialogState();
}

class _SlotPickerDialogState extends State<_SlotPickerDialog> {
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.defaultSlot;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final meta in widget.slots)
            if (!widget.onlyFilled || !meta.isEmpty)
              RadioListTile<int>(
                value: meta.index,
                groupValue: _selected,
                onChanged: (v) => setState(() => _selected = v!),
                title: Text(
                  meta.isEmpty
                      ? 'Slot ${meta.index + 1} (vazio)'
                      : meta.clubName!,
                ),
                subtitle: meta.isEmpty ? null : Text(meta.summarySubtitle),
              ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
