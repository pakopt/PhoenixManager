import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/tactics_board.dart';
import 'package:phoenix_ui/src/game/tactics_prefs.dart';
import 'package:phoenix_ui/src/screens/player_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

/// Ecrã de táctica estilo FootSim × Phoenix (apresentação).
class TacticsScreen extends StatefulWidget {
  const TacticsScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<TacticsScreen> createState() => _TacticsScreenState();
}

class _TacticsScreenState extends State<TacticsScreen> {
  var _formation = TacticsCatalog.formations[1]; // 4-4-2 Diamante
  var _mentality = 1; // Defensiva
  var _tempo = 1; // Normal
  var _corner = 0;
  var _freeKick = 0;
  var _penalty = 0;
  TacticsLineup? _lineup;
  var _prefsLoaded = false;
  int? _loadedSlot;

  /// Posições livres no campo (playerId → x/y 0–1).
  final Map<String, PitchPos> _pitchPositions = {};
  var _pitchDragging = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onController);
    _loadPrefs();
    _rebuildLineup();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (!mounted) {
      return;
    }
    if (_loadedSlot != null &&
        _loadedSlot != widget.controller.activeSlot) {
      _loadPrefs();
      return;
    }
    _rebuildLineup();
  }

  Future<void> _loadPrefs() async {
    final slot = widget.controller.activeSlot;
    final snap = await TacticsPrefs.load(slot);
    if (!mounted) {
      return;
    }
    if (snap == null) {
      setState(() {
        _loadedSlot = slot;
        _formation = TacticsCatalog.formations[1];
        _mentality = 1;
        _tempo = 1;
        _corner = 0;
        _freeKick = 0;
        _penalty = 0;
        _pitchPositions.clear();
        _prefsLoaded = true;
      });
      _rebuildLineup();
      return;
    }
    final formation = TacticsCatalog.formations.firstWhere(
      (f) => f.id == snap.formationId,
      orElse: () => TacticsCatalog.formations[1],
    );
    setState(() {
      _loadedSlot = slot;
      _formation = formation;
      _mentality =
          snap.mentality.clamp(0, TacticsCatalog.mentalities.length - 1);
      _tempo = snap.tempo.clamp(0, TacticsCatalog.tempos.length - 1);
      _corner = snap.corner.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _freeKick =
          snap.freeKick.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _penalty =
          snap.penalty.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _pitchPositions
        ..clear()
        ..addAll(snap.playerPositions);
      _prefsLoaded = true;
    });
    _rebuildLineup();
  }

  void _seedDefaultPositions({required bool force}) {
    final lineup = _lineup;
    if (lineup == null) {
      return;
    }
    for (var i = 0; i < lineup.starters.length && i < _formation.slots.length; i++) {
      final id = lineup.starters[i].id.value;
      final slot = _formation.slots[i];
      if (force || !_pitchPositions.containsKey(id)) {
        _pitchPositions[id] = PitchPos(slot.x, slot.y);
      }
    }
  }

  void _rebuildLineup() {
    if (!mounted) {
      return;
    }
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    setState(() {
      _lineup = TacticsLineup.auto(
        squad: session.squad,
        formation: _formation,
      );
      _seedDefaultPositions(force: false);
    });
  }

  void _setFormation(TacticsFormation formation) {
    UiFeedback.tap();
    setState(() {
      _formation = formation;
      final session = widget.controller.session;
      if (session != null) {
        _lineup = TacticsLineup.auto(
          squad: session.squad,
          formation: formation,
        );
      }
      _seedDefaultPositions(force: true);
    });
  }

  void _resetPitchPositions() {
    UiFeedback.tap();
    setState(() => _seedDefaultPositions(force: true));
  }

  void _movePlayer(String playerId, PitchPos pos) {
    setState(() => _pitchPositions[playerId] = pos.clamp01());
  }

  void _setPitchDragging(bool value) {
    if (_pitchDragging == value) {
      return;
    }
    setState(() => _pitchDragging = value);
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

  Future<void> _saveTactics() async {
    UiFeedback.action();
    await TacticsPrefs.save(
      widget.controller.activeSlot,
      TacticsSnapshot(
        formationId: _formation.id,
        mentality: _mentality,
        tempo: _tempo,
        corner: _corner,
        freeKick: _freeKick,
        penalty: _penalty,
        playerPositions: Map<String, PitchPos>.from(_pitchPositions),
      ),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Táctica guardada · ${_formation.name} · '
          '${TacticsCatalog.mentalities[_mentality]} · '
          '${TacticsCatalog.tempos[_tempo]}',
        ),
      ),
    );
  }

  Widget _pitch({required List<Player> starters}) {
    return _PitchPanel(
      formation: _formation,
      starters: starters,
      positions: _pitchPositions,
      onMoved: _movePlayer,
      onDragState: _setPitchDragging,
      onOpenPlayer: _openPlayer,
      onResetPositions: _resetPitchPositions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.controller.session;
    if (session == null) {
      return const SizedBox.shrink();
    }
    final lineup = _lineup ??
        TacticsLineup.auto(squad: session.squad, formation: _formation);

    if (session.squad.isEmpty) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.sports_soccer_outlined,
          message: 'Sem jogadores no plantel para montar a táctica.',
        ),
      );
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenPageHeader(
            title: 'Táctica',
            subtitle: 'Formação e instruções',
            trailing: FilledButton.icon(
              onPressed: _prefsLoaded ? _saveTactics : null,
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Guardar táctica'),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                final medium = constraints.maxWidth >= 820;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 280,
                        child: _SettingsPanel(
                          formation: _formation,
                          mentality: _mentality,
                          tempo: _tempo,
                          corner: _corner,
                          freeKick: _freeKick,
                          penalty: _penalty,
                          onFormation: _setFormation,
                          onMentality: (v) => setState(() => _mentality = v),
                          onTempo: (v) => setState(() => _tempo = v),
                          onCorner: (v) => setState(() => _corner = v),
                          onFreeKick: (v) => setState(() => _freeKick = v),
                          onPenalty: (v) => setState(() => _penalty = v),
                        ),
                      ),
                      Expanded(
                        child: _SquadPanel(
                          formation: _formation,
                          lineup: lineup,
                          onAuto: _rebuildLineup,
                          onOpenPlayer: _openPlayer,
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth * 0.34,
                        child: _pitch(starters: lineup.starters),
                      ),
                    ],
                  );
                }
                if (medium) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: _SettingsPanel(
                                formation: _formation,
                                mentality: _mentality,
                                tempo: _tempo,
                                corner: _corner,
                                freeKick: _freeKick,
                                penalty: _penalty,
                                onFormation: _setFormation,
                                onMentality: (v) =>
                                    setState(() => _mentality = v),
                                onTempo: (v) => setState(() => _tempo = v),
                                onCorner: (v) => setState(() => _corner = v),
                                onFreeKick: (v) =>
                                    setState(() => _freeKick = v),
                                onPenalty: (v) => setState(() => _penalty = v),
                                compact: true,
                              ),
                            ),
                            Expanded(
                              child: _SquadPanel(
                                formation: _formation,
                                lineup: lineup,
                                onAuto: _rebuildLineup,
                                onOpenPlayer: _openPlayer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: _pitch(starters: lineup.starters),
                      ),
                    ],
                  );
                }
                return ListView(
                  physics: _pitchDragging
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    SizedBox(
                      height: 240,
                      child: _SettingsPanel(
                        formation: _formation,
                        mentality: _mentality,
                        tempo: _tempo,
                        corner: _corner,
                        freeKick: _freeKick,
                        penalty: _penalty,
                        onFormation: _setFormation,
                        onMentality: (v) => setState(() => _mentality = v),
                        onTempo: (v) => setState(() => _tempo = v),
                        onCorner: (v) => setState(() => _corner = v),
                        onFreeKick: (v) => setState(() => _freeKick = v),
                        onPenalty: (v) => setState(() => _penalty = v),
                        compact: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AspectRatio(
                        aspectRatio: 0.72,
                        child: _pitch(starters: lineup.starters),
                      ),
                    ),
                    SizedBox(
                      height: 420,
                      child: _SquadPanel(
                        formation: _formation,
                        lineup: lineup,
                        onAuto: _rebuildLineup,
                        onOpenPlayer: _openPlayer,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.formation,
    required this.mentality,
    required this.tempo,
    required this.corner,
    required this.freeKick,
    required this.penalty,
    required this.onFormation,
    required this.onMentality,
    required this.onTempo,
    required this.onCorner,
    required this.onFreeKick,
    required this.onPenalty,
    this.compact = false,
  });

  final TacticsFormation formation;
  final int mentality;
  final int tempo;
  final int corner;
  final int freeKick;
  final int penalty;
  final ValueChanged<TacticsFormation> onFormation;
  final ValueChanged<int> onMentality;
  final ValueChanged<int> onTempo;
  final ValueChanged<int> onCorner;
  final ValueChanged<int> onFreeKick;
  final ValueChanged<int> onPenalty;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 12, 16),
      children: [
        const _SectionLabel('Formação'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: formation.id,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: [
            for (final f in TacticsCatalog.formations)
              DropdownMenuItem(value: f.id, child: Text(f.name)),
          ],
          onChanged: (id) {
            if (id == null) {
              return;
            }
            final next = TacticsCatalog.formations.firstWhere((f) => f.id == id);
            onFormation(next);
          },
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Mentalidade'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var i = 0; i < TacticsCatalog.mentalities.length; i++)
              ChoiceChip(
                label: Text(
                  compact
                      ? TacticsCatalog.mentalityShort[i]
                      : TacticsCatalog.mentalities[i],
                  style: const TextStyle(fontSize: 11),
                ),
                selected: mentality == i,
                onSelected: (_) {
                  UiFeedback.tap();
                  onMentality(i);
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Ritmo'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: [
            for (var i = 0; i < TacticsCatalog.tempos.length; i++)
              ChoiceChip(
                label: Text(TacticsCatalog.tempos[i]),
                selected: tempo == i,
                onSelected: (_) {
                  UiFeedback.tap();
                  onTempo(i);
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Bolas paradas'),
        const SizedBox(height: 8),
        _SetPieceDropdown(
          label: 'Cantos',
          value: corner,
          onChanged: onCorner,
        ),
        const SizedBox(height: 8),
        _SetPieceDropdown(
          label: 'Livres',
          value: freeKick,
          onChanged: onFreeKick,
        ),
        const SizedBox(height: 8),
        _SetPieceDropdown(
          label: 'Penáltis',
          value: penalty,
          onChanged: onPenalty,
        ),
      ],
    );
  }
}

class _SetPieceDropdown extends StatelessWidget {
  const _SetPieceDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(color: PhoenixColors.muted, fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: value,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: [
              for (var i = 0; i < TacticsCatalog.setPieceOptions.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(TacticsCatalog.setPieceOptions[i]),
                ),
            ],
            onChanged: (v) {
              if (v == null) {
                return;
              }
              UiFeedback.tap();
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _SquadPanel extends StatelessWidget {
  const _SquadPanel({
    required this.formation,
    required this.lineup,
    required this.onAuto,
    required this.onOpenPlayer,
  });

  final TacticsFormation formation;
  final TacticsLineup lineup;
  final VoidCallback onAuto;
  final ValueChanged<PlayerId> onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Text(
                'PLANTEL',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {
                  UiFeedback.tap();
                  onAuto();
                },
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Auto'),
              ),
            ],
          ),
        ),
        const _TableHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              const _GroupLabel('Titulares'),
              for (var i = 0; i < lineup.starters.length; i++)
                _PlayerRow(
                  slot: i < formation.slots.length
                      ? formation.slots[i].label
                      : '—',
                  player: lineup.starters[i],
                  positionOverride: i < formation.slots.length
                      ? formation.slots[i].label
                      : null,
                  onTap: () => onOpenPlayer(lineup.starters[i].id),
                ),
              if (lineup.reserves.isNotEmpty) ...[
                const _GroupLabel('Suplentes'),
                for (final player in lineup.reserves)
                  _PlayerRow(
                    slot: 'SUP',
                    player: player,
                    onTap: () => onOpenPlayer(player.id),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: PhoenixColors.headerBar,
      child: const Row(
        children: [
          SizedBox(width: 44, child: Text('SLOT', style: _headerStyle)),
          SizedBox(width: 52, child: Text('FORMA', style: _headerStyle)),
          Expanded(child: Text('NOME', style: _headerStyle)),
          SizedBox(width: 40, child: Text('POS', style: _headerStyle)),
          SizedBox(width: 40, child: Text('OVR', style: _headerStyle)),
        ],
      ),
    );
  }
}

const _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w700,
  color: PhoenixColors.muted,
  letterSpacing: 0.4,
);

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: PhoenixColors.muted,
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.slot,
    required this.player,
    required this.onTap,
    this.positionOverride,
  });

  final String slot;
  final Player player;
  final VoidCallback onTap;
  final String? positionOverride;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerDisplayProfile.from(player);
    final pos = positionOverride ?? profile.position;
    final ovrColor = player.currentAbility >= 72
        ? PhoenixColors.positive
        : player.currentAbility >= 62
            ? PhoenixColors.warning
            : PhoenixColors.muted;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: PhoenixColors.cardBorder),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                slot,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 52,
              child: Text(
                '${player.form}%',
                style: TextStyle(
                  color: player.form >= 70
                      ? PhoenixColors.positive
                      : PhoenixColors.muted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Text(
                player.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                pos,
                style: const TextStyle(
                  color: PhoenixColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: ovrColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ovrColor.withValues(alpha: 0.45)),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${player.currentAbility}',
                  style: TextStyle(
                    color: ovrColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchPanel extends StatelessWidget {
  const _PitchPanel({
    required this.formation,
    required this.starters,
    required this.positions,
    required this.onMoved,
    required this.onDragState,
    required this.onOpenPlayer,
    required this.onResetPositions,
  });

  final TacticsFormation formation;
  final List<Player> starters;
  final Map<String, PitchPos> positions;
  final void Function(String playerId, PitchPos pos) onMoved;
  final ValueChanged<bool> onDragState;
  final ValueChanged<PlayerId> onOpenPlayer;
  final VoidCallback onResetPositions;

  PitchPos _posFor(Player player, int index) {
    final saved = positions[player.id.value];
    if (saved != null) {
      return saved;
    }
    if (index < formation.slots.length) {
      final slot = formation.slots[index];
      return PitchPos(slot.x, slot.y);
    }
    return const PitchPos(0.5, 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1F12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PhoenixColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              if (size.width < 8 || size.height < 8) {
                return const SizedBox.shrink();
              }
              final count = formation.slots.length < starters.length
                  ? formation.slots.length
                  : starters.length;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _PitchPainter()),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: onResetPositions,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restart_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Repor',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Arrasta para posicionar · toca para ficha',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  for (var i = 0; i < count; i++)
                    _PitchPlayerMarker(
                      key: ValueKey(starters[i].id.value),
                      slotLabel: formation.slots[i].label,
                      player: starters[i],
                      position: _posFor(starters[i], i),
                      pitchSize: size,
                      onMoved: (pos) => onMoved(starters[i].id.value, pos),
                      onDragState: onDragState,
                      onTap: () => onOpenPlayer(starters[i].id),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PitchPlayerMarker extends StatefulWidget {
  const _PitchPlayerMarker({
    super.key,
    required this.slotLabel,
    required this.player,
    required this.position,
    required this.pitchSize,
    required this.onMoved,
    required this.onDragState,
    required this.onTap,
  });

  final String slotLabel;
  final Player player;
  final PitchPos position;
  final Size pitchSize;
  final ValueChanged<PitchPos> onMoved;
  final ValueChanged<bool> onDragState;
  final VoidCallback onTap;

  @override
  State<_PitchPlayerMarker> createState() => _PitchPlayerMarkerState();
}

class _PitchPlayerMarkerState extends State<_PitchPlayerMarker> {
  var _dragging = false;
  var _dragged = false;

  static String _surname(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    return parts.last;
  }

  @override
  Widget build(BuildContext context) {
    final pitchSize = widget.pitchSize;
    final compact = pitchSize.width < 280;
    final markerW = compact ? 56.0 : 68.0;
    final markerH = compact ? 52.0 : 58.0;
    final center = _PitchGeom.normalizedToOffset(widget.position, pitchSize);
    final left = _safeClamp(
      center.dx - markerW / 2,
      2,
      pitchSize.width - markerW - 2,
    );
    final top = _safeClamp(
      center.dy - markerH / 2,
      2,
      pitchSize.height - markerH - 2,
    );

    return Positioned(
      left: left,
      top: top,
      width: markerW,
      height: markerH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) {
          widget.onDragState(true);
          setState(() {
            _dragging = true;
            _dragged = false;
          });
        },
        onPanUpdate: (details) {
          _dragged = true;
          final area = _PitchGeom.playArea(pitchSize);
          if (area.width <= 0 || area.height <= 0) {
            return;
          }
          final next = PitchPos(
            widget.position.x + details.delta.dx / area.width,
            widget.position.y - details.delta.dy / area.height,
          ).clamp01();
          widget.onMoved(next);
        },
        onPanEnd: (_) {
          final wasDrag = _dragged;
          widget.onDragState(false);
          setState(() {
            _dragging = false;
            _dragged = false;
          });
          if (!wasDrag) {
            widget.onTap();
          } else {
            UiFeedback.tap();
          }
        },
        onPanCancel: () {
          widget.onDragState(false);
          setState(() {
            _dragging = false;
            _dragged = false;
          });
        },
        child: AnimatedScale(
          scale: _dragging ? 1.08 : 1,
          duration: const Duration(milliseconds: 120),
          child: Opacity(
            opacity: _dragging ? 0.95 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: compact ? 30 : 34,
                      height: compact ? 30 : 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF122018),
                        border: Border.all(
                          color: _dragging
                              ? Colors.white
                              : PhoenixColors.seed,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: _dragging ? 8 : 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.slotLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: compact ? 9 : 10,
                          color: PhoenixColors.positive,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: PhoenixColors.seed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.player.currentAbility}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  constraints: BoxConstraints(maxWidth: markerW),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _surname(widget.player.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 9 : 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double _safeClamp(double value, double min, double max) {
  if (max < min) {
    return min;
  }
  return value.clamp(min, max);
}

/// Geometria do relvado — partilhada entre painter e markers.
abstract final class _PitchGeom {
  static const insetX = 0.07;
  static const insetY = 0.05;
  static const insetW = 0.86;
  static const insetH = 0.90;

  static Rect playArea(Size size) {
    return Rect.fromLTWH(
      size.width * insetX,
      size.height * insetY,
      size.width * insetW,
      size.height * insetH,
    );
  }

  /// y=0 baliza própria (baixo do ecrã); y=1 ataque (cima).
  static Offset normalizedToOffset(PitchPos pos, Size size) {
    final area = playArea(size);
    return Offset(
      area.left + pos.x * area.width,
      area.top + (1 - pos.y) * area.height,
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final area = _PitchGeom.playArea(size);

    // Relvado base
    final pitch = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1F7A3A), Color(0xFF176B32), Color(0xFF0F4F24)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, pitch);

    // Faixas de relva
    final stripeA = Paint()..color = const Color(0xFF228B3F);
    final stripeB = Paint()..color = const Color(0xFF1A7034);
    const bands = 10;
    for (var i = 0; i < bands; i++) {
      final y = area.top + area.height * (i / bands);
      canvas.drawRect(
        Rect.fromLTWH(area.left, y, area.width, area.height / bands),
        i.isEven ? stripeA : stripeB,
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..isAntiAlias = true;

    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Contorno
    canvas.drawRRect(
      RRect.fromRectAndRadius(area, const Radius.circular(2)),
      line,
    );

    // Meio-campo
    canvas.drawLine(
      Offset(area.left, area.center.dy),
      Offset(area.right, area.center.dy),
      line,
    );
    final circleR = area.width * 0.12;
    canvas.drawCircle(area.center, circleR, line);
    canvas.drawCircle(
      area.center,
      2.2,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    void drawBox({required bool atBottom}) {
      final boxH = area.height * 0.18;
      final boxW = area.width * 0.56;
      final sixH = area.height * 0.08;
      final sixW = area.width * 0.28;
      final cy = atBottom ? area.bottom - boxH / 2 : area.top + boxH / 2;
      final sixCy = atBottom ? area.bottom - sixH / 2 : area.top + sixH / 2;
      final box = Rect.fromCenter(
        center: Offset(area.center.dx, cy),
        width: boxW,
        height: boxH,
      );
      final six = Rect.fromCenter(
        center: Offset(area.center.dx, sixCy),
        width: sixW,
        height: sixH,
      );
      canvas.drawRect(box, line);
      canvas.drawRect(six, thin);

      // Baliza
      final goalW = area.width * 0.18;
      final goalH = area.height * 0.018;
      final goal = Rect.fromCenter(
        center: Offset(
          area.center.dx,
          atBottom ? area.bottom : area.top,
        ),
        width: goalW,
        height: goalH,
      );
      canvas.drawRect(
        goal,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Marca de penálti
      final penY = atBottom
          ? area.bottom - area.height * 0.12
          : area.top + area.height * 0.12;
      canvas.drawCircle(
        Offset(area.center.dx, penY),
        2.0,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );

      // Arco da área
      final arcRect = Rect.fromCircle(
        center: Offset(area.center.dx, penY),
        radius: area.width * 0.1,
      );
      canvas.drawArc(
        arcRect,
        atBottom ? 3.6 : 0.55,
        atBottom ? 2.5 : 2.05,
        false,
        thin,
      );
    }

    drawBox(atBottom: true);
    drawBox(atBottom: false);

    // Cantos
    final cornerR = area.width * 0.035;
    void corner(Offset o, double start) {
      canvas.drawArc(
        Rect.fromCircle(center: o, radius: cornerR),
        start,
        1.57,
        false,
        thin,
      );
    }

    corner(area.topLeft, 0);
    corner(area.topRight, 1.57);
    corner(area.bottomLeft, -1.57);
    corner(area.bottomRight, 3.14);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
        color: PhoenixColors.muted,
        letterSpacing: 0.3,
      ),
    );
  }
}
