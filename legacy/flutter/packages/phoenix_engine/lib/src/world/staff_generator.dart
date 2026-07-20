import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Ensures every club has a full staff roster (GDD Cap. 7).
class StaffGenerator {
  StaffGenerator({required SeededRng rng}) : _rng = rng;

  final SeededRng _rng;

  static const _firstNames = [
    'Ricardo', 'Sofia', 'Hugo', 'Inês', 'Paulo', 'Catarina', 'Nuno', 'Beatriz',
    'Filipe', 'Mariana', 'Rui', 'Teresa', 'Vítor', 'Cláudia', 'Jorge',
  ];
  static const _lastNames = [
    'Almeida', 'Barbosa', 'Cardoso', 'Duarte', 'Esteves', 'Freitas', 'Lopes',
    'Monteiro', 'Nunes', 'Pinto', 'Queirós', 'Teixeira', 'Vaz', 'Xavier',
  ];

  static const _phoenixStaff = [
    ('staff-phx-asst', 'Carlos Mendes', StaffRole.assistant, 72, 8500),
    ('staff-phx-fit', 'Ana Rodrigues', StaffRole.fitnessCoach, 68, 6200),
    ('staff-phx-gk', 'Luís Pereira', StaffRole.goalkeeperCoach, 65, 4800),
    ('staff-phx-analyst', 'Pedro Sousa', StaffRole.analyst, 70, 5500),
    ('staff-phx-director', 'Helena Costa', StaffRole.sportingDirector, 75, 12000),
    ('staff-phx-doc', 'Dr. Miguel Ramos', StaffRole.doctor, 78, 9000),
    ('staff-phx-psy', 'Dra. Rita Fonseca', StaffRole.psychologist, 66, 5200),
    ('staff-phx-nutri', 'Bruno Oliveira', StaffRole.nutritionist, 64, 4500),
    ('staff-phx-scout', 'Tiago Machado', StaffRole.scout, 71, 5800),
  ];

  int ensureRoster(WorldRegistry registry) {
    var created = 0;
    for (final club in registry.clubs.values) {
      if (club.id.value == 'club-phoenix') {
        created += _seedPhoenixStaff(registry, club.id);
      }
      for (final role in StaffRole.values) {
        if (registry.staffQuery.getByClubAndRole(club.id, role) != null) {
          continue;
        }
        registry.registerStaff(_generate(club: club, role: role));
        created += 1;
      }
    }
    return created;
  }

  int _seedPhoenixStaff(WorldRegistry registry, ClubId clubId) {
    var created = 0;
    for (final entry in _phoenixStaff) {
      if (registry.staff.values.any((s) => s.id.value == entry.$1)) {
        continue;
      }
      registry.registerStaff(
        StaffMember(
          id: StaffId(entry.$1),
          name: entry.$2,
          clubId: clubId,
          role: entry.$3,
          level: entry.$4,
          salary: entry.$5,
        ),
      );
      created += 1;
    }
    return created;
  }

  StaffMember _generate({required Club club, required StaffRole role}) {
    final first = _firstNames[_rng.nextInt(_firstNames.length)];
    final last = _lastNames[_rng.nextInt(_lastNames.length)];
    final level = (club.reputation * 0.6 + _rng.nextInt(25))
        .round()
        .clamp(40, 90);
    final salary = (level * 80 + _rng.nextInt(2000)).clamp(2500, 15000);

    return StaffMember(
      id: StaffId('staff-${club.id.value}-${role.name}'),
      name: '$first $last',
      clubId: club.id,
      role: role,
      level: level,
      salary: salary,
    );
  }
}
