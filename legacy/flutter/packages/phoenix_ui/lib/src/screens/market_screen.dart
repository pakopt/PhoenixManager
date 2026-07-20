import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

/// Transferências estilo FootSim × Phoenix.
class MarketScreen extends StatefulWidget {
  const MarketScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _tabIndex = 0;
  var _search = '';
  var _visibleLimit = 40;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final finance = session.userFinance;
    final isOpen = session.isTransferWindowOpen;
    final windowMonths = session.transferConfig.windowMonths.toList()..sort();
    final clubTransfers = session.clubTransfers;
    final allTransfers = session.registry.transfers.reversed.toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenPageHeader(
            title: 'Transferências',
            subtitle: isOpen ? 'Janela aberta · mercado activo' : 'Janela fechada',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TransferWindowBanner(
                  isOpen: isOpen,
                  windowMonths: windowMonths,
                  currentMonth: session.currentDate.month,
                  transfersUsed:
                      finance?.transfersCompletedThisWindow ?? 0,
                  transfersMax:
                      session.transferConfig.maxTransfersPerClubPerWindow,
                ),
                const SizedBox(height: 12),
                _FinanceSummaryRow(session: session),
                const SizedBox(height: 12),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Mercado')),
                    ButtonSegment(value: 1, label: Text('Livres')),
                    ButtonSegment(value: 2, label: Text('Histórico')),
                  ],
                  selected: {_tabIndex},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _tabIndex = selection.first;
                      _search = '';
                      _visibleLimit = 40;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: switch (_tabIndex) {
              0 => _MarketList(
                  session: session,
                  controller: widget.controller,
                  players: _filterPlayers(session.marketPlayers),
                  totalCount: session.marketPlayers.length,
                  search: _search,
                  onSearch: (v) => setState(() {
                    _search = v;
                    _visibleLimit = 40;
                  }),
                  visibleLimit: _visibleLimit,
                  onLoadMore: () => setState(() => _visibleLimit += 40),
                  isFreeTab: false,
                  windowOpen: isOpen,
                  onBid: (player) => _confirmBuy(context, player),
                ),
              1 => _MarketList(
                  session: session,
                  controller: widget.controller,
                  players: _filterPlayers(session.freeAgentCandidates),
                  totalCount: session.freeAgentCandidates.length,
                  search: _search,
                  onSearch: (v) => setState(() {
                    _search = v;
                    _visibleLimit = 40;
                  }),
                  visibleLimit: _visibleLimit,
                  onLoadMore: () => setState(() => _visibleLimit += 40),
                  isFreeTab: true,
                  windowOpen: isOpen,
                  onBid: (player) => _confirmFreeSign(context, player),
                ),
              _ => _TransferHistory(
                  session: session,
                  clubTransfers: clubTransfers,
                  allTransfers: allTransfers,
                ),
            },
          ),
        ],
      ),
    );
  }

  List<Player> _filterPlayers(List<Player> source) {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) {
      return source;
    }
    return source.where((p) {
      final club = widget.controller.session!.registry.getClub(p.clubId);
      final clubName = club?.displayShortName.toLowerCase() ?? '';
      return p.name.toLowerCase().contains(q) || clubName.contains(q);
    }).toList();
  }

  Future<void> _confirmBuy(BuildContext context, Player player) async {
    final session = widget.controller.session!;
    final ask = session.playerAskPrice(player);
    final club = session.registry.getClub(player.clubId);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fazer oferta'),
        content: Text(
          'Oferecer ${MoneyFormat.compact(ask)} por ${player.name}'
          '${club != null ? ' (${club.displayShortName})' : ''}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    final error = widget.controller.tryBuyPlayer(player.id);
    UiFeedback.tap();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error ?? '${player.name} contratado por ${MoneyFormat.compact(ask)}.',
        ),
      ),
    );
  }

  Future<void> _confirmFreeSign(BuildContext context, Player player) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assinar a custo zero'),
        content: Text(
          'Contratar ${player.name} sem taxa de transferência?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Assinar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) {
      return;
    }
    final error = widget.controller.trySignFreeAgent(player.id);
    UiFeedback.tap();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? '${player.name} assinou a custo zero.'),
      ),
    );
  }
}

