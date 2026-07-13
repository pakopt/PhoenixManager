import 'package:phoenix_core/phoenix_core.dart';

/// Hidden momentum — affects segment initiative without changing attributes.
class MomentumSystem {
  MomentumSystem({required MatchEngineConfig config}) : _config = config.momentum;

  final MomentumConfig _config;

  MomentumState decay(MomentumState state) {
    return MomentumState(
      home: _decayValue(state.home),
      away: _decayValue(state.away),
    );
  }

  MomentumState onGoal(MomentumState state, {required bool scorerIsHome}) {
    return state
        .withTeam(isHome: scorerIsHome, delta: _config.goalBoost)
        .withTeam(isHome: !scorerIsHome, delta: _config.concedePenalty);
  }

  MomentumState onBigChanceMiss(MomentumState state, {required bool isHome}) {
    return state.withTeam(isHome: isHome, delta: _config.bigChanceMiss);
  }

  double initiativeBonus(MomentumState state, {required bool isHome}) {
    return state.forTeam(isHome: isHome) * 0.15;
  }

  double _decayValue(double value) {
    if (value > 0) {
      return (value - _config.decayPerSegment).clamp(_config.min, _config.max);
    }
    if (value < 0) {
      return (value + _config.decayPerSegment).clamp(_config.min, _config.max);
    }
    return 0;
  }
}
