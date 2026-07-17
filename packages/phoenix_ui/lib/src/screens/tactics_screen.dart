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

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuildLineup);
    _loadPrefs();
    _rebuildLineup();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuildLineup);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final snap = await TacticsPrefs.load(widget.controller.activeSlot);
    if (!mounted) {
      return;
    }
    if (snap == null) {
      setState(() => _prefsLoaded = true);
      return;
    }
    final formation = TacticsCatalog.formations.firstWhere(
      (f) => f.id == snap.formationId,
      orElse: () => TacticsCatalog.formations[1],
    );
    setState(() {
      _formation = formation;
      _mentality =
          snap.mentality.clamp(0, TacticsCatalog.mentalities.length - 1);
      _tempo = snap.tempo.clamp(0, TacticsCatalog.tempos.length - 1);
      _corner = snap.corner.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _freeKick =
          snap.freeKick.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _penalty =
          snap.penalty.clamp(0, TacticsCatalog.setPieceOptions.length - 1);
      _prefsLoaded = true;
    });
    _rebuildLineup();
  }

  void _rebuildLineup() {
    final session = widget.controller.session;
    if (session == null) {
      return;
    }
    setState(() {
      _lineup = TacticsLineup.auto(
        squad: session.squad,
        formation: _formation,
      );
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Táctica',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _prefsLoaded ? _saveTactics : null,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: const Text('Guardar táctica'),
                ),
              ],
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
                        child: _PitchPanel(
                          formation: _formation,
                          starters: lineup.starters,
                          onOpenPlayer: _openPlayer,
                        ),
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
                        child: _PitchPanel(
                          formation: _formation,
                          starters: lineup.starters,
                          onOpenPlayer: _openPlayer,
                        ),
                      ),
                    ],
                  );
                }
                return ListView(
                  children: [
                    SizedBox(
                      height: 260,
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
                    SizedBox(
                      height: 420,
                      child: _PitchPanel(
                        formation: _formation,
                        starters: lineup.starters,
                        onOpenPlayer: _openPlayer,
                      ),
                    ),
                    SizedBox(
                      height: 480,
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
                  slot: formation.slots[i].label,
                  player: lineup.starters[i],
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
  });

  final String slot;
  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final profile = PlayerDisplayProfile.from(player);
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
                profile.position,
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
    required this.onOpenPlayer,
  });

  final TacticsFormation formation;
  final List<Player> starters;
  final ValueChanged<PlayerId> onOpenPlayer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PhoenixColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PhoenixColors.cardBorder),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _PitchPainter()),
                  ),
                  for (var i = 0;
                      i < formation.slots.length && i < starters.length;
                      i++)
                    _PitchPlayerMarker(
                      slot: formation.slots[i],
                      player: starters[i],
                      pitchSize: Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
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

class _PitchPlayerMarker extends StatelessWidget {
  const _PitchPlayerMarker({
    required this.slot,
    required this.player,
    required this.pitchSize,
    required this.onTap,
  });

  final FormationSlot slot;
  final Player player;
  final Size pitchSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const markerW = 76.0;
    const markerH = 64.0;
    final left = (slot.x * pitchSize.width) - markerW / 2;
    final top = ((1 - slot.y) * pitchSize.height) - markerH / 2;
    final initial = player.name.isNotEmpty
        ? player.name.characters.first.toUpperCase()
        : '?';

    return Positioned(
      left: left.clamp(4, pitchSize.width - markerW - 4),
      top: top.clamp(4, pitchSize.height - markerH - 4),
      width: markerW,
      height: markerH,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PhoenixColors.surface,
                border: Border.all(color: PhoenixColors.seed, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: PhoenixColors.positive,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: PhoenixColors.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${player.name.split(' ').last} · ${player.currentAbility}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pitch = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B5E20), Color(0xFF145A32), Color(0xFF0F3D24)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, pitch);

    // Stripe effect
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.03);
    for (var i = 0; i < 8; i++) {
      final y = size.height * (i / 8);
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, size.height / 16),
        stripe,
      );
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final inset = Rect.fromLTWH(
      size.width * 0.06,
      size.height * 0.04,
      size.width * 0.88,
      size.height * 0.92,
    );
    canvas.drawRect(inset, line);
    canvas.drawLine(
      Offset(inset.left, inset.center.dy),
      Offset(inset.right, inset.center.dy),
      line,
    );
    canvas.drawCircle(inset.center, size.width * 0.09, line);

    final boxH = inset.height * 0.16;
    final boxW = inset.width * 0.42;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(inset.center.dx, inset.bottom - boxH / 2),
        width: boxW,
        height: boxH,
      ),
      line,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(inset.center.dx, inset.top + boxH / 2),
        width: boxW,
        height: boxH,
      ),
      line,
    );
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
