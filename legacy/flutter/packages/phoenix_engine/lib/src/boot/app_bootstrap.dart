import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_data/phoenix_data.dart';
import 'package:phoenix_engine/src/boot/engine_context.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/modules/achievement/achievement_engine.dart';
import 'package:phoenix_engine/src/modules/competition/competition_manager.dart';
import 'package:phoenix_engine/src/modules/finance/finance_engine.dart';
import 'package:phoenix_engine/src/modules/match/match_simulator.dart';
import 'package:phoenix_engine/src/modules/training/training_engine.dart';
import 'package:phoenix_engine/src/modules/transfer/transfer_engine.dart';
import 'package:phoenix_engine/src/modules/contract/contract_engine.dart';
import 'package:phoenix_engine/src/modules/injury/injury_engine.dart';
import 'package:phoenix_engine/src/modules/youth/youth_engine.dart';
import 'package:phoenix_engine/src/save/save_manager.dart';
import 'package:phoenix_engine/src/simulation/daily_simulation_runner.dart';
import 'package:phoenix_engine/src/simulation/economy_simulation_runner.dart';
import 'package:phoenix_engine/src/simulation/simulation_engine.dart';
import 'package:phoenix_engine/src/simulation/time_controller.dart';
import 'package:phoenix_engine/src/world/world_manager.dart';
import 'package:phoenix_engine/src/world/squad_generator.dart';
import 'package:phoenix_engine/src/world/staff_generator.dart';
import 'package:phoenix_engine/src/world/world_pack_loader.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Boot sequence: Config → Logger → DI → Database → World → Simulation.
class AppBootstrap {
  AppBootstrap({
    ConfigLoader? configLoader,
    MatchConfigLoader? matchConfigLoader,
    EconomyConfigLoader? economyConfigLoader,
    DatabaseAdapter? database,
    WorldPackLoader? packLoader,
  })  : _configLoader = configLoader ?? ConfigLoader(),
        _matchConfigLoader = matchConfigLoader ?? MatchConfigLoader(),
        _economyConfigLoader = economyConfigLoader ?? EconomyConfigLoader(),
        _database = database ?? InMemoryDatabase(),
        _packLoader = packLoader ?? WorldPackLoader();

  final ConfigLoader _configLoader;
  final MatchConfigLoader _matchConfigLoader;
  final EconomyConfigLoader _economyConfigLoader;
  final DatabaseAdapter _database;
  final WorldPackLoader _packLoader;

