import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Injury recovery and match-day risk — off-screen medical simulation.
class InjuryEngine {
  InjuryEngine({
    required WorldRegistry registry,
    required InjuryConfig config,
    required StaffConfig staffConfig,
    required SeededRng rng,
    required EventBus eventBus,
  })  : _registry = registry,
        _config = config,
        _staffConfig = staffConfig,
        _rng = rng,
        _eventBus = eventBus;

  final WorldRegistry _registry;
  final InjuryConfig _config;
  final StaffConfig _staffConfig;
  final SeededRng _rng;
  final EventBus _eventBus;

  int runDaily() {
    var recovered = 0;
    for (final entry in _registry.players.entries) {
      final player = entry.value;
      if (player.injuredDaysRemaining <= 0) {
        continue;
      }
      final remaining = player.injuredDaysRemaining - 1;
      if (remaining <= 0) {
        _registry.players[entry.key] =
            player.copyWith(injuredDaysRemaining: 0);
        _eventBus.publish(
          PlayerRecoveredEvent(
            playerId: player.id,
            playerName: player.name,
            clubId: player.clubId,
          ),
        );
        recovered += 1;
      } else {
        _registry.players[entry.key] =
            player.copyWith(injuredDaysRemaining: remaining);
      }
    }
    return recovered;
  }

  void applyMatchInjuries({
    required ClubId homeClubId,
    required ClubId awayClubId,
    required GameDate date,
  }) {
    _rollClubInjuries(homeClubId, date);
    _rollClubInjuries(awayClubId, date);
  }

  void _rollClubInjuries(ClubId clubId, GameDate date) {
    final squad = _registry.squadQuery
        .getByClubId(clubId)
        .where((p) => !p.isInjured)
        .toList();
    if (squad.isEmpty) {
      return;
    }

    var injuries = 0;
    final bonuses = StaffBonuses.fromStaff(
      staff: _registry.staffQuery.getByClubId(clubId),
      config: _staffConfig,
    );
    final injuryChance =
        (_config.matchInjuryChance - bonuses.injuryChanceReduction).clamp(0.0, 1.0);

    for (final player in squad) {
      if (injuries >= _config.maxInjuredPerClubPerMatch) {
        break;
      }
      if (_rng.nextDouble() > injuryChance) {
        continue;
      }

      final span = _config.maxDaysOut - _config.minDaysOut + 1;
      var daysOut = _config.minDaysOut + _rng.nextInt(span);
      final reduction = bonuses.injuryDaysReduction;
      daysOut = (daysOut - reduction).clamp(_config.minDaysOut, _config.maxDaysOut);

      _registry.players[player.id] =
          player.copyWith(injuredDaysRemaining: daysOut);
      _eventBus.publish(
        PlayerInjuredEvent(
          playerId: player.id,
          playerName: player.name,
          clubId: clubId,
          daysOut: daysOut,
          date: date,
        ),
      );
      injuries += 1;
    }
  }
}
