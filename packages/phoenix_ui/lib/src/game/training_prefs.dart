import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Foco de treino do dia (apresentação UI).
enum WeeklyTrainingFocus {
  physical,
  attacking,
  defending,
  possession,
  rest;

  String get labelPt => switch (this) {
        WeeklyTrainingFocus.physical => 'Físico',
        WeeklyTrainingFocus.attacking => 'Ataque',
        WeeklyTrainingFocus.defending => 'Defesa',
        WeeklyTrainingFocus.possession => 'Posse',
        WeeklyTrainingFocus.rest => 'Descanso',
      };

  String get id => name;

  static WeeklyTrainingFocus fromId(String? id) {
    return WeeklyTrainingFocus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WeeklyTrainingFocus.physical,
    );
  }
}

/// Foco individual do jogador (apresentação UI).
enum PlayerTrainingFocus {
  general,
  goalkeeping,
  technique,
  defending,
  passing,
  physical,
  finishing;

  String get labelPt => switch (this) {
        PlayerTrainingFocus.general => 'Geral',
        PlayerTrainingFocus.goalkeeping => 'Guarda-redes',
        PlayerTrainingFocus.technique => 'Técnica',
        PlayerTrainingFocus.defending => 'Defesa',
        PlayerTrainingFocus.passing => 'Passe',
        PlayerTrainingFocus.physical => 'Físico',
        PlayerTrainingFocus.finishing => 'Finalização',
      };

  String get id => name;

  static PlayerTrainingFocus fromId(String? id) {
    return PlayerTrainingFocus.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PlayerTrainingFocus.general,
    );
  }
}

/// Snapshot de treino de apresentação (por slot de save).
class TrainingSnapshot {
  const TrainingSnapshot({
    this.weekFocus = const {},
    this.playerFocus = const {},
  });

  /// weekday 1–7 (seg–dom) → foco.
  final Map<int, WeeklyTrainingFocus> weekFocus;

  /// playerId → foco individual.
  final Map<String, PlayerTrainingFocus> playerFocus;

  /// Predefinição FootSim: Físico / Ataque / Defesa / Posse / Descanso / Descanso / Descanso.
  static Map<int, WeeklyTrainingFocus> defaultWeekFocus() => {
        1: WeeklyTrainingFocus.physical,
        2: WeeklyTrainingFocus.attacking,
        3: WeeklyTrainingFocus.defending,
        4: WeeklyTrainingFocus.possession,
        5: WeeklyTrainingFocus.rest,
        6: WeeklyTrainingFocus.rest,
        7: WeeklyTrainingFocus.rest,
      };

  WeeklyTrainingFocus focusForWeekday(int weekday) =>
      weekFocus[weekday] ?? defaultWeekFocus()[weekday]!;

  PlayerTrainingFocus focusForPlayer(String playerId) =>
      playerFocus[playerId] ?? PlayerTrainingFocus.general;

  TrainingSnapshot copyWith({
    Map<int, WeeklyTrainingFocus>? weekFocus,
    Map<String, PlayerTrainingFocus>? playerFocus,
  }) {
    return TrainingSnapshot(
      weekFocus: weekFocus ?? this.weekFocus,
      playerFocus: playerFocus ?? this.playerFocus,
    );
  }

  Map<String, dynamic> toMap() => {
        'weekFocus': {
          for (final e in weekFocus.entries) '${e.key}': e.value.id,
        },
        if (playerFocus.isNotEmpty)
          'playerFocus': {
            for (final e in playerFocus.entries) e.key: e.value.id,
          },
      };

  factory TrainingSnapshot.fromMap(Map<String, dynamic> map) {
    final week = <int, WeeklyTrainingFocus>{};
    final rawWeek = map['weekFocus'];
    if (rawWeek is Map) {
      for (final entry in rawWeek.entries) {
        final day = int.tryParse(entry.key.toString());
        if (day == null || day < 1 || day > 7) {
          continue;
        }
        week[day] = WeeklyTrainingFocus.fromId(entry.value?.toString());
      }
    }

    final players = <String, PlayerTrainingFocus>{};
    final rawPlayers = map['playerFocus'];
    if (rawPlayers is Map) {
      for (final entry in rawPlayers.entries) {
        players[entry.key.toString()] =
            PlayerTrainingFocus.fromId(entry.value?.toString());
      }
    }

    return TrainingSnapshot(weekFocus: week, playerFocus: players);
  }
}

/// Persistência local do treino (UI) por slot.
abstract final class TrainingPrefs {
  static const _prefix = 'phoenix_training_';

  static String _key(int slot) => '$_prefix$slot';

  static Future<TrainingSnapshot?> load(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(slot));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return TrainingSnapshot.fromMap(map);
    } on Object {
      return null;
    }
  }

  static Future<void> save(int slot, TrainingSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(slot), jsonEncode(snapshot.toMap()));
  }

  static Future<void> clearSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(slot));
  }
}
