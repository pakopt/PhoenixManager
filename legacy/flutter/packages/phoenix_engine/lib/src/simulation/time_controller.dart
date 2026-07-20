import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/simulation/simulation_engine.dart';
import 'package:phoenix_engine/src/world/world_state.dart';

/// Maps UI actions to simulation steps across the three time scales.
class TimeController {
  TimeController({
    required SimulationEngine simulationEngine,
    required PhoenixConfig config,
    TimeScale initialScale = TimeScale.management,
  })  : _simulationEngine = simulationEngine,
        _config = config,
        _scale = initialScale;

  final SimulationEngine _simulationEngine;
  final PhoenixConfig _config;
  TimeScale _scale;

  TimeScale get scale => _scale;

  void setScale(TimeScale scale) {
    _scale = scale;
  }

  WorldState advance(SimulationStep step) {
    switch (_scale) {
      case TimeScale.realTime:
        return _simulationEngine.tickOneDay();
      case TimeScale.management:
        return switch (step) {
          SimulationStep.day => _simulationEngine.tickOneDay(),
          SimulationStep.week => _simulationEngine.tickDays(_config.simulation.daysPerWeek),
          SimulationStep.month => _simulationEngine.tickDays(_config.simulation.daysPerWeek * 4),
          SimulationStep.season => _simulationEngine.tickDays(
              _config.simulation.daysPerWeek * _config.simulation.weeksPerSeason,
            ),
        };
      case TimeScale.simulation:
        return switch (step) {
          SimulationStep.day => _simulationEngine.tickOneDay(),
          SimulationStep.week => _simulationEngine.tickDays(_config.simulation.daysPerWeek),
          SimulationStep.month => _simulationEngine.tickDays(_config.simulation.daysPerWeek * 4),
          SimulationStep.season => _simulationEngine.tickDays(
              _config.simulation.daysPerWeek * _config.simulation.weeksPerSeason,
            ),
        };
    }
  }
}
