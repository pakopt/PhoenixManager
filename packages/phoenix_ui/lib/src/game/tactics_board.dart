import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';

/// Slot de formação no campo (x/y normalizados: 0–1, y=0 baliza própria).
class FormationSlot {
  const FormationSlot({
    required this.code,
    required this.label,
    required this.x,
    required this.y,
  });

  final String code;
  final String label;
  final double x;
  final double y;
}

class TacticsFormation {
  const TacticsFormation({
    required this.id,
    required this.name,
    required this.slots,
  });

  final String id;
  final String name;
  final List<FormationSlot> slots;
}

abstract final class TacticsCatalog {
  static const formations = <TacticsFormation>[
    TacticsFormation(
      id: '442',
      name: '4-4-2',
      slots: [
        FormationSlot(code: 'GK', label: 'GR', x: 0.50, y: 0.08),
        FormationSlot(code: 'LB', label: 'LE', x: 0.12, y: 0.28),
        FormationSlot(code: 'CB', label: 'DC', x: 0.36, y: 0.26),
        FormationSlot(code: 'CB', label: 'DC', x: 0.64, y: 0.26),
        FormationSlot(code: 'RB', label: 'LD', x: 0.88, y: 0.28),
        FormationSlot(code: 'LM', label: 'ME', x: 0.12, y: 0.52),
        FormationSlot(code: 'CM', label: 'MC', x: 0.36, y: 0.50),
        FormationSlot(code: 'CM', label: 'MC', x: 0.64, y: 0.50),
        FormationSlot(code: 'RM', label: 'MD', x: 0.88, y: 0.52),
        FormationSlot(code: 'ST', label: 'PL', x: 0.36, y: 0.78),
        FormationSlot(code: 'ST', label: 'PL', x: 0.64, y: 0.78),
      ],
    ),
    TacticsFormation(
      id: '442d',
      name: '4-4-2 Diamante',
      slots: [
        FormationSlot(code: 'GK', label: 'GR', x: 0.50, y: 0.08),
        FormationSlot(code: 'LB', label: 'LE', x: 0.12, y: 0.28),
        FormationSlot(code: 'CB', label: 'DC', x: 0.36, y: 0.26),
        FormationSlot(code: 'CB', label: 'DC', x: 0.64, y: 0.26),
        FormationSlot(code: 'RB', label: 'LD', x: 0.88, y: 0.28),
        FormationSlot(code: 'DM', label: 'TR', x: 0.50, y: 0.42),
        FormationSlot(code: 'CM', label: 'MC', x: 0.30, y: 0.56),
        FormationSlot(code: 'CM', label: 'MC', x: 0.70, y: 0.56),
        FormationSlot(code: 'AM', label: 'MO', x: 0.50, y: 0.68),
        FormationSlot(code: 'ST', label: 'PL', x: 0.36, y: 0.84),
        FormationSlot(code: 'ST', label: 'PL', x: 0.64, y: 0.84),
      ],
    ),
    TacticsFormation(
      id: '433',
      name: '4-3-3',
      slots: [
        FormationSlot(code: 'GK', label: 'GR', x: 0.50, y: 0.08),
        FormationSlot(code: 'LB', label: 'LE', x: 0.12, y: 0.28),
        FormationSlot(code: 'CB', label: 'DC', x: 0.36, y: 0.26),
        FormationSlot(code: 'CB', label: 'DC', x: 0.64, y: 0.26),
        FormationSlot(code: 'RB', label: 'LD', x: 0.88, y: 0.28),
        FormationSlot(code: 'CM', label: 'MC', x: 0.28, y: 0.50),
        FormationSlot(code: 'CM', label: 'MC', x: 0.50, y: 0.48),
        FormationSlot(code: 'CM', label: 'MC', x: 0.72, y: 0.50),
        FormationSlot(code: 'LW', label: 'EE', x: 0.18, y: 0.74),
        FormationSlot(code: 'ST', label: 'PL', x: 0.50, y: 0.82),
        FormationSlot(code: 'RW', label: 'ED', x: 0.82, y: 0.74),
      ],
    ),
    TacticsFormation(
      id: '4231',
      name: '4-2-3-1',
      slots: [
        FormationSlot(code: 'GK', label: 'GR', x: 0.50, y: 0.08),
        FormationSlot(code: 'LB', label: 'LE', x: 0.12, y: 0.28),
        FormationSlot(code: 'CB', label: 'DC', x: 0.36, y: 0.26),
        FormationSlot(code: 'CB', label: 'DC', x: 0.64, y: 0.26),
        FormationSlot(code: 'RB', label: 'LD', x: 0.88, y: 0.28),
        FormationSlot(code: 'DM', label: 'TR', x: 0.36, y: 0.46),
        FormationSlot(code: 'DM', label: 'TR', x: 0.64, y: 0.46),
        FormationSlot(code: 'LM', label: 'ME', x: 0.16, y: 0.64),
        FormationSlot(code: 'AM', label: 'MO', x: 0.50, y: 0.66),
        FormationSlot(code: 'RM', label: 'MD', x: 0.84, y: 0.64),
        FormationSlot(code: 'ST', label: 'PL', x: 0.50, y: 0.84),
      ],
    ),
    TacticsFormation(
      id: '352',
      name: '3-5-2',
      slots: [
        FormationSlot(code: 'GK', label: 'GR', x: 0.50, y: 0.08),
        FormationSlot(code: 'CB', label: 'DC', x: 0.28, y: 0.26),
        FormationSlot(code: 'CB', label: 'DC', x: 0.50, y: 0.24),
        FormationSlot(code: 'CB', label: 'DC', x: 0.72, y: 0.26),
        FormationSlot(code: 'LM', label: 'ME', x: 0.10, y: 0.48),
        FormationSlot(code: 'CM', label: 'MC', x: 0.34, y: 0.50),
        FormationSlot(code: 'CM', label: 'MC', x: 0.50, y: 0.46),
        FormationSlot(code: 'CM', label: 'MC', x: 0.66, y: 0.50),
        FormationSlot(code: 'RM', label: 'MD', x: 0.90, y: 0.48),
        FormationSlot(code: 'ST', label: 'PL', x: 0.38, y: 0.78),
        FormationSlot(code: 'ST', label: 'PL', x: 0.62, y: 0.78),
      ],
    ),
  ];