class _FinanceSummaryRow extends StatelessWidget {
  const _FinanceSummaryRow({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final finance = session.userFinance;
    final balance = finance?.balance ?? 0;
    final wages = finance?.monthlyWages ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        final cards = [
          _SummaryCard(
            label: 'Orçamento',
            value: MoneyFormat.compact(balance),
            hint: 'Disponível para compras',
          ),
          _SummaryCard(
            label: 'Salários',
            value: '${MoneyFormat.compact(wages)}/mês',
            hint: 'Massa salarial',
          ),
          _SummaryCard(
            label: 'Saldo',
            value: MoneyFormat.compact(balance),
            hint: 'Conta corrente',
          ),
          _SummaryCard(
            label: 'Plantel',
            value: '${session.squad.length}',
            hint: 'Jogadores',
          ),
        ];
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 8),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 8),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: PhoenixColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(fontSize: 10, color: PhoenixColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TransferWindowBanner extends StatelessWidget {
  const _TransferWindowBanner({
    required this.isOpen,
    required this.windowMonths,
    required this.currentMonth,
    required this.transfersUsed,
    required this.transfersMax,
  });

  final bool isOpen;
  final List<int> windowMonths;
  final int currentMonth;
  final int transfersUsed;
  final int transfersMax;

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    final windows = windowMonths.map((m) => monthNames[m - 1]).join(' · ');
    final title =
        isOpen ? 'Janela de transferências aberta' : 'Mercado fechado';
    final subtitle = isOpen
        ? '${monthNames[currentMonth - 1]} · $transfersUsed/$transfersMax negócios esta janela'
        : 'Janelas: $windows';

    return Semantics(
      label: '$title. $subtitle',
      child: Card(
        color: isOpen
            ? Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.35)
            : null,
        child: ListTile(
          leading: Icon(
            isOpen ? Icons.lock_open : Icons.lock_outline,
            color: isOpen
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          title: Text(title),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}

class _MarketList extends StatelessWidget {
  const _MarketList({
    required this.session,
    required this.controller,
    required this.players,
    required this.totalCount,
    required this.search,
    required this.onSearch,
    required this.visibleLimit,
    required this.onLoadMore,
    required this.isFreeTab,
    required this.windowOpen,
    required this.onBid,
  });

  final GameSession session;
  final GameController controller;
  final List<Player> players;
  final int totalCount;
  final String search;
  final ValueChanged<String> onSearch;
  final int visibleLimit;
  final VoidCallback onLoadMore;
  final bool isFreeTab;
  final bool windowOpen;
  final Future<void> Function(Player player) onBid;

  @override
  Widget build(BuildContext context) {
    final shown = players.take(visibleLimit).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Pesquisar jogadores…',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              suffixText: '${players.length}/$totalCount',
            ),
            onChanged: onSearch,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: players.isEmpty
              ? EmptyState(
                  icon: Icons.person_search_outlined,
                  message: isFreeTab
                      ? 'Sem jogadores livres nesta época.'
                      : 'Sem jogadores no mercado.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: shown.length + (players.length > shown.length ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= shown.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: OutlinedButton(
                          onPressed: onLoadMore,
                          child: Text(
                            'Mostrar mais (${players.length - shown.length})',
                          ),
                        ),
                      );
                    }
                    final player = shown[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _MarketPlayerTile(
                        session: session,
                        player: player,
                        isFree: isFreeTab,
                        windowOpen: windowOpen,
                        onOpen: () {
                          UiFeedback.tap();
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PlayerDetailScreen(
                                controller: controller,
                                playerId: player.id,
                              ),
                            ),
                          );
                        },
                        onBid: () => onBid(player),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MarketPlayerTile extends StatelessWidget {
  const _MarketPlayerTile({
    required this.session,
    required this.player,
    required this.isFree,
    required this.windowOpen,
    required this.onOpen,
    required this.onBid,
  });

  final GameSession session;
  final Player player;
  final bool isFree;
  final bool windowOpen;
  final VoidCallback onOpen;
  final VoidCallback onBid;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerDisplayProfile.from(player);
    final club = session.registry.getClub(player.clubId);
    final value = session.playerMarketValue(player);
    final ask = session.playerAskPrice(player);
    final stars = ((club?.reputation ?? 40) / 20).round().clamp(1, 5);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: PhoenixColors.seed.withValues(alpha: 0.22),
                    child: Text(
                      '${player.currentAbility}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            if (club != null) ...[
                              ClubCrest(
                                club: club,
                                size: 14,
                                showBorder: false,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                club?.displayShortName ??
                                    session.clubName(player.clubId),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PhoenixColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _PosBadge(code: profile.position),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _MetaChip(label: 'Idade', value: '${player.age}'),
                  const SizedBox(width: 6),
                  _MetaChip(
                    label: 'Valor',
                    value: MoneyFormat.compact(value),
                  ),
                  const SizedBox(width: 6),
                  _MetaChip(
                    label: 'Salário',
                    value: MoneyFormat.compact(player.salary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Contrato ${player.contractEndYear}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PhoenixColors.muted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...List.generate(
                    5,
                    (i) => Icon(
                      i < stars ? Icons.star : Icons.star_border,
                      size: 14,
                      color: i < stars
                          ? PhoenixColors.draw
                          : PhoenixColors.muted,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: windowOpen ? onBid : null,
                    child: Text(
                      isFree ? 'Assinar' : 'Fazer oferta',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: windowOpen
                            ? PhoenixColors.seed
                            : PhoenixColors.muted,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isFree)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Pedido: ${MoneyFormat.compact(ask)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: PhoenixColors.muted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosBadge extends StatelessWidget {
  const _PosBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final color = switch (code) {
      'GR' => const Color(0xFFF9A825),
      'DF' => const Color(0xFF1E88E5),
      'MD' => const Color(0xFFFB8C00),
      'MO' => const Color(0xFF8E24AA),
      'PL' => const Color(0xFFE53935),
      'EX' => const Color(0xFFD81B60),
      _ => PhoenixColors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: PhoenixColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PhoenixColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: PhoenixColors.muted),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransferHistory extends StatefulWidget {
  const _TransferHistory({
    required this.session,
    required this.clubTransfers,
    required this.allTransfers,
  });

  final GameSession session;
  final List<TransferRecord> clubTransfers;
  final List<TransferRecord> allTransfers;

  @override
  State<_TransferHistory> createState() => _TransferHistoryState();
}

class _TransferHistoryState extends State<_TransferHistory> {
  var _onlyClub = true;

  @override
  Widget build(BuildContext context) {
    final transfers =
        _onlyClub ? widget.clubTransfers : widget.allTransfers;
    final isOpen = widget.session.isTransferWindowOpen;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              label: Text(
                _onlyClub
                    ? 'Só o meu clube (${widget.clubTransfers.length})'
                    : 'Toda a liga (${widget.allTransfers.length})',
              ),
              selected: _onlyClub,
              onSelected: (v) => setState(() => _onlyClub = v),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: transfers.isEmpty
              ? EmptyState(
                  icon: Icons.swap_horiz,
                  message: _onlyClub
                      ? 'Sem movimentos envolvendo o ${widget.session.userClub.name}.'
                      : isOpen
                          ? 'Janela aberta — ainda sem negócios na liga.'
                          : 'Sem histórico nesta época.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: transfers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _TransferTile(
                        session: widget.session,
                        transfer: transfers[index],
                      ),
                    );
                  },
                ),
        ),
      ],
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
    final fromClub = session.registry.getClub(transfer.fromClubId);
    final toClub = session.registry.getClub(transfer.toClubId);
    final from = fromClub?.displayShortName ??
        session.clubName(transfer.fromClubId);
    final to =
        toClub?.displayShortName ?? session.clubName(transfer.toClubId);
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
          subtitle: Row(
            children: [
              if (fromClub != null) ...[
                ClubCrest(club: fromClub, size: 16, showBorder: false),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  from,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('→', style: TextStyle(fontSize: 12)),
              ),
              if (toClub != null) ...[
                ClubCrest(club: toClub, size: 16, showBorder: false),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  to,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(
                ' · ${DateFormatUtil.gameDate(transfer.date)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          isThreeLine: false,
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
