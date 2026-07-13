import 'dart:convert';

import 'package:phoenix_engine/src/core/engine_version.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';
import 'package:phoenix_engine/src/world/world_state.dart';

/// Delta save manager — serializes Digital Twin + WorldRegistry.
class SaveManager {
  SaveManager({required EventBus eventBus}) : _eventBus = eventBus;

  final EventBus _eventBus;

  String serialize({
    required WorldState state,
    required WorldRegistry registry,
  }) {
    final envelope = SaveEnvelope(
      saveId: 'save-${state.worldId}-${state.tick}',
      savedAt: DateTime.now().toUtc(),
      engineVersion: state.engineVersion,
      world: state,
      registry: registry,
    );
    return jsonEncode(envelope.toMap());
  }

  SaveEnvelope deserializeEnvelope(String jsonText) {
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return SaveEnvelope.fromMap(map);
  }

  WorldState deserializeWorld(String jsonText) =>
      deserializeEnvelope(jsonText).world;

  WorldRegistry deserializeRegistry(String jsonText) =>
      deserializeEnvelope(jsonText).registry;

  String save({
    required WorldState state,
    required WorldRegistry registry,
  }) {
    final payload = serialize(state: state, registry: registry);
    _eventBus.publish(
      WorldSavedEvent(
        saveId: 'save-${state.worldId}-${state.tick}',
        savedAt: DateTime.now().toUtc(),
      ),
    );
    return payload;
  }
}

class SaveEnvelope {
  const SaveEnvelope({
    required this.saveId,
    required this.savedAt,
    required this.engineVersion,
    required this.world,
    required this.registry,
  });

  final String saveId;
  final DateTime savedAt;
  final EngineVersion engineVersion;
  final WorldState world;
  final WorldRegistry registry;

  Map<String, dynamic> toMap() {
    return {
      'saveId': saveId,
      'savedAt': savedAt.toIso8601String(),
      'engineVersion': engineVersion.toMap(),
      'world': world.toMap(),
      'registry': registry.toMap(),
    };
  }

  factory SaveEnvelope.fromMap(Map<String, dynamic> map) {
    return SaveEnvelope(
      saveId: map['saveId'] as String,
      savedAt: DateTime.parse(map['savedAt'] as String),
      engineVersion: EngineVersion.fromMap(
        Map<String, dynamic>.from(map['engineVersion'] as Map),
      ),
      world: WorldState.fromMap(
        Map<String, dynamic>.from(map['world'] as Map),
      ),
      registry: map['registry'] != null
          ? WorldRegistry.fromMap(
              Map<String, dynamic>.from(map['registry'] as Map),
            )
          : WorldRegistry(),
    );
  }
}
