import 'package:phoenix_core/src/domain/ids.dart';

/// Staff roles — GDD Cap. 7 (excluding head coach, stored as [Coach]).
enum StaffRole {
  assistant,
  fitnessCoach,
  goalkeeperCoach,
  analyst,
  sportingDirector,
  doctor,
  psychologist,
  nutritionist,
  scout,
}

/// Non-head-coach staff member.
class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.clubId,
    required this.role,
    this.level = 50,
    this.salary = 3000,
  });

  factory StaffMember.fromMap(Map<String, dynamic> map) {
    return StaffMember(
      id: StaffId(map['id'] as String),
      name: map['name'] as String,
      clubId: ClubId(map['clubId'] as String),
      role: StaffRole.values.byName(map['role'] as String),
      level: map['level'] as int? ?? 50,
      salary: map['salary'] as int? ?? 3000,
    );
  }

  final StaffId id;
  final String name;
  final ClubId clubId;
  final StaffRole role;
  final int level;
  final int salary;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'clubId': clubId.value,
        'role': role.name,
        'level': level,
        'salary': salary,
      };
}
