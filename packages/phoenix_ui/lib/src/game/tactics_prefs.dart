import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Posição normalizada no campo (0–1; y=0 baliza própria).
class PitchPos {
  const PitchPos(this.x, this.y);

  final double x;
  final double y;

  Map<String, dynamic> toMap() => {'x': x, 'y': y};

  factory PitchPos.fromMap(Map<String, dynamic> map) {
    return PitchPos(
      (map['x'] as num?)?.toDouble() ?? 0.5,
      (map['y'] as num?)?.toDouble() ?? 0.5,
    );
  }

  PitchPos clamp01() => PitchPos(
        x.clamp(0.02, 0.98),
        y.clamp(0.02, 0.98),
      );
}

/// Snapshot de táctica de apresentação (por slot de save).
class TacticsSnapshot {
  const TacticsSnapshot({
    required this.formationId,
    required this.mentality,
    required this.tempo,
    required this.corner,
    required this.freeKick,
    required this.penalty,
    this.playerPositions = const {},
  });

  final String formationId;
  final int mentality;
  final int tempo;
  final int corner;
  final int freeKick;
  final int penalty;

  /// playerId → posição livre no campo.
  final Map<String, PitchPos> playerPositions;

  Map<String, dynamic> toMap() => {
        'formationId': formationId,
        'mentality': mentality,
        'tempo': tempo,
        'corner': corner,
        'freeKick': freeKick,
        'penalty': penalty,
        if (playerPositions.isNotEmpty)
          'playerPositions': {
            for (final e in playerPositions.entries) e.key: e.value.toMap(),
          },
      };

  factory TacticsSnapshot.fromMap(Map<String, dynamic> map) {
    final rawPos = map['playerPositions'];
    final positions = <String, PitchPos>{};
    if (rawPos is Map) {
      for (final entry in rawPos.entries) {
        final value = entry.value;
        if (value is Map) {
          positions[entry.key.toString()] = PitchPos.fromMap(
            Map<String, dynamic>.from(value),
          );
        }
      }
    }
    return TacticsSnapshot(
      formationId: map['formationId'] as String? ?? '442d',
      mentality: map['mentality'] as int? ?? 1,
      tempo: map['tempo'] as int? ?? 1,
      corner: map['corner'] as int? ?? 0,
      freeKick: map['freeKick'] as int? ?? 0,
      penalty: map['penalty'] as int? ?? 0,
      playerPositions: positions,
    );
  }
}

/// Persistência local da táctica (UI) por slot.
abstract final class TacticsPrefs {
  static const _prefix = 'phoenix_tactics_';

  static String _key(int slot) => '$_prefix$slot';

  static Future<TacticsSnapshot?> load(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(slot));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return TacticsSnapshot.fromMap(map);
    } on Object {
      return null;
    }
  }

  static Future<void> save(int slot, TacticsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(slot), jsonEncode(snapshot.toMap()));
  }

  static Future<void> clearSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(slot));
  }
}
