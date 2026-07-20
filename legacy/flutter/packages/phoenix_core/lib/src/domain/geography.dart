import 'package:phoenix_core/src/domain/ids.dart';

/// World → Continents → Countries → Regions → Cities → Clubs
class Continent {
  const Continent({required this.id, required this.name});

  factory Continent.fromMap(Map<String, dynamic> map) {
    return Continent(
      id: ContinentId(map['id'] as String),
      name: map['name'] as String,
    );
  }

  final ContinentId id;
  final String name;

  Map<String, dynamic> toMap() => {'id': id.value, 'name': name};
}

class Country {
  const Country({
    required this.id,
    required this.name,
    required this.continentId,
    this.reputation = 50,
  });

  factory Country.fromMap(Map<String, dynamic> map) {
    return Country(
      id: CountryId(map['id'] as String),
      name: map['name'] as String,
      continentId: ContinentId(map['continentId'] as String),
      reputation: map['reputation'] as int? ?? 50,
    );
  }

  final CountryId id;
  final String name;
  final ContinentId continentId;
  final int reputation;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'continentId': continentId.value,
        'reputation': reputation,
      };
}

class Region {
  const Region({
    required this.id,
    required this.name,
    required this.countryId,
    this.footballTradition = 50,
    this.creativityBias = 0,
    this.disciplineBias = 0,
    this.physicalBias = 0,
  });

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      id: RegionId(map['id'] as String),
      name: map['name'] as String,
      countryId: CountryId(map['countryId'] as String),
      footballTradition: map['footballTradition'] as int? ?? 50,
      creativityBias: map['creativityBias'] as int? ?? 0,
      disciplineBias: map['disciplineBias'] as int? ?? 0,
      physicalBias: map['physicalBias'] as int? ?? 0,
    );
  }

  final RegionId id;
  final String name;
  final CountryId countryId;
  final int footballTradition;
  final int creativityBias;
  final int disciplineBias;
  final int physicalBias;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'countryId': countryId.value,
        'footballTradition': footballTradition,
        'creativityBias': creativityBias,
        'disciplineBias': disciplineBias,
        'physicalBias': physicalBias,
      };
}

class City {
  const City({
    required this.id,
    required this.name,
    required this.regionId,
    this.population = 100000,
    this.economy = 50,
    this.footballTradition = 50,
  });

  factory City.fromMap(Map<String, dynamic> map) {
    return City(
      id: CityId(map['id'] as String),
      name: map['name'] as String,
      regionId: RegionId(map['regionId'] as String),
      population: map['population'] as int? ?? 100000,
      economy: map['economy'] as int? ?? 50,
      footballTradition: map['footballTradition'] as int? ?? 50,
    );
  }

  final CityId id;
  final String name;
  final RegionId regionId;
  final int population;
  final int economy;
  final int footballTradition;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'regionId': regionId.value,
        'population': population,
        'economy': economy,
        'footballTradition': footballTradition,
      };
}
