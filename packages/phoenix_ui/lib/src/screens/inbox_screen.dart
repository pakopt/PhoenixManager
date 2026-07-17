import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/inbox_message.dart';
import 'package:phoenix_ui/src/game/inbox_read_store.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({
    required this.controller,
    this.onUnreadChanged,
    super.key,
  });

  final GameController controller;
  final ValueChanged<int>? onUnreadChanged;

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  InboxCategory _filter = InboxCategory.all;
  String? _selectedId;
  Set<String> _readIds = {};
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _loadRead();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (mounted) {
      setState(() {});
      _notifyUnread();
    }
  }

  Future<void> _loadRead() async {
    final ids = await InboxReadStore.loadReadIds(widget.controller.activeSlot);
    if (!mounted) {
      return;
    }
    setState(() {
      _readIds = ids;
      _loaded = true;
    });
    _notifyUnread();
  }

  List<InboxMessage> get _messages {
    final session = widget.controller.session;
    if (session == null) {
      return const [];
    }
    final all = InboxMessageBuilder.fromSession(session);
    if (_filter == InboxCategory.all) {
      return all;
    }
    return all.where((m) => m.category == _filter).toList();
  }

  int get _unreadCount {
    final session = widget.controller.session;
    if (session == null) {
      return 0;
    }
    final all = InboxMessageBuilder.fromSession(session);
    return all.where((m) => !_readIds.contains(m.id)).length;
  }

  void _notifyUnread() {
    widget.onUnreadChanged?.call(_unreadCount);
  }

  Future<void> _select(InboxMessage message) async {
    UiFeedback.tap();
    setState(() => _selectedId = message.id);
    if (!_readIds.contains(message.id)) {
      await InboxReadStore.markRead(widget.controller.activeSlot, message.id);
      if (!mounted) {
        return;
      }
      setState(() => _readIds = {..._readIds, message.id});
      _notifyUnread();
    }

    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (!wide) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => _InboxDetailPage(
            message: message,
            onBack: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  Future<void> _markAllRead() async {
    final ids = _messages.map((m) => m.id);
    await InboxReadStore.markAllRead(widget.controller.activeSlot, ids);
    if (!mounted) {
      return;
    }
    UiFeedback.action();
    setState(() => _readIds = {..._readIds, ...ids});
    _notifyUnread();
  }

  @override
  Widget build(BuildContext context) {
    final messages = _messages;
    final unread = _unreadCount;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final selected = messages
        .where((m) => m.id == _selectedId)
        .cast<InboxMessage?>()
        .firstOrNull;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Inbox',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: PhoenixColors.textPrimary,
                            ),
                      ),
                      if (_loaded && unread > 0) ...[
                        const SizedBox(width: 10),
                        _UnreadPill(count: unread),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: unread == 0 ? null : _markAllRead,
                  child: const Text('Marcar tudo como lido'),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                for (final category in InboxCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: category.label,
                      selected: _filter == category,
                      onTap: () {
                        UiFeedback.tap();
                        setState(() {
                          _filter = category;
                          if (selected != null &&
                              category != InboxCategory.all &&
                              selected.category != category) {
                            _selectedId = null;
                          }
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 380,
                        child: _MessageList(
                          messages: messages,
                          readIds: _readIds,
                          selectedId: _selectedId,
                          onSelect: _select,
                        ),
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: selected == null
                            ? const _EmptyDetail()
                            : _MessageDetail(message: selected),
                      ),
                    ],
                  )
                : _MessageList(
                    messages: messages,
                    readIds: _readIds,
                    selectedId: _selectedId,
                    onSelect: _select,
                  ),
          ),
        ],
      ),
    );
  }
}

class _UnreadPill extends StatelessWidget {
  const _UnreadPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: PhoenixColors.seed.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count não lidas',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PhoenixColors.seed : PhoenixColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? PhoenixColors.seed
                  : PhoenixColors.cardBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? Colors.white : PhoenixColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.readIds,
    required this.selectedId,
    required this.onSelect,
  });

  final List<InboxMessage> messages;
  final Set<String> readIds;
  final String? selectedId;
  final ValueChanged<InboxMessage> onSelect;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: PhoenixColors.muted),
              SizedBox(height: 12),
              Text(
                'Caixa de entrada vazia',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: PhoenixColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Avança a carreira para receber resultados, transferências e alertas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PhoenixColors.muted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final message = messages[index];
        final unread = !readIds.contains(message.id);
        final selected = message.id == selectedId;
        return _MessageTile(
          message: message,
          unread: unread,
          selected: selected,
          onTap: () => onSelect(message),
        );
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.unread,
    required this.selected,
    required this.onTap,
  });

  final InboxMessage message;
  final bool unread;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PhoenixColors.seed.withValues(alpha: 0.14)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 10,
                child: unread
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: PhoenixColors.positive,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              Icon(
                message.icon,
                size: 20,
                color: unread
                    ? PhoenixColors.textPrimary
                    : PhoenixColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                        color: unread
                            ? PhoenixColors.textPrimary
                            : PhoenixColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: PhoenixColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                message.dateLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: PhoenixColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.mail_outline,
            size: 64,
            color: PhoenixColors.muted,
          ),
          SizedBox(height: 12),
          Text(
            'Selecciona uma mensagem para ler.',
            style: TextStyle(
              color: PhoenixColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageDetail extends StatelessWidget {
  const _MessageDetail({required this.message});

  final InboxMessage message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Icon(message.icon, color: PhoenixColors.positive),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PhoenixColors.textPrimary,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${message.category.label} · ${message.dateLabel}',
          style: const TextStyle(color: PhoenixColors.muted),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Text(
            message.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: PhoenixColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

class _InboxDetailPage extends StatelessWidget {
  const _InboxDetailPage({
    required this.message,
    required this.onBack,
  });

  final InboxMessage message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: _MessageDetail(message: message),
    );
  }
}
