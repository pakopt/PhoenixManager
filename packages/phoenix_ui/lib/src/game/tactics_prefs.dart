import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Snapshot de táctica de apresentação (por slot de save).
class TacticsSnapshot {
  const TacticsSnapshot({
    required this.formationId,
    required this.mentality,
    required this.tempo,
    required this.corner,
    required this.freeKick,
    required this.penalty,
  });

  final String formationId;
  final int mentality;
  final int tempo;
  final int corner;
  final int freeKick;
  final int penalty;

  Map<String, dynamic> toMap() => {
        'formationId': formationId,
        'mentality': mentality,
        'tempo': tempo,
        'corner': corner,
        'freeKick': freeKick,
        'penalty': penalty,
      };

  factory TacticsSnapshot.fromMap(Map<String, dynamic> map) {
    return TacticsSnapshot(
      formationId: map['formationId'] as String? ?? '442d',
      mentality: map['mentality'] as int? ?? 1,
      tempo: map['tempo'] as int? ?? 1,
      corner: map['corner'] as int? ?? 0,
      freeKick: map['freeKick'] as int? ?? 0,
      penalty: map['penalty'] as int? ?? 0,
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
