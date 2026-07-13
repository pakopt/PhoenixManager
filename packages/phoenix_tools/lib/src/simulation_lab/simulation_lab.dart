import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';

/// Headless batch runner for CI benchmarks.
class SimulationLab {
  SimulationLab({required this.context});

  final EngineContext context;

  SimulationLabResult runDays(int days) {
    final startTick = context.simulationEngine.worldState.tick;
    final startDate = context.simulationEngine.worldState.currentDate;

    context.simulationEngine.tickDays(days);

    final endState = context.simulationEngine.worldState;
    return SimulationLabResult(
      daysSimulated: days,
      startTick: startTick,
      endTick: endState.tick,
      startDate: startDate,
      endDate: endState.currentDate,
      eventsPublished: context.eventBus.history.length,
      matchesPlayed: context.eventBus.history.whereType<MatchPlayedEvent>().length,
    );
  }

  SimulationLabResult runSeasons(int seasons) {
    final daysPerSeason = context.config.simulation.daysPerWeek *
        context.config.simulation.weeksPerSeason;
    return runDays(daysPerSeason * seasons);
  }

  /// Simulates until Liga Phoenix season completes.
  SimulationLabResult runUntilSeasonEnd({int maxDays = 400}) {
    const competitionId = CompetitionId('liga-phoenix');
    final startTick = context.simulationEngine.worldState.tick;
    final startDate = context.simulationEngine.worldState.currentDate;
    var days = 0;

    while (days < maxDays &&
        !context.competitionManager.isSeasonComplete(competitionId)) {
      context.simulationEngine.tickOneDay();
      days += 1;
    }

    final endState = context.simulationEngine.worldState;
    return SimulationLabResult(
      daysSimulated: days,
      startTick: startTick,
      endTick: endState.tick,
      startDate: startDate,
      endDate: endState.currentDate,
      eventsPublished: context.eventBus.history.length,
      matchesPlayed: context.eventBus.history.whereType<MatchPlayedEvent>().length,
      seasonComplete: context.competitionManager.isSeasonComplete(competitionId),
    );
  }
}

class SimulationLabResult {
  const SimulationLabResult({
    required this.daysSimulated,
    required this.startTick,
    required this.endTick,
    required this.startDate,
    required this.endDate,
    required this.eventsPublished,
    this.matchesPlayed = 0,
    this.seasonComplete = false,
  });

  final int daysSimulated;
  final int startTick;
  final int endTick;
  final GameDate startDate;
  final GameDate endDate;
  final int eventsPublished;
  final int matchesPlayed;
  final bool seasonComplete;
}
