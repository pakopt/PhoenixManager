import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_data/phoenix_data.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/modules/competition/competition_manager.dart';
import 'package:phoenix_engine/src/modules/match/match_simulator.dart';
import 'package:phoenix_engine/src/save/save_manager.dart';
import 'package:phoenix_engine/src/simulation/economy_simulation_runner.dart';
import 'package:phoenix_engine/src/simulation/simulation_engine.dart';
import 'package:phoenix_engine/src/simulation/time_controller.dart';
import 'package:phoenix_engine/src/world/world_manager.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Runtime context returned after [AppBootstrap.boot].
class EngineContext {
  const EngineContext({
    required this.container,
    required this.config,
    required this.matchConfig,
    required this.economyConfig,
    required this.logger,
    required this.eventBus,
    required this.database,
    required this.registry,
    required this.competitionManager,
    required this.matchSimulator,
    required this.economyRunner,
    required this.worldManager,
    required this.simulationEngine,
    required this.timeController,
    required this.saveManager,
  });

  final ServiceContainer container;
  final PhoenixConfig config;
  final MatchEngineConfig matchConfig;
  final EconomyConfig economyConfig;
  final PhoenixLogger logger;
  final EventBus eventBus;
  final DatabaseAdapter database;
  final WorldRegistry registry;
  final CompetitionManager competitionManager;
  final MatchSimulator matchSimulator;
  final EconomySimulationRunner economyRunner;
  final WorldManager worldManager;
  final SimulationEngine simulationEngine;
  final TimeController timeController;
  final SaveManager saveManager;
}
