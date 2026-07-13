import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';

enum SquadSort { ability, age, name, form }

class SquadScreen extends StatefulWidget {
  const SquadScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends State<SquadScreen> {
  var _sort = SquadSort.ability;
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
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Plantel · ${session.squad.length} jogadores'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar jogador…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  for (final option in SquadSort.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(_sortLabel(option)),
                        selected: _sort == option,
                        onSelected: (_) => setState(() => _sort = option),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (squad.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text('Nenhum jogador corresponde à pesquisa.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final player = squad[index];
                    return _SquadPlayerCard(
                      player: player,
                      session: session,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PlayerDetailScreen(
                              controller: widget.controller,
                              playerId: player.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: squad.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Player> _filteredSquad(List<Player> squad) {
    final q = _query.toLowerCase();
    var list = q.isEmpty
        ? List<Player>.from(squad)
        : squad.where((p) => p.name.toLowerCase().contains(q)).toList();

    list.sort((a, b) {
      return switch (_sort) {
        SquadSort.ability =>
          b.currentAbility.compareTo(a.currentAbility),
        SquadSort.age => a.age.compareTo(b.age),
        SquadSort.name => a.name.compareTo(b.name),
        SquadSort.form => b.form.compareTo(a.form),
      };
    });
    return list;
  }

  static String _sortLabel(SquadSort sort) {
    return switch (sort) {
      SquadSort.ability => 'CA',
      SquadSort.age => 'Idade',
      SquadSort.name => 'Nome',
      SquadSort.form => 'Forma',
    };
  }
}

class _SquadPlayerCard extends StatelessWidget {
  const _SquadPlayerCard({
    required this.player,
    required this.session,
    required this.onTap,
  });

  final Player player;
  final GameSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gap = player.potentialAbility - player.currentAbility;
    final isWonderkid = gap >= 15;
    final isExpiring = player.contractEndYear <= session.seasonYear + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isWonderkid)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '${player.age} anos · PA ${player.potentialAbility} · '
                          '${MoneyFormat.perMonth(player.salary)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (player.isInjured)
                    _StatusBadge(
                      icon: Icons.healing,
                      label: '${player.injuredDaysRemaining}d',
                      color: theme.colorScheme.error,
                    )
                  else if (isExpiring)
                    _StatusBadge(
                      icon: Icons.assignment_late,
                      label: 'Expira',
                      color: theme.colorScheme.tertiary,
                    )
                  else
                    Text(
                      'Forma ${player.form}',
                      style: theme.textTheme.labelSmall,
                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
