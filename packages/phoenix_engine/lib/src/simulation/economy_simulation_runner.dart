import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/finance/finance_engine.dart';
import 'package:phoenix_engine/src/modules/training/training_engine.dart';
import 'package:phoenix_engine/src/modules/transfer/transfer_engine.dart';
import 'package:phoenix_engine/src/modules/contract/contract_engine.dart';
import 'package:phoenix_engine/src/modules/injury/injury_engine.dart';
import 'package:phoenix_engine/src/modules/youth/youth_engine.dart';
import 'package:phoenix_engine/src/world/squad_generator.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Orchestrates economy systems on daily and season-end ticks.
class EconomySimulationRunner {
  EconomySimulationRunner({
    required FinanceEngine financeEngine,
    required TrainingEngine trainingEngine,
    required TransferEngine transferEngine,
    required YouthEngine youthEngine,
    required InjuryEngine injuryEngine,
    required ContractEngine contractEngine,
    required WorldRegistry registry,
  })  : _financeEngine = financeEngine,
        _trainingEngine = trainingEngine,
        _transferEngine = transferEngine,
        _youthEngine = youthEngine,
        _injuryEngine = injuryEngine,
        _contractEngine = contractEngine,
        _registry = registry;

  final FinanceEngine _financeEngine;
  final TrainingEngine _trainingEngine;
  final TransferEngine _transferEngine;
  final YouthEngine _youthEngine;
  final InjuryEngine _injuryEngine;
  final ContractEngine _contractEngine;
  final WorldRegistry _registry;

  ContractEngine get contractEngine => _contractEngine;

  TransferEngine get transferEngine => _transferEngine;

  /// Compra no mercado pelo clube do utilizador.
  String? tryUserBuyPlayer({
    required ClubId buyerId,
    required PlayerId playerId,
    required GameDate date,
  }) {
    return _transferEngine.tryUserBuy(
      buyerId: buyerId,
      playerId: playerId,
      date: date,
    );
  }

  /// Assinatura a custo zero (contrato expirado).
  String? tryUserSignFreeAgent({
    required ClubId buyerId,
    required PlayerId playerId,
    required GameDate date,
  }) {
    return _transferEngine.tryUserSignFree(
      buyerId: buyerId,
      playerId: playerId,
      date: date,
    );
  }

  /// Upgrade de instalação (treinos / academia).
  String? tryUpgradeFacility({
    required ClubId clubId,
    required FacilityKind kind,
    required GameDate date,
  }) {
    return _financeEngine.tryUpgradeFacility(
      clubId: clubId,
      kind: kind,
      date: date,
    );
  }

  void initialize() {
    _financeEngine.initializeFromClubs();
  }

  /// Completa plantéis curtos (ex. saves antigos) e actualiza salários.
  int ensureSquadDepth(SeededRng rng) {
    final created = SquadGenerator(rng: rng).ensureMinimumSquad(_registry);
    if (created > 0) {
      for (final club in _registry.clubs.values) {
        _financeEngine.refreshMonthlyWages(club.id);
      }
    }
    return created;
  }

  int runDaily(GameDate date) {
    var operations = 0;
    operations += _financeEngine.runDaily(date);
    operations += _injuryEngine.runDaily();
    operations += _trainingEngine.runDaily();
    operations += _transferEngine.runDaily(date);
    return operations;
  }

  void onMatchPlayed(MatchPlayedEvent event) {
    final homeClub = _registry.getClub(event.homeClubId);
    if (homeClub != null) {
      _financeEngine.recordMatchDayRevenue(
        homeClubId: event.homeClubId,
        homeClub: homeClub,
        date: event.fixture.date,
      );
    }

    final homeWon = event.homeScore > event.awayScore;
    final awayWon = event.awayScore > event.homeScore;
    final drawn = event.homeScore == event.awayScore;

    _trainingEngine.applyMatchResult(
      clubId: event.homeClubId,
      won: homeWon,
      drawn: drawn,
    );
    _trainingEngine.applyMatchResult(
      clubId: event.awayClubId,
      won: awayWon,
      drawn: drawn,
    );
    _injuryEngine.applyMatchInjuries(
      homeClubId: event.homeClubId,
      awayClubId: event.awayClubId,
      date: event.fixture.date,
    );
  }

  void onSeasonFinished(SeasonFinishedEvent event) {
    _youthEngine.runSeasonIntake(
      seasonYear: event.seasonYear,
      date: event.finishedOn,
    );
    _transferEngine.processExpiredContracts(event.finishedOn);
    _transferEngine.resetWindowCounters();
    resetSeasonFinanceStats();
  }

  void resetSeasonFinanceStats() {
    _resetSeasonFinanceStats();
  }

  void _resetSeasonFinanceStats() {
    for (final entry in _registry.clubFinances.entries) {
      _registry.clubFinances[entry.key] = entry.value.copyWith(
        seasonRevenue: 0,
        seasonExpenses: 0,
      );
    }
  }
}
