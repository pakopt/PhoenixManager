import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

enum SquadSort { ability, age, name, form, morale, salary, contract }

class SquadScreen extends StatefulWidget {
  const SquadScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  var _sort = SquadSort.ability;
  var _ascending = false;
  var _query = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session!;
    final squad = _filteredSquad(session.squad);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar jogadores…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              tooltip: 'Limpar pesquisa',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (v) => setState(() => _query = v.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${session.squad.length} jogadores',
                  style: const TextStyle(
                    color: PhoenixColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: squad.isEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: _query.isEmpty
                        ? 'Ainda não há jogadores no plantel.'
                        : 'Nenhum jogador corresponde à pesquisa.',
                    action: _query.isEmpty
                        ? null
                        : TextButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar pesquisa'),
                          ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tableWidth = constraints.maxWidth < 980
                                ? 980.0
                                : constraints.maxWidth;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: tableWidth,
                                height: constraints.maxHeight,
                                child: Column(
                                  children: [
                                    _TableHeader(
                                      sort: _sort,
                                      ascending: _ascending,
                                      onSort: _toggleSort,
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: squad.length,
                                        itemBuilder: (context, index) {
                                          final player = squad[index];
                                          return _SquadRow(
                                            player: player,
                                            session: session,
                                            striped: index.isOdd,
                                            onTap: () =>
                                                _openPlayer(player.id),
                                            onRenew: () =>
                                                _openPlayer(player.id),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      _FooterBar(
                        showing: squad.length,
                        total: session.squad.length,
                        filtered: _query.isNotEmpty,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleSort(SquadSort sort) {
    UiFeedback.tap();
    setState(() {
      if (_sort == sort) {
        _ascending = !_ascending;
      } else {
        _sort = sort;
        _ascending = sort == SquadSort.name || sort == SquadSort.age;
      }
    });
  }

  void _openPlayer(PlayerId id) {
    UiFeedback.tap();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerDetailScreen(
          controller: widget.controller,
          playerId: id,
        ),
      ),
    );
  }

  List<Player> _filteredSquad(List<Player> squad) {
    final q = _query.toLowerCase();
    var list = q.isEmpty
        ? List<Player>.from(squad)
        : squad.where((p) => p.name.toLowerCase().contains(q)).toList();

    int cmp(Player a, Player b) {
      final raw = switch (_sort) {
        SquadSort.ability =>
          a.currentAbility.compareTo(b.currentAbility),
        SquadSort.age => a.age.compareTo(b.age),
        SquadSort.name => a.name.compareTo(b.name),
        SquadSort.form => a.form.compareTo(b.form),
        SquadSort.morale => a.morale.compareTo(b.morale),
        SquadSort.salary => a.salary.compareTo(b.salary),
        SquadSort.contract =>
          a.contractEndYear.compareTo(b.contractEndYear),
      };
      return _ascending ? raw : -raw;
    }

    list.sort(cmp);
    return list;
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.sort,
    required this.ascending,
    required this.onSort,
  });

  final SquadSort sort;
  final bool ascending;
  final ValueChanged<SquadSort> onSort;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: PhoenixColors.card,
        border: Border(
          bottom: BorderSide(color: PhoenixColors.cardBorder),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _HeadCell(
            label: 'JOGADOR',
            flex: 4,
            sort: SquadSort.name,
            active: sort,
            ascending: ascending,
            onSort: onSort,
          ),
          _HeadCell(
            label: 'IDADE',
            width: 56,
            sort: SquadSort.age,
            active: sort,
            ascending: ascending,
            onSort: onSort,
            align: TextAlign.center,
          ),
          _HeadCell(
            label: 'OVR',
            width: 52,
            sort: SquadSort.ability,
            active: sort,
            ascending: ascending,
            onSort: onSort,
            align: TextAlign.center,
          ),
          _HeadCell(
            label: 'PA',
            width: 44,
            align: TextAlign.center,
          ),
          _HeadCell(
            label: 'FORMA',
            width: 64,
            sort: SquadSort.form,
            active: sort,
            ascending: ascending,
            onSort: onSort,
            align: TextAlign.center,
          ),
          _HeadCell(
            label: 'MORAL',
            width: 100,
            sort: SquadSort.morale,
            active: sort,
            ascending: ascending,
            onSort: onSort,
          ),
          _HeadCell(
            label: 'CONTRATO',
            width: 80,
            sort: SquadSort.contract,
            active: sort,
            ascending: ascending,
            onSort: onSort,
            align: TextAlign.center,
          ),
          _HeadCell(
            label: 'SALÁRIO',
            width: 88,
            sort: SquadSort.salary,
            active: sort,
            ascending: ascending,
            onSort: onSort,
            align: TextAlign.end,
          ),
          const SizedBox(width: 120),
        ],
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell({
    required this.label,
    this.flex,
    this.width,
    this.sort,
    this.active,
    this.ascending = false,
    this.onSort,
    this.align = TextAlign.start,
  });

  final String label;
  final int? flex;
  final double? width;
  final SquadSort? sort;
  final SquadSort? active;
  final bool ascending;
  final ValueChanged<SquadSort>? onSort;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final isActive = sort != null && sort == active;
    final child = InkWell(
      onTap: sort == null || onSort == null ? null : () => onSort!(sort!),
      child: Row(
        mainAxisAlignment: switch (align) {
          TextAlign.center => MainAxisAlignment.center,
          TextAlign.end || TextAlign.right => MainAxisAlignment.end,
          _ => MainAxisAlignment.start,
        },
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isActive ? PhoenixColors.positive : PhoenixColors.muted,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: PhoenixColors.positive,
            ),
          ],
        ],
      ),
    );

    if (flex != null) {
      return Expanded(flex: flex!, child: child);
    }
    return SizedBox(width: width, child: child);
  }
}

class _SquadRow extends StatefulWidget {
  const _SquadRow({
    required this.player,
    required this.session,
    required this.striped,
    required this.onTap,
    required this.onRenew,
  });

