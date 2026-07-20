import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/competition/competition_manager.dart';
import 'package:phoenix_engine/src/modules/match/match_simulator.dart';
import 'package:phoenix_engine/src/simulation/economy_simulation_runner.dart';

/// Runs daily off-screen simulation — matches, standings, season completion.
class DailySimulationRunner {
  DailySimulationRunner({
    required CompetitionManager competitionManager,
    required MatchSimulator matchSimulator,
    required EventBus eventBus,
    required PhoenixLogger logger,
    EconomySimulationRunner? economyRunner,
  })  : _competitionManager = competitionManager,
        _matchSimulator = matchSimulator,
        _eventBus = eventBus,
        _logger = logger,
        _economyRunner = economyRunner;

  final CompetitionManager _competitionManager;
  final MatchSimulator _matchSimulator;
  final EventBus _eventBus;
  final PhoenixLogger _logger;
  final EconomySimulationRunner? _economyRunner;

  int runForDate(GameDate date) {
    _economyRunner?.runDaily(date);

    final fixtures = _competitionManager.matchesOnDate(date);
    if (fixtures.isEmpty) {
      _checkSeasonCompletion(date);
      return 0;
    }

    var played = 0;
    for (final fixture in fixtures) {
      final output = _matchSimulator.simulate(fixture);
      _competitionManager.recordResult(output.fixture);
      final matchEvent = MatchPlayedEvent(
        fixture: output.fixture,
        homeClubId: output.fixture.homeClubId,
        awayClubId: output.fixture.awayClubId,
        homeScore: output.fixture.homeScore!,
        awayScore: output.fixture.awayScore!,
        homeXg: output.result.homeStats.xg,
        awayXg: output.result.awayStats.xg,
      );
      _eventBus.publish(matchEvent);
      _economyRunner?.onMatchPlayed(matchEvent);
      played += 1;
      _logger.debug(
        'Match: ${output.fixture.homeClubId.value} ${output.fixture.homeScore}-'
        '${output.fixture.awayScore} ${output.fixture.awayClubId.value} '
        '(xG ${output.result.homeStats.xg.toStringAsFixed(2)}-'
        '${output.result.awayStats.xg.toStringAsFixed(2)}, '
        '${output.result.durationMs}ms)',
      );
    }

    _checkSeasonCompletion(date);
    return played;
  }

  void _checkSeasonCompletion(GameDate date) {
    for (final competition in _competitionManager.registry.competitions.values) {
      if (!_competitionManager.isSeasonComplete(competition.id)) {
        continue;
      }
      final alreadyFinished = _eventBus.history.whereType<SeasonFinishedEvent>().any(
            (e) =>
                e.competitionId == competition.id &&
                e.seasonYear == competition.seasonYear,
          );
      if (alreadyFinished) {
        continue;
      }
      final seasonEvent = SeasonFinishedEvent(
        competitionId: competition.id,
        seasonYear: competition.seasonYear,
        standings: _competitionManager.standings(competition.id),
        finishedOn: date,
      );
      _eventBus.publish(seasonEvent);
      _economyRunner?.onSeasonFinished(seasonEvent);
      _logger.info('Season finished: ${competition.name} (${competition.seasonYear})');
    }
  }
}
