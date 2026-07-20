import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/modules/match/match_engine.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Facade — delegates to [MatchEngine], stores results in registry.
class MatchSimulator {
  MatchSimulator({
    required SeededRng rng,
    required WorldRegistry registry,
    MatchEngineConfig? config,
    int worldSeed = 42,
  })  : _registry = registry,
        _worldSeed = worldSeed,
        _engine = MatchEngine(
          registry: registry,
          config: config ?? const MatchEngineConfig(),
        );

  final WorldRegistry _registry;
  final int _worldSeed;
  final MatchEngine _engine;

  MatchSimulationOutput simulate(MatchFixture fixture) {
    final output = _engine.simulate(fixture, worldSeed: _worldSeed);
    _registry.fixtures[fixture.id] = output.fixture;
    _registry.matchResults[fixture.id] = output.result;
    return output;
  }

  MatchResult? getResult(MatchId id) => _registry.matchResults[id];
}
