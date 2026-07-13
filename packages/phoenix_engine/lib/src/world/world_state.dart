import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/core/engine_version.dart';

/// Digital Twin snapshot — the world exists independently of the UI.
class WorldState {
  WorldState({
    required this.worldId,
    required this.seed,
    required this.currentDate,
    required this.tick,
    required this.engineVersion,
    this.isPaused = true,
    this.metadata = const {},
  });

  factory WorldState.newGame({
    required String worldId,
    required int seed,
    GameDate? startDate,
  }) {
    return WorldState(
      worldId: worldId,
      seed: seed,
      currentDate: startDate ?? GameDate.start(),
      tick: 0,
      engineVersion: EngineVersion.current,
      isPaused: true,
    );
  }

  factory WorldState.fromMap(Map<String, dynamic> map) {
    return WorldState(
      worldId: map['worldId'] as String,
      seed: map['seed'] as int,
      currentDate: GameDate.fromMap(
        Map<String, dynamic>.from(map['currentDate'] as Map),
      ),
      tick: map['tick'] as int? ?? 0,
      engineVersion: EngineVersion.fromMap(
        Map<String, dynamic>.from(map['engineVersion'] as Map),
      ),
      isPaused: map['isPaused'] as bool? ?? true,
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? {}),
    );
  }

  final String worldId;
  final int seed;
  final GameDate currentDate;
  final int tick;
  final EngineVersion engineVersion;
  final bool isPaused;
  final Map<String, dynamic> metadata;

  WorldState copyWith({
    GameDate? currentDate,
    int? tick,
    bool? isPaused,
    Map<String, dynamic>? metadata,
  }) {
    return WorldState(
      worldId: worldId,
      seed: seed,
      currentDate: currentDate ?? this.currentDate,
      tick: tick ?? this.tick,
      engineVersion: engineVersion,
      isPaused: isPaused ?? this.isPaused,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'worldId': worldId,
      'seed': seed,
      'currentDate': currentDate.toMap(),
      'tick': tick,
      'engineVersion': engineVersion.toMap(),
      'isPaused': isPaused,
      'metadata': metadata,
    };
  }
}
