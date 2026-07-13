import 'package:phoenix_core/src/domain/ids.dart';

/// Club entity — plantel via [clubId] query, never embedded player lists.
class Club {
  const Club({
    required this.id,
    required this.name,
    required this.cityId,
    this.reputation = 50,
    this.budget = 1000000,
    this.stadiumCapacity = 10000,
    this.coachId,
  });

  factory Club.fromMap(Map<String, dynamic> map) {
    return Club(
      id: ClubId(map['id'] as String),
      name: map['name'] as String,
      cityId: CityId(map['cityId'] as String),
      reputation: map['reputation'] as int? ?? 50,
      budget: map['budget'] as int? ?? 1000000,
      stadiumCapacity: map['stadiumCapacity'] as int? ?? 10000,
      coachId:
          map['coachId'] != null ? CoachId(map['coachId'] as String) : null,
    );
  }

  final ClubId id;
  final String name;
  final CityId cityId;
  final int reputation;
  final int budget;
  final int stadiumCapacity;
  final CoachId? coachId;

  Club copyWith({
    int? reputation,
    int? budget,
    CoachId? coachId,
  }) {
    return Club(
      id: id,
      name: name,
      cityId: cityId,
      reputation: reputation ?? this.reputation,
      budget: budget ?? this.budget,
      stadiumCapacity: stadiumCapacity,
      coachId: coachId ?? this.coachId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'cityId': cityId.value,
        'reputation': reputation,
        'budget': budget,
        'stadiumCapacity': stadiumCapacity,
        if (coachId != null) 'coachId': coachId!.value,
      };
}
