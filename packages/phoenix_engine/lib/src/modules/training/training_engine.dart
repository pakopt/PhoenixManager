import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Daily training — CA growth, form and morale from match results.
class TrainingEngine {
  TrainingEngine({
    required WorldRegistry registry,
    required TrainingConfig config,
    required StaffConfig staffConfig,
    required SeededRng rng,
  })  : _registry = registry,
        _config = config,
        _staffConfig = staffConfig,
        _rng = rng;

  final WorldRegistry _registry;
  final TrainingConfig _config;
  final StaffConfig _staffConfig;
  final SeededRng _rng;

  int runDaily() {
    var updates = 0;
    for (final club in _registry.clubs.values) {
      final bonuses = StaffBonuses.fromStaff(
        staff: _registry.staffQuery.getByClubId(club.id),
        config: _staffConfig,
      );
      updates += _runDailyForClub(
        club.id,
        chanceBonus: bonuses.trainingChanceBonus,
        moraleBoost: bonuses.moraleDailyBoost,
      );
    }
    return updates;
  }

  int _runDailyForClub(
    ClubId clubId, {
    required double chanceBonus,
    required int moraleBoost,
  }) {
    var updates = 0;
    final squad = _registry.squadQuery.getByClubId(clubId);
    for (final player in squad) {
      var current = player;

      if (moraleBoost > 0 && !current.isInjured && current.morale < 100) {
        final newMorale = (current.morale + moraleBoost).clamp(1, 100);
        if (newMorale != current.morale) {
          current = current.copyWith(morale: newMorale);
          _registry.players[current.id] = current;
          updates += 1;
        }
      }

      if (current.age > _config.maxAgeForGrowth) {
        continue;
      }
      if (current.currentAbility >= current.potentialAbility) {
        continue;
      }
      if (current.isInjured) {
        continue;
      }
      if (_rng.nextDouble() > _config.dailyCaGainChance + chanceBonus) {
        continue;
      }

      final gain = 1 + _rng.nextInt(_config.dailyCaGainMax);
      final newCa =
          (current.currentAbility + gain).clamp(1, current.potentialAbility);
      if (newCa == current.currentAbility) {
        continue;
      }

      _registry.players[current.id] = current.copyWith(currentAbility: newCa);
      updates += 1;
    }
    return updates;
  }

  void applyMatchResult({
    required ClubId clubId,
    required bool won,
    required bool drawn,
  }) {
    final squad = _registry.squadQuery.getByClubId(clubId);
    for (final player in squad) {
      final moraleDelta = won
          ? _config.matchWinMoraleBoost
          : drawn
              ? 0
              : -_config.matchLossMoralePenalty;
      final formDelta = won
          ? _config.matchFormWinBoost
          : drawn
              ? 1
              : -_config.matchFormLossPenalty;

      _registry.players[player.id] = player.copyWith(
        morale: (player.morale + moraleDelta).clamp(1, 100),
        form: (player.form + formDelta).clamp(1, 100),
      );
    }
  }
}
