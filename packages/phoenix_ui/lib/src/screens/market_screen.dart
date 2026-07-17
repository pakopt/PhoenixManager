import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({required this.session, super.key});

  final GameSession session;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final allTransfers = session.registry.transfers.reversed.toList();
    final clubTransfers = session.clubTransfers;
    final isOpen = session.isTransferWindowOpen;
    final windowMonths = session.transferConfig.windowMonths.toList()..sort();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenPageHeader(
            title: 'Mercado',
            subtitle: isOpen ? 'Janela aberta' : 'Janela fechada',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TransferWindowBanner(
              isOpen: isOpen,
              windowMonths: windowMonths,
              currentMonth: session.currentDate.month,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(
                  value: 0,
                  label: Text('Clube (${clubTransfers.length})'),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Liga (${allTransfers.length})'),
                ),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (selection) {
                setState(() => _tabIndex = selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _tabIndex == 0
                ? _TransferList(
                    session: session,
                    transfers: clubTransfers,
                    emptyMessage:
                        'Sem movimentos envolvendo o ${session.userClub.name}.',
                  )
                : _TransferList(
                    session: session,
                    transfers: allTransfers,
                    emptyMessage: isOpen
                        ? 'Janela aberta — a IA ainda não fechou negócios.'
                        : 'Mercado fechado — janela em ${_monthNames(windowMonths)}.',
                  ),
          ),
        ],
      ),
    );
  }

  static String _monthNames(List<int> months) {
    const names = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return months.map((m) => names[m - 1]).join(', ');
  }
}

class _TransferWindowBanner extends StatelessWidget {
  const _TransferWindowBanner({
    required this.isOpen,
    required this.windowMonths,
    required this.currentMonth,
  });

  final bool isOpen;
  final List<int> windowMonths;
  final int currentMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final windows = windowMonths.map((m) => monthNames[m - 1]).join(' · ');

    final title =
        isOpen ? 'Janela de transferências aberta' : 'Mercado fechado';
    final subtitle = isOpen
        ? '${monthNames[currentMonth - 1]} · negócios activos'
        : 'Janelas: $windows';
    return Semantics(
      label: '$title. $subtitle',
      child: Card(
        color: isOpen
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
            : null,
        child: ListTile(
          leading: Icon(
            isOpen ? Icons.lock_open : Icons.lock_outline,
            color:
                isOpen ? theme.colorScheme.primary : theme.colorScheme.outline,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class _TransferList extends StatelessWidget {
  const _TransferList({
    required this.session,
    required this.transfers,
    required this.emptyMessage,
  });

  final GameSession session;
  final List<TransferRecord> transfers;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return EmptyState(
        icon: Icons.swap_horiz,
        message: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: transfers.length,
      itemBuilder: (context, index) {
        final transfer = transfers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TransferTile(session: session, transfer: transfer),
        );
      },
    );
  }
}

class _TransferTile extends StatelessWidget {
  const _TransferTile({
    required this.session,
    required this.transfer,
  });

  final GameSession session;
  final TransferRecord transfer;

  @override
  Widget build(BuildContext context) {
    final player = session.registry.getPlayer(transfer.playerId);
    final playerName = player?.name ?? transfer.playerId.value;
    final from = session.clubName(transfer.fromClubId);
    final to = session.clubName(transfer.toClubId);
    final isIncoming = transfer.toClubId == GameSession.userClubId;
    final isOutgoing = transfer.fromClubId == GameSession.userClubId;
    final isUser = isIncoming || isOutgoing;
    final direction = isIncoming
        ? 'Entrada'
        : isOutgoing
            ? 'Saída'
            : 'Transferência';
    final feeLabel =
        transfer.isFree ? 'livre' : MoneyFormat.compact(transfer.fee);

    return Semantics(
      label: '$direction: $playerName, de $from para $to, $feeLabel, '
          '${DateFormatUtil.gameDate(transfer.date)}',
      excludeSemantics: true,
      child: Card(
        color: isUser
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
            : null,
        child: ListTile(
          leading: Icon(
            transfer.isFree
                ? Icons.person_off
                : isIncoming
                    ? Icons.arrow_downward
                    : isOutgoing
                        ? Icons.arrow_upward
                        : Icons.swap_horiz,
            color: isIncoming
                ? Colors.green
                : isOutgoing
                    ? Colors.orange
                    : null,
          ),
          title: Text(playerName),
          subtitle: Text(
            '$from → $to · ${DateFormatUtil.gameDate(transfer.date)}',
          ),
          trailing: transfer.isFree
              ? const Text('Livre')
              : Text(
                  MoneyFormat.compact(transfer.fee),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