  final Player player;
  final GameSession session;
  final bool striped;
  final VoidCallback onTap;
  final VoidCallback onRenew;

  @override
  State<_SquadRow> createState() => _SquadRowState();
}

class _SquadRowState extends State<_SquadRow> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final session = widget.session;
    final gap = player.potentialAbility - player.currentAbility;
    final isWonderkid = gap >= 15;
    final isExpiring = player.contractEndYear <= session.seasonYear + 1;
    final canRenew = session.canRenewPlayer(player);

    final bg = _hovered
        ? PhoenixColors.seed.withValues(alpha: 0.1)
        : widget.striped
            ? PhoenixColors.card.withValues(alpha: 0.45)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: PhoenixColors.cardBorder),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: PhoenixColors.seed.withValues(
                          alpha: 0.35,
                        ),
                        child: Text(
                          player.name.characters.first.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: PhoenixColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    player.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: PhoenixColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isWonderkid) ...[
                                  const SizedBox(width: 6),
                                  const _Tag(
                                    label: 'ESTRELA',
                                    color: PhoenixColors.draw,
                                  ),
                                ],
                                if (player.isInjured) ...[
                                  const SizedBox(width: 6),
                                  _Tag(
                                    label: 'LESÃO ${player.injuredDaysRemaining}d',
                                    color: PhoenixColors.negative,
                                  ),
                                ] else if (isExpiring) ...[
                                  const SizedBox(width: 6),
                                  const _Tag(
                                    label: 'EXPIRA',
                                    color: PhoenixColors.warning,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${player.age}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: PhoenixColors.textSecondary),
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Center(child: _OvrBadge(value: player.currentAbility)),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '${player.potentialAbility}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: PhoenixColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    '${player.form}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _statColor(player.form),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: _MoraleBar(value: player.morale),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${player.contractEndYear}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isExpiring
                          ? PhoenixColors.warning
                          : PhoenixColors.textSecondary,
                      fontWeight:
                          isExpiring ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 88,
                  child: Text(
                    MoneyFormat.compact(player.salary),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: PhoenixColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (canRenew)
                        TextButton(
                          onPressed: widget.onRenew,
                          style: TextButton.styleFrom(
                            foregroundColor: PhoenixColors.positive,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Renovar'),
                        ),
                      TextButton(
                        onPressed: widget.onTap,
                        style: TextButton.styleFrom(
                          foregroundColor: PhoenixColors.muted,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statColor(int value) {
    if (value >= 75) {
      return PhoenixColors.positive;
    }
    if (value >= 50) {
      return PhoenixColors.draw;
    }
    return PhoenixColors.warning;
  }
}

class _OvrBadge extends StatelessWidget {
  const _OvrBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PhoenixColors.seed.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _MoraleBar extends StatelessWidget {
  const _MoraleBar({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final t = (value.clamp(0, 100)) / 100;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: t,
              minHeight: 8,
              backgroundColor: PhoenixColors.cardBorder,
              color: value >= 70
                  ? PhoenixColors.positive
                  : value >= 45
                      ? PhoenixColors.draw
                      : PhoenixColors.warning,
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PhoenixColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.showing,
    required this.total,
    required this.filtered,
  });

  final int showing;
  final int total;
  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final label = filtered
        ? 'A mostrar $showing de $total jogadores'
        : 'A mostrar 1–$showing de $total jogadores';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: PhoenixColors.cardBorder),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: PhoenixColors.muted,
          fontSize: 12,
        ),
      ),
    );
  }
}
