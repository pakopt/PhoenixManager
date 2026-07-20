import 'package:phoenix_engine/src/simulation/daily_simulation_runner.dart';
import 'package:phoenix_engine/src/world/world_manager.dart';
import 'package:phoenix_engine/src/world/world_state.dart';

/// Runs simulation ticks using the configured time scale.
class SimulationEngine {
  SimulationEngine({
    required WorldManager worldManager,
    DailySimulationRunner? dailyRunner,
  })  : _worldManager = worldManager,
        _dailyRunner = dailyRunner;

  final WorldManager _worldManager;
  final DailySimulationRunner? _dailyRunner;

  WorldState get worldState => _worldManager.state;

  /// Headless management tick — advances one day and simulates matches.
  WorldState tickOneDay() {
    final state = _worldManager.advanceDays(1);
    _dailyRunner?.runForDate(state.currentDate);
    return state;
  }

  /// Advances [days] one day at a time (runs daily simulation each day).
  WorldState tickDays(int days) {
    WorldState state = worldState;
    for (var i = 0; i < days; i++) {
      state = tickOneDay();
    }
    return state;
  }

  DailySimulationRunner? get dailyRunner => _dailyRunner;
}
