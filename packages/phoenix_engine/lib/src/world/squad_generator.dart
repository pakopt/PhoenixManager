import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Garante plantel mínimo por clube (XI + suplentes) para UI e gestão.
class SquadGenerator {
  SquadGenerator({required SeededRng rng, this.minSize = 16}) : _rng = rng;

  final SeededRng _rng;
  final int minSize;

  static const _firstNames = [
    'Afonso', 'Bruno', 'César', 'Daniel', 'Edgar', 'Fábio', 'Gonçalo', 'Hélder',
    'Ivo', 'Jorge', 'Kevin', 'Leandro', 'Marco', 'Nelson', 'Óscar', 'Paulo',
    'Rúben', 'Sérgio', 'Tiago', 'Vasco', 'Wilson', 'Xavier', 'Yuri', 'Zé',
  ];
  static const _lastNames = [
    'Abreu', 'Borges', 'Campos', 'Domingos', 'Estevão', 'Faria', 'Guerreiro',
    'Henriques', 'Isaías', 'Jesus', 'Laranjeira', 'Magalhães', 'Neves',
    'Ornelas', 'Pacheco', 'Quaresma', 'Rebelo', 'Sousa', 'Tavares', 'Valente',
  ];

  int ensureMinimumSquad(WorldRegistry registry) {
    var created = 0;
    for (final club in registry.clubs.values) {
      final squad = registry.squadQuery.getByClubId(club.id);
      final missing = minSize - squad.length;
      if (missing <= 0) {
        continue;
      }
      for (var i = 0; i < missing; i++) {
        registry.registerPlayer(
          _generate(
            club: club,
            index: squad.length + i,
            registry: registry,
          ),
        );
        created += 1;
      }
    }
    return created;
  }

  static const _roles = ['GR', 'DF', 'DF', 'DF', 'MD', 'MD', 'MD', 'MO', 'EX', 'PL', 'PL'];

  Player _generate({
    required Club club,
    required int index,
    required WorldRegistry registry,
  }) {
    final first = _firstNames[_rng.nextInt(_firstNames.length)];
    final last = _lastNames[_rng.nextInt(_lastNames.length)];
    final caBase = (club.reputation * 0.55 + _rng.nextInt(18)).round();
    final ca = caBase.clamp(48, 78);
    final pa = (ca + 2 + _rng.nextInt(12)).clamp(ca, 92);
    final age = 18 + _rng.nextInt(16);
    final salary = (ca * 280 + club.reputation * 40 + _rng.nextInt(4000))
        .clamp(2500, 48000);
    final contractEnd = 2027 + _rng.nextInt(4);
    final position = _roles[index % _roles.length];

    return Player(
      id: PlayerId('p-gen-${club.id.value}-$index'),
      name: '$first $last',
      clubId: club.id,
      age: age,
      currentAbility: ca,
      potentialAbility: pa,
      morale: 62 + _rng.nextInt(25),
      form: 45 + _rng.nextInt(30),
      salary: salary,
      contractEndYear: contractEnd,
      position: position,
      nationalityId: registry.countries.values.isNotEmpty
          ? registry.countries.values.first.id
          : null,
    );
  }
}
