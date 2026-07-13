import 'dart:convert';
import 'dart:io';

import 'package:phoenix_engine/src/world/world_registry.dart';

/// Loads official database packs into a [WorldRegistry].
class WorldPackLoader {
  WorldRegistry loadFromJson(String jsonText) {
    final map = jsonDecode(jsonText) as Map<String, dynamic>;
    return WorldRegistry.fromMap(map);
  }

  WorldRegistry loadFromFile(String path) {
    return loadFromJson(File(path).readAsStringSync());
  }

  /// Built-in Liga Phoenix MVP pack (4 clubs, fictional data).
  WorldRegistry loadLigaPhoenixAlpha() {
    return loadFromJson(_ligaPhoenixAlphaJson);
  }
}

const _ligaPhoenixAlphaJson = '''
{
  "continents": [
    {"id": "eu", "name": "Europa"}
  ],
  "countries": [
    {"id": "phoenix-nation", "name": "Nação Phoenix", "continentId": "eu", "reputation": 62}
  ],
  "regions": [
    {"id": "central", "name": "Região Central", "countryId": "phoenix-nation", "footballTradition": 72, "disciplineBias": 3}
  ],
  "cities": [
    {"id": "phoenix-city", "name": "Phoenix City", "regionId": "central", "population": 420000, "economy": 68, "footballTradition": 80},
    {"id": "riverside", "name": "Riverside", "regionId": "central", "population": 180000, "economy": 55, "footballTradition": 65},
    {"id": "highland", "name": "Highland", "regionId": "central", "population": 95000, "economy": 48, "footballTradition": 58},
    {"id": "union-town", "name": "Union Town", "regionId": "central", "population": 210000, "economy": 60, "footballTradition": 70}
  ],
  "clubs": [
    {"id": "club-phoenix", "name": "Phoenix FC", "cityId": "phoenix-city", "reputation": 78, "budget": 8500000, "stadiumCapacity": 32000, "coachId": "coach-phoenix"},
    {"id": "club-union", "name": "Union City", "cityId": "union-town", "reputation": 71, "budget": 5200000, "stadiumCapacity": 24000, "coachId": "coach-union"},
    {"id": "club-riverside", "name": "Riverside SC", "cityId": "riverside", "reputation": 65, "budget": 3100000, "stadiumCapacity": 14000, "coachId": "coach-riverside"},
    {"id": "club-highland", "name": "Highland Athletic", "cityId": "highland", "reputation": 58, "budget": 1800000, "stadiumCapacity": 9000, "coachId": "coach-highland"}
  ],
  "coaches": [
    {"id": "coach-phoenix", "name": "Marco Silva", "clubId": "club-phoenix", "reputation": 74, "personality": "idealist", "licenseLevel": 4},
    {"id": "coach-union", "name": "Ana Costa", "clubId": "club-union", "reputation": 68, "personality": "pragmatist", "licenseLevel": 3},
    {"id": "coach-riverside", "name": "João Mendes", "clubId": "club-riverside", "reputation": 61, "personality": "youthDeveloper", "licenseLevel": 2},
    {"id": "coach-highland", "name": "Pedro Alves", "clubId": "club-highland", "reputation": 55, "personality": "disciplinarian", "licenseLevel": 2}
  ],
  "players": [
    {"id": "p-phx-1", "name": "Rui Costa", "clubId": "club-phoenix", "age": 27, "currentAbility": 74, "potentialAbility": 76, "morale": 78, "salary": 45000, "contractEndYear": 2028, "nationalityId": "phoenix-nation"},
    {"id": "p-phx-2", "name": "Diego Lima", "clubId": "club-phoenix", "age": 24, "currentAbility": 71, "potentialAbility": 80, "morale": 75, "salary": 38000, "contractEndYear": 2029, "nationalityId": "phoenix-nation"},
    {"id": "p-phx-3", "name": "Tomás Ferreira", "clubId": "club-phoenix", "age": 31, "currentAbility": 72, "potentialAbility": 72, "morale": 70, "salary": 42000, "contractEndYear": 2027, "nationalityId": "phoenix-nation"},
    {"id": "p-uni-1", "name": "Bruno Santos", "clubId": "club-union", "age": 26, "currentAbility": 70, "potentialAbility": 73, "morale": 72, "salary": 35000, "contractEndYear": 2028, "nationalityId": "phoenix-nation"},
    {"id": "p-uni-2", "name": "Carlos Neto", "clubId": "club-union", "age": 29, "currentAbility": 68, "potentialAbility": 68, "morale": 68, "salary": 32000, "contractEndYear": 2027, "nationalityId": "phoenix-nation"},
    {"id": "p-riv-1", "name": "Miguel Rocha", "clubId": "club-riverside", "age": 22, "currentAbility": 65, "potentialAbility": 78, "morale": 80, "salary": 18000, "contractEndYear": 2030, "nationalityId": "phoenix-nation"},
    {"id": "p-riv-2", "name": "Hugo Dias", "clubId": "club-riverside", "age": 28, "currentAbility": 64, "potentialAbility": 65, "morale": 66, "salary": 22000, "contractEndYear": 2028, "nationalityId": "phoenix-nation"},
    {"id": "p-hig-1", "name": "André Pires", "clubId": "club-highland", "age": 25, "currentAbility": 62, "potentialAbility": 70, "morale": 74, "salary": 15000, "contractEndYear": 2029, "nationalityId": "phoenix-nation"},
    {"id": "p-hig-2", "name": "Nuno Vieira", "clubId": "club-highland", "age": 33, "currentAbility": 60, "potentialAbility": 60, "morale": 65, "salary": 14000, "contractEndYear": 2026, "nationalityId": "phoenix-nation"}
  ],
  "competitions": [
    {
      "id": "liga-phoenix",
      "name": "Liga Phoenix",
      "type": "league",
      "seasonYear": 2026,
      "participantClubIds": ["club-phoenix", "club-union", "club-riverside", "club-highland"],
      "rules": {"pointsWin": 3, "pointsDraw": 1, "pointsLoss": 0, "homeAdvantage": 5, "doubleRoundRobin": true},
      "leagueStyle": "formation_export"
    },
    {
      "id": "taca-phoenix",
      "name": "Taça Phoenix",
      "type": "cup",
      "seasonYear": 2026,
      "participantClubIds": ["club-phoenix", "club-union", "club-riverside", "club-highland"],
      "rules": {"pointsWin": 3, "pointsDraw": 1, "pointsLoss": 0, "homeAdvantage": 5, "doubleRoundRobin": false},
      "knockoutSemiFinalDate": {"year": 2026, "month": 9, "day": 26},
      "knockoutFinalDate": {"year": 2026, "month": 10, "day": 24}
    }
  ],
  "fixtures": [],
  "standings": {}
}
''';