  static const mentalities = [
    'Muito defensiva',
    'Defensiva',
    'Equilibrada',
    'Ofensiva',
    'Muito ofensiva',
  ];

  /// Labels curtos para chips em layout compacto (não cortar «Muito …»).
  static const mentalityShort = [
    'M. def.',
    'Defensiva',
    'Equilibrada',
    'Ofensiva',
    'M. of.',
  ];

  static const tempos = ['Lento', 'Normal', 'Rápido'];

  static const setPieceOptions = ['Auto', 'Mais alto', 'Mais técnico'];
}

/// Monta XI + suplentes a partir do plantel (apresentação).
class TacticsLineup {
  const TacticsLineup({
    required this.starters,
    required this.reserves,
  });

  final List<Player> starters;
  final List<Player> reserves;

  static TacticsLineup auto({
    required List<Player> squad,
    required TacticsFormation formation,
  }) {
    if (squad.isEmpty) {
      return const TacticsLineup(starters: [], reserves: []);
    }

    final remaining = List<Player>.from(squad)
      ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
    final starters = <Player>[];

    for (final slot in formation.slots) {
      if (remaining.isEmpty) {
        break;
      }
      remaining.sort(
        (a, b) => _slotScore(b, slot.code).compareTo(_slotScore(a, slot.code)),
      );
      starters.add(remaining.removeAt(0));
    }

    return TacticsLineup(starters: starters, reserves: remaining);
  }

  static int _slotScore(Player player, String slotCode) {
    final profile = PlayerDisplayProfile.from(player);
    final affinity = _affinity(profile.position, slotCode);
    return player.currentAbility * 10 + affinity * 8 + (100 - player.age);
  }

  static int _affinity(String role, String slot) {
    return switch (slot) {
      'GK' => role == 'GR' ? 20 : 0,
      'LB' || 'RB' || 'LWB' || 'RWB' => role == 'DF' || role == 'EX' ? 14 : 4,
      'CB' => role == 'DF' || role == 'GR' ? 16 : 3,
      'DM' => role == 'MD' || role == 'DF' ? 14 : 5,
      'CM' => role == 'MD' || role == 'MO' ? 16 : 6,
      'AM' => role == 'MO' || role == 'MD' ? 16 : 5,
      'LM' || 'RM' || 'LW' || 'RW' => role == 'EX' || role == 'MO' ? 16 : 5,
      'ST' => role == 'PL' || role == 'EX' ? 18 : 4,
      _ => 5,
    };
  }
}
