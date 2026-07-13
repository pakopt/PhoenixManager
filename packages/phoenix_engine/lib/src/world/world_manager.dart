import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/world/world_state.dart';

/// Orchestrates world ticks — Digital Twin clock and off-screen simulation hook.
class WorldManager {
  WorldManager({
    required EventBus eventBus,
    required PhoenixLogger logger,
    WorldState? initialState,
  })  : _eventBus = eventBus,
        _logger = logger,
        _state = initialState ??
            WorldState.newGame(
              worldId: 'world-default',
              seed: 42,
            );

  final EventBus _eventBus;
  final PhoenixLogger _logger;
  WorldState _state;

  WorldState get state => _state;

  void initialize({required String worldId, required int seed}) {
    _state = WorldState.newGame(worldId: worldId, seed: seed);
    _eventBus.publish(
      WorldInitializedEvent(worldId: worldId, seed: seed),
    );
    _logger.info('World initialized: $worldId (seed=$seed)');
  }

  /// Advances the Digital Twin by [days] in-game days.
  WorldState advanceDays(int days) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', 'must be > 0');
    }

    final previousDate = _state.currentDate;
    var nextDate = _state.currentDate;
    for (var i = 0; i < days; i++) {
      nextDate = nextDate.addDays(1);
    }

    _state = _state.copyWith(
      currentDate: nextDate,
      tick: _state.tick + days,
      isPaused: false,
    );

    _eventBus.publish(
      DayAdvancedEvent(
        previousDate: previousDate,
        currentDate: _state.currentDate,
        tick: _state.tick,
      ),
    );

    _logger.debug(
      'Day advanced: $previousDate -> ${_state.currentDate} (tick=${_state.tick})',
    );

    return _state;
  }

  void loadState(WorldState state) {
    _state = state;
    _logger.info('World loaded at ${_state.currentDate} (tick=${_state.tick})');
  }
}
