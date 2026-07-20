import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/time/game_date.dart';

enum CompetitionType {
  league,
  cup,
}

/// Competition-agnostic rules — motor não conhece ligas específicas.
class CompetitionRules {
  const CompetitionRules({
    this.pointsWin = 3,
    this.pointsDraw = 1,
    this.pointsLoss = 0,
    this.homeAdvantage = 5,
    this.doubleRoundRobin = true,
  });

  factory CompetitionRules.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const CompetitionRules();
    }
    return CompetitionRules(
      pointsWin: map['pointsWin'] as int? ?? 3,
      pointsDraw: map['pointsDraw'] as int? ?? 1,
      pointsLoss: map['pointsLoss'] as int? ?? 0,
      homeAdvantage: map['homeAdvantage'] as int? ?? 5,
      doubleRoundRobin: map['doubleRoundRobin'] as bool? ?? true,
    );
  }

  final int pointsWin;
  final int pointsDraw;
  final int pointsLoss;
  final int homeAdvantage;
  final bool doubleRoundRobin;

  Map<String, dynamic> toMap() => {
        'pointsWin': pointsWin,
        'pointsDraw': pointsDraw,
        'pointsLoss': pointsLoss,
        'homeAdvantage': homeAdvantage,
        'doubleRoundRobin': doubleRoundRobin,
      };
}

class Competition {
  const Competition({
    required this.id,
    required this.name,
    required this.type,
    required this.seasonYear,
    required this.participantClubIds,
    required this.rules,
    this.leagueStyle,
    this.knockoutSemiFinalDate,
    this.knockoutFinalDate,
  });

  factory Competition.fromMap(Map<String, dynamic> map) {
    return Competition(
      id: CompetitionId(map['id'] as String),
      name: map['name'] as String,
      type: CompetitionType.values.byName(map['type'] as String),
      seasonYear: map['seasonYear'] as int,
      participantClubIds: (map['participantClubIds'] as List)
          .map((id) => ClubId(id as String))
          .toList(),
      rules: CompetitionRules.fromMap(
        map['rules'] != null
            ? Map<String, dynamic>.from(map['rules'] as Map)
            : null,
      ),
      leagueStyle: map['leagueStyle'] as String?,
      knockoutSemiFinalDate: map['knockoutSemiFinalDate'] != null
          ? GameDate.fromMap(
              Map<String, dynamic>.from(map['knockoutSemiFinalDate'] as Map),
            )
          : null,
      knockoutFinalDate: map['knockoutFinalDate'] != null
          ? GameDate.fromMap(
              Map<String, dynamic>.from(map['knockoutFinalDate'] as Map),
            )
          : null,
    );
  }

  final CompetitionId id;
  final String name;
  final CompetitionType type;
  final int seasonYear;
  final List<ClubId> participantClubIds;
  final CompetitionRules rules;
  final String? leagueStyle;
  final GameDate? knockoutSemiFinalDate;
  final GameDate? knockoutFinalDate;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'type': type.name,
        'seasonYear': seasonYear,
        'participantClubIds':
            participantClubIds.map((id) => id.value).toList(),
        'rules': rules.toMap(),
        if (leagueStyle != null) 'leagueStyle': leagueStyle,
        if (knockoutSemiFinalDate != null)
          'knockoutSemiFinalDate': knockoutSemiFinalDate!.toMap(),
        if (knockoutFinalDate != null)
          'knockoutFinalDate': knockoutFinalDate!.toMap(),
      };

  Competition copyWith({
    int? seasonYear,
    GameDate? knockoutSemiFinalDate,
    GameDate? knockoutFinalDate,
  }) {
    return Competition(
      id: id,
      name: name,
      type: type,
      seasonYear: seasonYear ?? this.seasonYear,
      participantClubIds: participantClubIds,
      rules: rules,
      leagueStyle: leagueStyle,
      knockoutSemiFinalDate:
          knockoutSemiFinalDate ?? this.knockoutSemiFinalDate,
      knockoutFinalDate: knockoutFinalDate ?? this.knockoutFinalDate,
    );
  }
}

class StandingEntry {
  const StandingEntry({
    required this.clubId,
    this.played = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  factory StandingEntry.fromMap(Map<String, dynamic> map) {
    return StandingEntry(
      clubId: ClubId(map['clubId'] as String),
      played: map['played'] as int? ?? 0,
      won: map['won'] as int? ?? 0,
      drawn: map['drawn'] as int? ?? 0,
      lost: map['lost'] as int? ?? 0,
      goalsFor: map['goalsFor'] as int? ?? 0,
      goalsAgainst: map['goalsAgainst'] as int? ?? 0,
      points: map['points'] as int? ?? 0,
    );
  }

  final ClubId clubId;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;

  int get goalDifference => goalsFor - goalsAgainst;

  StandingEntry applyResult({
    required int scored,
    required int conceded,
    required int pointsEarned,
    required bool won,
    required bool drawn,
  }) {
    return StandingEntry(
      clubId: clubId,
      played: played + 1,
      won: won ? this.won + 1 : this.won,
      drawn: drawn ? this.drawn + 1 : this.drawn,
      lost: (!won && !drawn) ? this.lost + 1 : this.lost,
      goalsFor: goalsFor + scored,
      goalsAgainst: goalsAgainst + conceded,
      points: points + pointsEarned,
    );
  }

  Map<String, dynamic> toMap() => {
        'clubId': clubId.value,
        'played': played,
        'won': won,
        'drawn': drawn,
        'lost': lost,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
        'points': points,
      };
}
