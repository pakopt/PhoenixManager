import 'package:phoenix_core/src/domain/ids.dart';

/// Club entity — plantel via [clubId] query, never embedded player lists.
class Club {
  const Club({
    required this.id,
    required this.name,
    required this.cityId,
    this.shortName,
    this.reputation = 50,
    this.budget = 1000000,
    this.stadiumCapacity = 10000,
    this.coachId,
    this.logoAsset,
    this.foundedOn,
    this.association,
    this.president,
    this.address,
    this.teams = const [],
  });

  factory Club.fromMap(Map<String, dynamic> map) {
    final rawTeams = map['teams'] as List<dynamic>?;
    return Club(
      id: ClubId(map['id'] as String),
      name: map['name'] as String,
      cityId: CityId(map['cityId'] as String),
      shortName: map['shortName'] as String?,
      reputation: map['reputation'] as int? ?? 50,
      budget: map['budget'] as int? ?? 1000000,
      stadiumCapacity: map['stadiumCapacity'] as int? ?? 10000,
      coachId:
          map['coachId'] != null ? CoachId(map['coachId'] as String) : null,
      logoAsset: map['logoAsset'] as String?,
      foundedOn: map['foundedOn'] as String?,
      association: map['association'] as String?,
      president: map['president'] as String?,
      address: map['address'] as String?,
      teams: rawTeams?.map((e) => e as String).toList() ?? const [],
    );
  }

  final ClubId id;
  final String name;
  final CityId cityId;
  final String? shortName;
  final int reputation;
  final int budget;
  final int stadiumCapacity;
  final CoachId? coachId;
  final String? logoAsset;
  /// ISO date `YYYY-MM-DD` when known.
  final String? foundedOn;
  final String? association;
  final String? president;
  final String? address;
  /// Named squads / age groups (display metadata).
  final List<String> teams;

  String get displayShortName => shortName ?? name;

  Club copyWith({
    String? name,
    CityId? cityId,
    String? shortName,
    int? reputation,
    int? budget,
    int? stadiumCapacity,
    CoachId? coachId,
    String? logoAsset,
    String? foundedOn,
    String? association,
    String? president,
    String? address,
    List<String>? teams,
  }) {
    return Club(
      id: id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      shortName: shortName ?? this.shortName,
      reputation: reputation ?? this.reputation,
      budget: budget ?? this.budget,
      stadiumCapacity: stadiumCapacity ?? this.stadiumCapacity,
      coachId: coachId ?? this.coachId,
      logoAsset: logoAsset ?? this.logoAsset,
      foundedOn: foundedOn ?? this.foundedOn,
      association: association ?? this.association,
      president: president ?? this.president,
      address: address ?? this.address,
      teams: teams ?? this.teams,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'cityId': cityId.value,
        if (shortName != null) 'shortName': shortName,
        'reputation': reputation,
        'budget': budget,
        'stadiumCapacity': stadiumCapacity,
        if (coachId != null) 'coachId': coachId!.value,
        if (logoAsset != null) 'logoAsset': logoAsset,
        if (foundedOn != null) 'foundedOn': foundedOn,
        if (association != null) 'association': association,
        if (president != null) 'president': president,
        if (address != null) 'address': address,
        if (teams.isNotEmpty) 'teams': teams,
      };
}
