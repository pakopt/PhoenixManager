import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Academy intake — generates youth players at end of season.
class YouthEngine {
  YouthEngine({
    required WorldRegistry registry,
    required YouthConfig config,
    required StaffConfig staffConfig,
    required SeededRng rng,
    required EventBus eventBus,
  })  : _registry = registry,
        _config = config,
        _staffConfig = staffConfig,
        _rng = rng,
        _eventBus = eventBus;

  final WorldRegistry _registry;
  final YouthConfig _config;
  final StaffConfig _staffConfig;
  final SeededRng _rng;
  final EventBus _eventBus;

  static const _firstNames = [
    'Tiago', 'Lucas', 'Miguel', 'João', 'Pedro', 'André', 'Diogo', 'Rafael',
    'Tomás', 'Gonçalo', 'Duarte', 'Francisco', 'Martim', 'Guilherme',
  ];
  static const _lastNames = [
    'Silva', 'Santos', 'Costa', 'Oliveira', 'Ferreira', 'Rodrigues',
    'Martins', 'Pereira', 'Alves', 'Ribeiro', 'Carvalho', 'Gomes',
  ];

  int runSeasonIntake({required int seasonYear, required GameDate date}) {
    var total = 0;
    for (final club in _registry.clubs.values) {
      final city = _registry.cities[club.cityId];
      final finance = _registry.clubFinances[club.id];
      final academyLevel = finance?.academyLevel ?? 2;
      final traditionBonus = city?.footballTradition ?? 50;

      final intakeCount = _config.baseIntakePerClub +
          (traditionBonus / 40).floor() +
          (academyLevel ~/ 2);

      final players = <Player>[];
      for (var i = 0; i < intakeCount; i++) {
        final player = _generateYouth(
          club: club,
          city: city,
          seasonYear: seasonYear,
          index: total + i,
          scoutPaBonus: StaffBonuses.fromStaff(
            staff: _registry.staffQuery.getByClubId(club.id),
            config: _staffConfig,
          ).youthPaBonus,
        );
        _registry.registerPlayer(player);
        players.add(player);
      }

      total += players.length;
      _eventBus.publish(
        YouthIntakeEvent(
          clubId: club.id,
          players: players,
          seasonYear: seasonYear,
          date: date,
        ),
      );
    }
    return total;
  }

  Player _generateYouth({
    required Club club,
    required City? city,
    required int seasonYear,
    required int index,
    int scoutPaBonus = 0,
  }) {
    final tradition = city?.footballTradition ?? 50;
    final ca = (_config.baseCa + _rng.nextInt(_config.caVariance))
        .clamp(20, 55);
    final paBonus = (tradition * _config.traditionPaBonus).round();
    final pa = (_config.basePa + paBonus + scoutPaBonus + _rng.nextInt(_config.paVariance))
        .clamp(ca, 95);
    final age =
        _config.minAge + _rng.nextInt(_config.maxAge - _config.minAge + 1);

    final firstName = _firstNames[_rng.nextInt(_firstNames.length)];
    final lastName = _lastNames[_rng.nextInt(_lastNames.length)];

    return Player(
      id: PlayerId('youth-$seasonYear-${club.id.value}-$index'),
      name: '$firstName $lastName',
      clubId: club.id,
      age: age,
      currentAbility: ca,
      potentialAbility: pa,
      morale: 85,
      form: 55,
      salary: 500 + _rng.nextInt(1500),
      contractEndYear: seasonYear + 3,
      nationalityId: _registry.countries.values.isNotEmpty
          ? _registry.countries.values.first.id
          : null,
    );
  }
}
