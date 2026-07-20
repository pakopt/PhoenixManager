import 'package:phoenix_core/src/time/game_date.dart';

class AchievementId {
  const AchievementId(this.value);

  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementId && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
  });

  final AchievementId id;
  final String title;
  final String description;
}

class UnlockedAchievement {
  const UnlockedAchievement({
    required this.id,
    required this.unlockedOn,
    required this.seasonYear,
  });

  factory UnlockedAchievement.fromMap(Map<String, dynamic> map) {
    return UnlockedAchievement(
      id: AchievementId(map['id'] as String),
      unlockedOn: GameDate.fromMap(
        Map<String, dynamic>.from(map['unlockedOn'] as Map),
      ),
      seasonYear: map['seasonYear'] as int,
    );
  }

  final AchievementId id;
  final GameDate unlockedOn;
  final int seasonYear;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'unlockedOn': unlockedOn.toMap(),
        'seasonYear': seasonYear,
      };
}

/// Static catalog — UI reads labels from here; engine uses ids only.
abstract final class AchievementCatalog {
  static const firstWin = AchievementId('first_win');
  static const leagueChampion = AchievementId('league_champion');
  static const cupChampion = AchievementId('cup_champion');
  static const doubleWinner = AchievementId('double_winner');
  static const contractRenewed = AchievementId('contract_renewed');
  static const transferDeal = AchievementId('transfer_deal');
  static const youthIntake = AchievementId('youth_intake');
  static const wonderkid = AchievementId('wonderkid');
  static const seasonComplete = AchievementId('season_complete');
  static const careerContinues = AchievementId('career_continues');

  static const all = [
    AchievementDefinition(
      id: firstWin,
      title: 'Primeira vitória',
      description: 'Ganha o teu primeiro jogo oficial.',
    ),
    AchievementDefinition(
      id: leagueChampion,
      title: 'Campeão da Liga',
      description: 'Termina a Liga Phoenix em 1.º lugar.',
    ),
    AchievementDefinition(
      id: cupChampion,
      title: 'Campeão da Taça',
      description: 'Vence a Taça Phoenix.',
    ),
    AchievementDefinition(
      id: doubleWinner,
      title: 'Dobradinha',
      description: 'Vence liga e taça na mesma época.',
    ),
    AchievementDefinition(
      id: contractRenewed,
      title: 'Renovação',
      description: 'Renova o contrato de um jogador.',
    ),
    AchievementDefinition(
      id: transferDeal,
      title: 'Negócio fechado',
      description: 'Completa uma transferência envolvendo o clube.',
    ),
    AchievementDefinition(
      id: youthIntake,
      title: 'Nova geração',
      description: 'Recebe jovens da academia no fim de época.',
    ),
    AchievementDefinition(
      id: wonderkid,
      title: 'Wonderkid',
      description: 'Integra um jovem com margem de evolução ≥15.',
    ),
    AchievementDefinition(
      id: seasonComplete,
      title: 'Época completa',
      description: 'Termina liga e taça na mesma temporada.',
    ),
    AchievementDefinition(
      id: careerContinues,
      title: 'Nova temporada',
      description: 'Inicia uma segunda época de carreira.',
    ),
  ];

  static AchievementDefinition? find(AchievementId id) {
    for (final def in all) {
      if (def.id == id) {
        return def;
      }
    }
    return null;
  }
}
