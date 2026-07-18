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

  /// Built-in Liga Phoenix MVP pack (6 clubs: Phoenix FC + PT peers + rivals).
  WorldRegistry loadLigaPhoenixAlpha() {
    return loadFromJson(_ligaPhoenixAlphaJson);
  }
}

const _ligaPhoenixAlphaJson = '''
{
  "continents": [
    {"id": "eu", "name": "Europa"},
    {"id": "sa", "name": "América do Sul"},
    {"id": "af", "name": "África"}
  ],
  "countries": [
    {"id": "portugal", "name": "Portugal", "continentId": "eu", "reputation": 78},
    {"id": "phoenix-nation", "name": "Nação Phoenix", "continentId": "eu", "reputation": 62},
    {"id": "brazil", "name": "Brasil", "continentId": "sa", "reputation": 82},
    {"id": "angola", "name": "Angola", "continentId": "af", "reputation": 48}
  ],
  "regions": [
    {"id": "madeira", "name": "Madeira", "countryId": "portugal", "footballTradition": 58, "disciplineBias": 2},
    {"id": "setubal", "name": "Setúbal", "countryId": "portugal", "footballTradition": 64, "disciplineBias": 2},
    {"id": "central", "name": "Região Central", "countryId": "phoenix-nation", "footballTradition": 72, "disciplineBias": 3}
  ],
  "cities": [
    {"id": "monte-funchal", "name": "Monte, Funchal", "regionId": "madeira", "population": 7500, "economy": 52, "footballTradition": 55},
    {"id": "setubal", "name": "Setúbal", "regionId": "setubal", "population": 118000, "economy": 56, "footballTradition": 68},
    {"id": "phoenix-city", "name": "Phoenix City", "regionId": "central", "population": 420000, "economy": 68, "footballTradition": 80},
    {"id": "riverside", "name": "Riverside", "regionId": "central", "population": 180000, "economy": 55, "footballTradition": 65},
    {"id": "highland", "name": "Highland", "regionId": "central", "population": 95000, "economy": 48, "footballTradition": 58},
    {"id": "union-town", "name": "Union Town", "regionId": "central", "population": 210000, "economy": 60, "footballTradition": 70}
  ],
  "clubs": [
    {
      "id": "club-phoenix",
      "name": "Phoenix FC",
      "shortName": "Phoenix",
      "cityId": "phoenix-city",
      "reputation": 78,
      "budget": 8500000,
      "stadiumCapacity": 32000,
      "coachId": "coach-phoenix"
    },
    {
      "id": "club-coruja",
      "name": "Associação Desportiva «A Coruja»",
      "shortName": "A Coruja",
      "cityId": "monte-funchal",
      "reputation": 52,
      "budget": 650000,
      "stadiumCapacity": 1200,
      "coachId": "coach-coruja",
      "logoAsset": "assets/clubs/coruja.png",
      "foundedOn": "1976-04-09",
      "association": "AF Madeira",
      "president": "José Gomes",
      "address": "Corujeira De Fora, N.º 95, Monte, Funchal",
      "teams": [
        "Equipa Principal",
        "Jun.A S19",
        "Jun.B S17",
        "Jun.C S15",
        "Jun.D S13",
        "Veteranos",
        "Fut.7 Jun.D S12",
        "Fut.7 Jun.E S11"
      ]
    },
    {
      "id": "club-sindicato",
      "name": "Grupo Desportivo Recreativo «O Sindicato»",
      "shortName": "GDR «O Sindicato»",
      "cityId": "setubal",
      "reputation": 50,
      "budget": 580000,
      "stadiumCapacity": 1500,
      "coachId": "coach-sindicato",
      "logoAsset": "assets/clubs/sindicato.png",
      "kitAsset": "assets/clubs/sindicato-kit.png",
      "foundedOn": "1977-02-06",
      "association": "AAF Setúbal",
      "president": "João Raimundo",
      "teams": [
        "Equipa Principal",
        "Jun.A S19",
        "Jun.B S17",
        "Jun.C S15",
        "Jun.D S13",
        "Fut.7 Jun.D S13",
        "Fut.7 Jun.D S12",
        "Fut.7 Jun.E S11",
        "Fut.7 Jun.E S10",
        "Fut.7 Jun.F S9"
      ]
    },
    {"id": "club-union", "name": "Union City", "cityId": "union-town", "reputation": 71, "budget": 5200000, "stadiumCapacity": 24000, "coachId": "coach-union"},
    {"id": "club-riverside", "name": "Riverside SC", "cityId": "riverside", "reputation": 65, "budget": 3100000, "stadiumCapacity": 14000, "coachId": "coach-riverside"},
    {"id": "club-highland", "name": "Highland Athletic", "cityId": "highland", "reputation": 58, "budget": 1800000, "stadiumCapacity": 9000, "coachId": "coach-highland"}
  ],
  "coaches": [
    {"id": "coach-phoenix", "name": "Marco Silva", "clubId": "club-phoenix", "reputation": 74, "personality": "idealist", "licenseLevel": 4},
    {"id": "coach-coruja", "name": "Carlos Correia", "clubId": "club-coruja", "reputation": 48, "personality": "youthDeveloper", "licenseLevel": 2},
    {"id": "coach-sindicato", "name": "Rui Baptista", "clubId": "club-sindicato", "reputation": 46, "personality": "youthDeveloper", "licenseLevel": 2},
    {"id": "coach-union", "name": "Ana Costa", "clubId": "club-union", "reputation": 68, "personality": "pragmatist", "licenseLevel": 3},
    {"id": "coach-riverside", "name": "João Mendes", "clubId": "club-riverside", "reputation": 61, "personality": "youthDeveloper", "licenseLevel": 2},
    {"id": "coach-highland", "name": "Pedro Alves", "clubId": "club-highland", "reputation": 55, "personality": "disciplinarian", "licenseLevel": 2}
  ],
  "players": [
    {"id": "p-phx-1", "name": "Rui Costa", "clubId": "club-phoenix", "age": 27, "currentAbility": 74, "potentialAbility": 76, "morale": 78, "salary": 45000, "contractEndYear": 2028, "nationalityId": "phoenix-nation"},
    {"id": "p-phx-2", "name": "Diego Lima", "clubId": "club-phoenix", "age": 24, "currentAbility": 71, "potentialAbility": 80, "morale": 75, "salary": 38000, "contractEndYear": 2029, "nationalityId": "phoenix-nation"},
    {"id": "p-phx-3", "name": "Tomás Ferreira", "clubId": "club-phoenix", "age": 31, "currentAbility": 72, "potentialAbility": 72, "morale": 70, "salary": 42000, "contractEndYear": 2027, "nationalityId": "phoenix-nation"},
    {"id": "p-cor-1", "name": "Fábio Andrade", "clubId": "club-coruja", "age": 28, "currentAbility": 58, "potentialAbility": 60, "morale": 72, "salary": 8000, "contractEndYear": 2027, "nationalityId": "portugal"},
    {"id": "p-cor-2", "name": "Ricardo Gouveia", "clubId": "club-coruja", "age": 23, "currentAbility": 55, "potentialAbility": 68, "morale": 78, "salary": 5500, "contractEndYear": 2029, "nationalityId": "portugal"},
    {"id": "p-cor-3", "name": "Paulo Freitas", "clubId": "club-coruja", "age": 34, "currentAbility": 54, "potentialAbility": 54, "morale": 65, "salary": 6000, "contractEndYear": 2026, "nationalityId": "portugal"},
    {"id": "p-sin-jb-01", "name": "Diogo Correia", "clubId": "club-sindicato", "age": 31, "currentAbility": 56, "potentialAbility": 56, "morale": 78, "form": 68, "salary": 4500, "contractEndYear": 2027, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-02", "name": "Vítor Fraga", "clubId": "club-sindicato", "age": 16, "currentAbility": 60, "potentialAbility": 74, "morale": 84, "form": 78, "salary": 2400, "contractEndYear": 2029, "nationalityId": "brazil", "position": "PL"},
    {"id": "p-sin-jb-03", "name": "Melquisedeque", "clubId": "club-sindicato", "age": 17, "currentAbility": 50, "potentialAbility": 56, "morale": 76, "form": 62, "salary": 1100, "contractEndYear": 2028, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-04", "name": "João Raimundo", "clubId": "club-sindicato", "age": 34, "currentAbility": 60, "potentialAbility": 60, "morale": 80, "form": 74, "salary": 4500, "contractEndYear": 2027, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-05", "name": "Tomás Casado", "clubId": "club-sindicato", "age": 15, "currentAbility": 59, "potentialAbility": 71, "morale": 82, "form": 72, "salary": 1700, "contractEndYear": 2029, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-06", "name": "Gabriel Correia", "clubId": "club-sindicato", "age": 16, "currentAbility": 56, "potentialAbility": 65, "morale": 78, "form": 66, "salary": 1450, "contractEndYear": 2029, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-07", "name": "Maiembe Paulo", "clubId": "club-sindicato", "age": 15, "currentAbility": 56, "potentialAbility": 66, "morale": 78, "form": 66, "salary": 1450, "contractEndYear": 2029, "nationalityId": "angola", "position": "DF"},
    {"id": "p-sin-jb-08", "name": "Vasco Felicio", "clubId": "club-sindicato", "age": 16, "currentAbility": 50, "potentialAbility": 57, "morale": 74, "form": 58, "salary": 1050, "contractEndYear": 2028, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-09", "name": "Samuel Reinholz", "clubId": "club-sindicato", "age": 17, "currentAbility": 53, "potentialAbility": 60, "morale": 76, "form": 62, "salary": 1250, "contractEndYear": 2028, "nationalityId": "brazil", "position": "MD"},
    {"id": "p-sin-jb-10", "name": "Pedro Souza", "clubId": "club-sindicato", "age": 17, "currentAbility": 51, "potentialAbility": 58, "morale": 74, "form": 60, "salary": 1100, "contractEndYear": 2028, "nationalityId": "brazil", "position": "MD"},
    {"id": "p-sin-jb-11", "name": "Martim Prazeres", "clubId": "club-sindicato", "age": 15, "currentAbility": 48, "potentialAbility": 56, "morale": 72, "form": 55, "salary": 900, "contractEndYear": 2029, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-12", "name": "Martim Salvado", "clubId": "club-sindicato", "age": 15, "currentAbility": 47, "potentialAbility": 55, "morale": 70, "form": 54, "salary": 820, "contractEndYear": 2029, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-13", "name": "Martim Santos", "clubId": "club-sindicato", "age": 16, "currentAbility": 47, "potentialAbility": 54, "morale": 70, "form": 54, "salary": 820, "contractEndYear": 2028, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-14", "name": "Francisco Sousa", "clubId": "club-sindicato", "age": 15, "currentAbility": 47, "potentialAbility": 55, "morale": 70, "form": 54, "salary": 820, "contractEndYear": 2029, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-15", "name": "Carlos Valido", "clubId": "club-sindicato", "age": 15, "currentAbility": 49, "potentialAbility": 58, "morale": 72, "form": 58, "salary": 950, "contractEndYear": 2029, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-16", "name": "João Gonçalves", "clubId": "club-sindicato", "age": 15, "currentAbility": 46, "potentialAbility": 54, "morale": 70, "form": 52, "salary": 780, "contractEndYear": 2029, "nationalityId": "brazil", "position": "MD"},
    {"id": "p-sin-jb-17", "name": "Matheus Astenreiter", "clubId": "club-sindicato", "age": 15, "currentAbility": 48, "potentialAbility": 57, "morale": 72, "form": 58, "salary": 910, "contractEndYear": 2029, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-18", "name": "Ruben Damaso", "clubId": "club-sindicato", "age": 17, "currentAbility": 46, "potentialAbility": 52, "morale": 68, "form": 52, "salary": 750, "contractEndYear": 2028, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-19", "name": "Tiago Pedro", "clubId": "club-sindicato", "age": 15, "currentAbility": 46, "potentialAbility": 54, "morale": 72, "form": 56, "salary": 750, "contractEndYear": 2029, "nationalityId": "portugal", "position": "GR"},
    {"id": "p-sin-jb-20", "name": "Leandro Caleira", "clubId": "club-sindicato", "age": 16, "currentAbility": 52, "potentialAbility": 61, "morale": 76, "form": 64, "salary": 1150, "contractEndYear": 2028, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-21", "name": "Bruno Abreu", "clubId": "club-sindicato", "age": 17, "currentAbility": 46, "potentialAbility": 52, "morale": 70, "form": 54, "salary": 720, "contractEndYear": 2028, "nationalityId": "portugal", "position": "GR"},
    {"id": "p-sin-jb-22", "name": "Jesus Aguilera", "clubId": "club-sindicato", "age": 16, "currentAbility": 45, "potentialAbility": 52, "morale": 68, "form": 50, "salary": 680, "contractEndYear": 2028, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-23", "name": "Diego Chagas", "clubId": "club-sindicato", "age": 15, "currentAbility": 45, "potentialAbility": 53, "morale": 68, "form": 50, "salary": 680, "contractEndYear": 2029, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-24", "name": "João Gonçalves", "clubId": "club-sindicato", "age": 15, "currentAbility": 44, "potentialAbility": 52, "morale": 66, "form": 48, "salary": 610, "contractEndYear": 2029, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-25", "name": "Leopoldino Neto", "clubId": "club-sindicato", "age": 16, "currentAbility": 44, "potentialAbility": 51, "morale": 66, "form": 48, "salary": 580, "contractEndYear": 2028, "nationalityId": "portugal", "position": "MD"},
    {"id": "p-sin-jb-26", "name": "Domingos Chimonze", "clubId": "club-sindicato", "age": 15, "currentAbility": 44, "potentialAbility": 52, "morale": 68, "form": 50, "salary": 580, "contractEndYear": 2029, "nationalityId": "angola", "position": "GR"},
    {"id": "p-sin-jb-27", "name": "Claudio Rodrigues", "clubId": "club-sindicato", "age": 17, "currentAbility": 44, "potentialAbility": 50, "morale": 64, "form": 46, "salary": 540, "contractEndYear": 2028, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-28", "name": "Martim Ascenção", "clubId": "club-sindicato", "age": 16, "currentAbility": 44, "potentialAbility": 51, "morale": 68, "form": 52, "salary": 590, "contractEndYear": 2028, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-29", "name": "Hugo Fernandes", "clubId": "club-sindicato", "age": 16, "currentAbility": 43, "potentialAbility": 50, "morale": 64, "form": 46, "salary": 500, "contractEndYear": 2028, "nationalityId": "portugal", "position": "PL"},
    {"id": "p-sin-jb-30", "name": "Lech Neto", "clubId": "club-sindicato", "age": 15, "currentAbility": 47, "potentialAbility": 56, "morale": 74, "form": 62, "salary": 750, "contractEndYear": 2029, "nationalityId": "angola", "position": "PL"},
    {"id": "p-sin-jb-31", "name": "Matheus Lobo", "clubId": "club-sindicato", "age": 14, "currentAbility": 43, "potentialAbility": 52, "morale": 66, "form": 48, "salary": 500, "contractEndYear": 2030, "nationalityId": "brazil", "position": "MD"},
    {"id": "p-sin-jb-32", "name": "Leonardo Ricardo", "clubId": "club-sindicato", "age": 15, "currentAbility": 43, "potentialAbility": 51, "morale": 64, "form": 46, "salary": 470, "contractEndYear": 2029, "nationalityId": "angola", "position": "DF"},
    {"id": "p-sin-jb-33", "name": "Afonso Rosa", "clubId": "club-sindicato", "age": 16, "currentAbility": 43, "potentialAbility": 50, "morale": 64, "form": 46, "salary": 470, "contractEndYear": 2028, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-34", "name": "Danilo Silva", "clubId": "club-sindicato", "age": 14, "currentAbility": 43, "potentialAbility": 52, "morale": 64, "form": 46, "salary": 470, "contractEndYear": 2030, "nationalityId": "brazil", "position": "MD"},
    {"id": "p-sin-jb-35", "name": "Martim Silva", "clubId": "club-sindicato", "age": 16, "currentAbility": 42, "potentialAbility": 49, "morale": 62, "form": 44, "salary": 430, "contractEndYear": 2028, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-36", "name": "Tomás Vaz", "clubId": "club-sindicato", "age": 14, "currentAbility": 42, "potentialAbility": 51, "morale": 62, "form": 44, "salary": 430, "contractEndYear": 2030, "nationalityId": "portugal", "position": "DF"},
    {"id": "p-sin-jb-37", "name": "Aryclane Lello", "clubId": "club-sindicato", "age": 15, "currentAbility": 42, "potentialAbility": 50, "morale": 62, "form": 44, "salary": 430, "contractEndYear": 2029, "nationalityId": "angola", "position": "PL"},
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
      "participantClubIds": ["club-phoenix", "club-coruja", "club-sindicato", "club-union", "club-riverside", "club-highland"],
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
