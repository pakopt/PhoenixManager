import 'package:phoenix_core/src/domain/ids.dart';

/// Player entity — SSOT: [clubId] is the authoritative club reference.
class Player {
  const Player({
    required this.id,
    required this.name,
    required this.clubId,
    required this.age,
    required this.currentAbility,
    required this.potentialAbility,
    this.morale = 70,
    this.form = 50,
    this.salary = 0,
    this.contractEndYear = 2028,
    this.nationalityId,
    this.injuredDaysRemaining = 0,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: PlayerId(map['id'] as String),
      name: map['name'] as String,
      clubId: ClubId(map['clubId'] as String),
      age: map['age'] as int,
      currentAbility: map['currentAbility'] as int,
      potentialAbility: map['potentialAbility'] as int,
      morale: map['morale'] as int? ?? 70,
      form: map['form'] as int? ?? 50,
      salary: map['salary'] as int? ?? 0,
      contractEndYear: map['contractEndYear'] as int? ?? 2028,
      nationalityId: map['nationalityId'] != null
          ? CountryId(map['nationalityId'] as String)
          : null,
      injuredDaysRemaining: map['injuredDaysRemaining'] as int? ?? 0,
    );
  }

  final PlayerId id;
  final String name;
  final ClubId clubId;
  final int age;
  final int currentAbility;
  final int potentialAbility;
  final int morale;
  final int form;
  final int salary;
  final int contractEndYear;
  final CountryId? nationalityId;
  final int injuredDaysRemaining;

  bool get isInjured => injuredDaysRemaining > 0;

  Player copyWith({
    ClubId? clubId,
    int? age,
    int? currentAbility,
    int? morale,
    int? form,
    int? salary,
    int? contractEndYear,
    int? injuredDaysRemaining,
  }) {
    return Player(
      id: id,
      name: name,
      clubId: clubId ?? this.clubId,
      age: age ?? this.age,
      currentAbility: currentAbility ?? this.currentAbility,
      potentialAbility: potentialAbility,
      morale: morale ?? this.morale,
      form: form ?? this.form,
      salary: salary ?? this.salary,
      contractEndYear: contractEndYear ?? this.contractEndYear,
      nationalityId: nationalityId,
      injuredDaysRemaining: injuredDaysRemaining ?? this.injuredDaysRemaining,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'clubId': clubId.value,
        'age': age,
        'currentAbility': currentAbility,
        'potentialAbility': potentialAbility,
        'morale': morale,
        'form': form,
        'salary': salary,
        'contractEndYear': contractEndYear,
        if (nationalityId != null) 'nationalityId': nationalityId!.value,
        if (injuredDaysRemaining > 0)
          'injuredDaysRemaining': injuredDaysRemaining,
      };
}
