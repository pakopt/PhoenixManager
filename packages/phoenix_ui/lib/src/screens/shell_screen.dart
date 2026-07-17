import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/game/save_slot.dart';
import 'package:phoenix_ui/src/screens/boot_screen.dart';
import 'package:phoenix_ui/src/screens/dashboard_screen.dart';
import 'package:phoenix_ui/src/screens/finances_screen.dart';
import 'package:phoenix_ui/src/screens/fixtures_screen.dart';
import 'package:phoenix_ui/src/screens/inbox_screen.dart';
import 'package:phoenix_ui/src/screens/market_screen.dart';
import 'package:phoenix_ui/src/legal/app_privacy_policy.dart';
import 'package:phoenix_ui/src/screens/privacy_policy_screen.dart';
import 'package:phoenix_ui/src/screens/squad_screen.dart';
import 'package:phoenix_ui/src/screens/standings_screen.dart';
import 'package:phoenix_ui/src/screens/club_screen.dart';
import 'package:phoenix_ui/src/screens/training_screen.dart';
import 'package:phoenix_ui/src/game/inbox_message.dart';
import 'package:phoenix_ui/src/game/inbox_read_store.dart';
import 'package:phoenix_ui/src/util/app_version.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/platform_chrome.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/app_sidebar.dart';
import 'package:phoenix_ui/src/widgets/beta_checklist_help.dart';
import 'package:phoenix_ui/src/widgets/content_width.dart';
import 'package:phoenix_ui/src/widgets/first_run_help_sheet.dart';
import 'package:phoenix_ui/src/widgets/top_command_bar.dart';
import 'package:phoenix_ui/src/widgets/unsaved_leave_help.dart';
import 'package:phoenix_ui/src/widgets/whats_new_help_sheet.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;
  int _clubInitialTab = 0;
  int _inboxUnread = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _saveHintShown = false;

  static const _inboxIndex = 1;
  static const _squadIndex = 2;
  static const _fixturesIndex = 4;
  static const _standingsIndex = 5;
  static const _financesIndex = 7;
  static const _clubIndex = 8;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOnboarding();
      _refreshInboxUnread();
    });
  }

  Future<void> _maybeShowOnboarding() async {
    final session = widget.controller.session;
    if (!mounted || session == null) {
      return;
    }
    final showedFirstRun = await FirstRunHelp.showIfNeeded(
      context,
      matchesPlayed: session.matchesPlayed,
    );
    if (!mounted || showedFirstRun) {
      return;
    }
    await WhatsNewHelp.showIfNeeded(context);
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
      _maybeShowSaveHint();
      _refreshInboxUnread();
    }
  }

  Future<void> _refreshInboxUnread() async {
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    final read = await InboxReadStore.loadReadIds(widget.controller.activeSlot);
    final messages = InboxMessageBuilder.fromSession(session);
    final unread = messages.where((m) => !read.contains(m.id)).length;
    if (!mounted) {
      return;
    }
    if (unread != _inboxUnread) {
      setState(() => _inboxUnread = unread);
    }
  }

  void _maybeShowSaveHint() {
    if (_saveHintShown || !widget.controller.hasUnsavedChanges) {
      return;
    }
    // Express auto-guarda após jornada — o aviso importa sobretudo no Diretor.
    if (widget.controller.playMode == PlayMode.express) {
      return;
    }
    _saveHintShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.hasUnsavedChanges) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Alterações por guardar'),
          action: SnackBarAction(
            label: 'Guardar',
            onPressed: () async {
              await widget.controller.saveGame();
              if (!mounted) {
                return;
              }
              UiFeedback.action();
            },
          ),
        ),
      );
    });
  }

  void _showPendingAchievementToasts() {
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    final ids = widget.controller.consumePendingAchievementUnlocks();
    if (ids.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (ids.length == 1) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.military_tech),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Conquista: ${session.achievementTitle(ids.first)}',
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
      return;
    }

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('${ids.length} conquistas desbloqueadas'),
        action: SnackBarAction(
          label: 'Ver',
          onPressed: _openAchievementsTab,
        ),
      ),
    );
  }

  void _openAchievementsTab() {
    setState(() {
      _clubInitialTab = 3;
      _index = _clubIndex;
    });
  }

  void _selectDestination(int value) {
    UiFeedback.tap();
    setState(() {
      if (value == _clubIndex && _index != _clubIndex) {
        _clubInitialTab = 0;
      }
      _index = value;
    });
    unawaited(BetaChecklistHelp.noteTabVisit(value));
  }

  Future<void> _quickSaveActiveSlot() async {
    final slot = widget.controller.activeSlot;
    await widget.controller.saveGame(slot);
    if (!mounted) {
      return;
    }
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.save_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text('Carreira guardada no slot ${slot + 1}')),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmQuitDesktop() async {
    if (widget.controller.hasUnsavedChanges) {
      final ok = await UnsavedLeaveHelp.confirmLeave(
        context,
        widget.controller,
        title: 'Sair do jogo?',
        body: 'Há alterações por guardar. A app será fechada.',
      );
      if (ok) {
        PhoenixPlatformChrome.quitApp();
      }
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair do jogo?'),
        content: const Text('A app será fechada.'),
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

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Início'),
    (Icons.inbox_outlined, Icons.inbox, 'Inbox'),
    (Icons.groups_outlined, Icons.groups, 'Plantel'),
    (Icons.fitness_center_outlined, Icons.fitness_center, 'Treinos'),
    (Icons.calendar_month_outlined, Icons.calendar_month, 'Jogos'),
    (Icons.leaderboard_outlined, Icons.leaderboard, 'Tabela'),
    (Icons.swap_horiz_outlined, Icons.swap_horiz, 'Mercado'),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finanças'),
    (Icons.shield_outlined, Icons.shield, 'Clube'),
  ];

  Future<void> _saveFromTopBar() async {
    await widget.controller.saveGame();
    if (!mounted) {
      return;
    }
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Carreira guardada no slot ${widget.controller.activeSlot + 1}',
        ),
      ),
    );
  }

  void _goToMatchFromTopBar() {
    UiFeedback.tap();
    final session = widget.controller.session!;
    if (session.isFullSeasonComplete || session.nextFixture == null) {
      return;
    }
    if (widget.controller.playMode == PlayMode.express) {
      setState(() => _index = 0);
      return;
    }
    widget.controller.advanceToNextMatch();
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final extendedSidebar = width >= 1100;

    final pages = [
      DashboardScreen(
        controller: widget.controller,
        onOpenAchievements: _openAchievementsTab,
        onOpenStandings: () => _selectDestination(_standingsIndex),
        onOpenFixtures: () => _selectDestination(_fixturesIndex),
        onOpenFinances: () => _selectDestination(_financesIndex),
        onOpenSquad: () => _selectDestination(_squadIndex),
      ),
      InboxScreen(
        controller: widget.controller,
        onUnreadChanged: (count) {
          if (count != _inboxUnread) {
            setState(() => _inboxUnread = count);
          }
        },
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

    final topBar = TopCommandBar(
      session: session,
      playMode: widget.controller.playMode,
      activeSlot: widget.controller.activeSlot,
      hasUnsavedChanges: widget.controller.hasUnsavedChanges,
      inboxUnread: _inboxUnread,
      onSave: _saveFromTopBar,
      onGoToMatch: _goToMatchFromTopBar,
      onOpenInbox: () => _selectDestination(_inboxIndex),
      onOpenMenu: () => wide
          ? _scaffoldKey.currentState?.openEndDrawer()
          : _scaffoldKey.currentState?.openDrawer(),
      compact: !wide,
      showLeadingMenu: !wide,
    );

    final scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: topBar,
      drawer: wide ? null : _GameDrawer(controller: widget.controller),
      body: wide
          ? Row(
              children: [
                AppSidebar(
                  clubName: session.userClub.name,
                  destinations: _destinations,
                  selectedIndex: _index,
                  onSelect: _selectDestination,
                  badges: {
                    if (_inboxUnread > 0) _inboxIndex: _inboxUnread,
                  },
                  extended: extendedSidebar,
                  onOpenMenu: () =>
                      _scaffoldKey.currentState?.openEndDrawer(),
                ),
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
              labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
              destinations: [
                for (var i = 0; i < _destinations.length; i++)
                  NavigationDestination(
                    icon: _inboxUnread > 0 && i == _inboxIndex
                        ? Badge(
                            label: Text('$_inboxUnread'),
                            child: Icon(_destinations[i].$1),
                          )
                        : Icon(_destinations[i].$1),
                    selectedIcon: Icon(_destinations[i].$2),
                    label: _destinations[i].$3,
                    tooltip: _destinations[i].$3,
                  ),
              ],
            ),
    );

    Widget withUnsavedGuard(Widget child) {
      return PopScope(
        canPop: !widget.controller.hasUnsavedChanges,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }
          final ok = await UnsavedLeaveHelp.confirmLeave(
            context,
            widget.controller,
            title: 'Sair da carreira?',
            body:
                'Há alterações por guardar. Queres guardar antes de voltar?',
          );
          if (ok && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: child,
      );
    }

    if (!PhoenixPlatformChrome.isDesktop) {
      return withUnsavedGuard(scaffold);
    }

    return withUnsavedGuard(
      CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyS, meta: true):
              _quickSaveActiveSlot,
          const SingleActivator(LogicalKeyboardKey.keyS, control: true):
              _quickSaveActiveSlot,
          const SingleActivator(LogicalKeyboardKey.keyQ, meta: true):
              _confirmQuitDesktop,
          const SingleActivator(LogicalKeyboardKey.keyQ, control: true):
              _confirmQuitDesktop,
        },
        child: Focus(
          autofocus: true,
          child: scaffold,
        ),
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
                  '${DateFormatUtil.gameDate(session.currentDate)} · '
                  'Jornada ${session.tick}',
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
            subtitle: () {
              final parts = <String>[
                if (controller.hasUnsavedChanges) 'Alterações por guardar',
                if (PhoenixPlatformChrome.isDesktop) 'Ctrl/⌘+S (slot activo)',
                if (controller.lastSavedAt != null)
                  'Último: ${DateFormatUtil.relative(controller.lastSavedAt!)}',
              ];
              if (parts.isEmpty) {
                return null;
              }
              return Text(parts.join(' · '));
            }(),
            onTap: () {
              UiFeedback.action();
              _pickSaveSlot(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Carregar save'),
            onTap: () {
              UiFeedback.action();
              _pickLoadSlot(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phoenix Manager'),
            subtitle: Text(AppVersion.engineLabel),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Feedback / reportar bug'),
            subtitle: const Text('Copia um modelo para email'),
            onTap: () => _copyFeedbackTemplate(context),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Roteiro de teste (beta)'),
            subtitle: BetaChecklistProgressLabel(
              builder: (context, done, total) => Text(
                done == 0
                    ? 'Checklist rápido do teste fechado'
                    : 'Progresso $done/$total',
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              BetaChecklistHelp.show(context);
            },
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
            onTap: () async {
              Navigator.pop(context);
              final ok = await UnsavedLeaveHelp.confirmLeave(
                context,
                controller,
                title: 'Voltar ao menu?',
                body:
                    'Há alterações por guardar. Queres guardar antes de sair da carreira?',
              );
              if (!ok || !context.mounted) {
                return;
              }
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => BootScreen(controller: controller),
                ),
                (_) => false,
              );
            },
          ),
          if (PhoenixPlatformChrome.isDesktop) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair do jogo'),
              subtitle: Text(
                controller.hasUnsavedChanges
                    ? 'Alterações por guardar · Ctrl/⌘+Q'
                    : 'Ctrl/⌘+Q',
              ),
              onTap: () async {
                Navigator.pop(context);
                if (controller.hasUnsavedChanges) {
                  final ok = await UnsavedLeaveHelp.confirmLeave(
                    context,
                    controller,
                    title: 'Sair do jogo?',
                    body: 'Há alterações por guardar. A app será fechada.',
                  );
                  if (ok) {
                    PhoenixPlatformChrome.quitApp();
                  }
                  return;
                }
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sair do jogo?'),
                    content: const Text('A app será fechada.'),
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
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _copyFeedbackTemplate(BuildContext context) async {
    final checklist = await BetaChecklistHelp.progressSummary();
    final text = AppVersion.feedbackTemplate(
      playMode: controller.playMode.label,
      saveSlot: controller.activeSlot,
      betaChecklistSummary: checklist,
    );
    await Clipboard.setData(ClipboardData(text: text));
    await BetaChecklistHelp.markDone('feedback');
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context);
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.content_copy),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Modelo copiado — cola no email para '
                '${AppPrivacyPolicy.contactEmail}',
              ),
            ),
          ],
        ),
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
    if (!context.mounted) {
      return;
    }
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.save_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text('Carreira guardada no slot ${slot + 1}')),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLoadSlot(BuildContext context) async {
    final filled = controller.slots.where((s) => !s.isEmpty).toList();
    if (filled.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.info_outline),
              SizedBox(width: 8),
              Expanded(child: Text('Nenhum save encontrado')),
            ],
          ),
        ),
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
    final proceed = await UnsavedLeaveHelp.confirmLeave(
      context,
      controller,
      title: 'Carregar outro save?',
      body:
          'Há alterações por guardar na carreira actual. '
          'Queres guardar antes de carregar outro slot?',
      discardLabel: 'Carregar sem guardar',
      saveLabel: 'Guardar e carregar',
    );
    if (!proceed || !context.mounted) {
      return;
    }
    final ok = await controller.loadGame(slot);
    if (!context.mounted) {
      return;
    }
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? null : Theme.of(context).colorScheme.error,
        content: Row(
          children: [
            Icon(ok ? Icons.check_circle_outline : Icons.error_outline),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ok
                    ? 'Save carregado do slot ${slot + 1}'
                    : 'Falha ao carregar',
              ),
            ),
          ],
        ),
      ),
    );
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