  Future<EngineContext> boot({
    String configYaml = _defaultConfigYaml,
    String matchConfigYaml = _defaultMatchConfigYaml,
    String economyConfigYaml = _defaultEconomyConfigYaml,
    String databasePackId = 'liga-phoenix-alpha',
    String worldId = 'world-alpha',
    bool scheduleSeason = true,
  }) async {
    final container = ServiceContainer();
    final config = _configLoader.loadFromYaml(configYaml);
    final matchConfig = _matchConfigLoader.loadFromYaml(matchConfigYaml);
    final economyConfig = _economyConfigLoader.loadFromYaml(economyConfigYaml);
    final logger = PhoenixLogger(minLevel: LogLevel.info);
    final eventBus = EventBus();
    final rng = SeededRng(config.defaultSeed);

    container.registerSingleton<PhoenixConfig>(config);
    container.registerSingleton<PhoenixLogger>(logger);
    container.registerSingleton<EventBus>(eventBus);
    container.registerSingleton<SeededRng>(rng);
    container.registerSingleton<DatabaseAdapter>(_database);

    await _database.open(packId: databasePackId);

    final registry = _packLoader.loadLigaPhoenixAlpha();
    StaffGenerator(rng: rng).ensureRoster(registry);
    SquadGenerator(rng: rng).ensureMinimumSquad(registry);
    final competitionManager = CompetitionManager(
      registry: registry,
      eventBus: eventBus,
    );

    if (scheduleSeason) {
      competitionManager.scheduleSeason(
        competitionId: const CompetitionId('liga-phoenix'),
        seasonStart: GameDate(year: 2026, month: 8, day: 15),
        daysBetweenRounds: 7,
      );
      competitionManager.scheduleCup(
        competitionId: const CompetitionId('taca-phoenix'),
      );
    }

    final worldManager = WorldManager(
      eventBus: eventBus,
      logger: logger,
    )..initialize(worldId: worldId, seed: config.defaultSeed);

    final matchSimulator = MatchSimulator(
      rng: rng,
      registry: registry,
      config: matchConfig,
      worldSeed: config.defaultSeed,
    );

    final financeEngine = FinanceEngine(
      registry: registry,
      config: economyConfig.finance,
      staffConfig: economyConfig.staff,
      eventBus: eventBus,
    );
    final trainingEngine = TrainingEngine(
      registry: registry,
      config: economyConfig.training,
      staffConfig: economyConfig.staff,
      rng: rng,
    );
    final transferEngine = TransferEngine(
      registry: registry,
      config: economyConfig.transfer,
      financeEngine: financeEngine,
      eventBus: eventBus,
      rng: rng,
    );
    final youthEngine = YouthEngine(
      registry: registry,
      config: economyConfig.youth,
      staffConfig: economyConfig.staff,
      rng: rng,
      eventBus: eventBus,
    );
    final injuryEngine = InjuryEngine(
      registry: registry,
      config: economyConfig.injury,
      staffConfig: economyConfig.staff,
      rng: rng,
      eventBus: eventBus,
    );
    final contractEngine = ContractEngine(
      registry: registry,
      config: economyConfig.contract,
      financeEngine: financeEngine,
      eventBus: eventBus,
    );
    final economyRunner = EconomySimulationRunner(
      financeEngine: financeEngine,
      trainingEngine: trainingEngine,
      transferEngine: transferEngine,
      youthEngine: youthEngine,
      injuryEngine: injuryEngine,
      contractEngine: contractEngine,
      registry: registry,
    )..initialize();

    final dailyRunner = DailySimulationRunner(
      competitionManager: competitionManager,
      matchSimulator: matchSimulator,
      eventBus: eventBus,
      logger: logger,
      economyRunner: economyRunner,
    );

    final achievementEngine = AchievementEngine(
      registry: registry,
      eventBus: eventBus,
      competitionManager: competitionManager,
    );

    final simulationEngine = SimulationEngine(
      worldManager: worldManager,
      dailyRunner: dailyRunner,
    );

    final timeController = TimeController(
      simulationEngine: simulationEngine,
      config: config,
    );

    final saveManager = SaveManager(eventBus: eventBus);

    container.registerSingleton<MatchEngineConfig>(matchConfig);
    container.registerSingleton<EconomyConfig>(economyConfig);
    container.registerSingleton<WorldRegistry>(registry);
    container.registerSingleton<CompetitionManager>(competitionManager);
    container.registerSingleton<MatchSimulator>(matchSimulator);
    container.registerSingleton<FinanceEngine>(financeEngine);
    container.registerSingleton<ContractEngine>(contractEngine);
    container.registerSingleton<EconomySimulationRunner>(economyRunner);
    container.registerSingleton<AchievementEngine>(achievementEngine);
    container.registerSingleton<WorldManager>(worldManager);
    container.registerSingleton<SimulationEngine>(simulationEngine);
    container.registerSingleton<TimeController>(timeController);
    container.registerSingleton<SaveManager>(saveManager);

    logger.info(
      'PSE v0.8 boot — sport=${config.sport}, clubs=${registry.clubs.length}, '
      'players=${registry.players.length}, fixtures=${registry.fixtures.length}, '
      'segments=${matchConfig.segmentCount}, finances=${registry.clubFinances.length}',
    );

    return EngineContext(
      container: container,
      config: config,
      matchConfig: matchConfig,
      economyConfig: economyConfig,
      logger: logger,
      eventBus: eventBus,
      database: _database,
      registry: registry,
      competitionManager: competitionManager,
      matchSimulator: matchSimulator,
      economyRunner: economyRunner,
      worldManager: worldManager,
      simulationEngine: simulationEngine,
      timeController: timeController,
      saveManager: saveManager,
    );
  }
}

const _defaultConfigYaml = '''
engineVersion: 0.8.47
sport: football
defaultSeed: 42
simulation:
  daysPerWeek: 7
  weeksPerSeason: 38
''';

const _defaultMatchConfigYaml = '''
segmentCount: 45
minutesPerSegment: 2
highlightMinGrade: dangerous
momentum:
  goalBoost: 15
  concedePenalty: -12
  bigChanceMiss: -8
  decayPerSegment: 1.5
  min: -50
  max: 50
xg:
  penalty: 0.76
  headerBox: 0.62
  oneOnOne: 0.45
  dangerous: 0.22
  moderate: 0.12
  weak: 0.04
''';

const _defaultEconomyConfigYaml = '''
finance:
  salaryPaymentDay: 1
  ticketPricePerSeat: 25
  attendanceRate: 0.72
  dailySponsorIncome: 1500
  ffpWageRatioLimit: 0.65
transfer:
  windowMonths: [1, 7, 8]
  minBudgetToBuy: 500000
  feeAcceptRatio: 0.85
  maxTransfersPerClubPerWindow: 2
training:
  dailyCaGainMax: 1
  dailyCaGainChance: 0.15
  maxAgeForGrowth: 28
  matchWinMoraleBoost: 3
  matchLossMoralePenalty: 2
  matchFormWinBoost: 5
  matchFormLossPenalty: 4
youth:
  baseIntakePerClub: 2
  minAge: 16
  maxAge: 18
  baseCa: 35
  caVariance: 12
  basePa: 55
  paVariance: 25
  traditionPaBonus: 0.3
injury:
  matchInjuryChance: 0.035
  minDaysOut: 3
  maxDaysOut: 21
  maxInjuredPerClubPerMatch: 1
staff:
  trainingBonusPerLevel: 0.0008
  injuryDaysReductionPerLevel: 0.04
  maxInjuryDaysReduction: 5
  youthPaBonusPerLevel: 0.05
  coachWagePerReputation: 500
  moraleBoostPerLevel: 0.02
  maxMoraleDailyBoost: 2
  injuryChanceReductionPerLevel: 0.0003
  maxInjuryChanceReduction: 0.015
contract:
  defaultExtensionYears: 2
  minExtensionYears: 1
  maxExtensionYears: 4
  salaryIncreaseRatio: 0.10
  moraleBoostOnRenewal: 5
''';
