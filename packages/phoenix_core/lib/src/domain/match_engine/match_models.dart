import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/domain/match_engine/match_config.dart';

/// Single event in a segment event chain.
class MatchEvent {
  const MatchEvent({
    required this.type,
    required this.teamId,
    required this.minute,
    this.xg,
    this.description,
  });

  factory MatchEvent.fromMap(Map<String, dynamic> map) {
    return MatchEvent(
      type: MatchEventType.values.byName(map['type'] as String),
      teamId: ClubId(map['teamId'] as String),
      minute: map['minute'] as int,
      xg: (map['xg'] as num?)?.toDouble(),
      description: map['description'] as String?,
    );
  }

  final MatchEventType type;
  final ClubId teamId;
  final int minute;
  final double? xg;
  final String? description;

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'teamId': teamId.value,
        'minute': minute,
        if (xg != null) 'xg': xg,
        if (description != null) 'description': description,
      };
}

/// One 2-minute segment of the match (45 total).
class MatchSegment {
  const MatchSegment({
    required this.index,
    required this.startMinute,
    required this.endMinute,
    required this.possessionTeamId,
    required this.ballState,
    required this.events,
    this.opportunityGrade,
    this.isHighlight = false,
  });

  factory MatchSegment.fromMap(Map<String, dynamic> map) {
    return MatchSegment(
      index: map['index'] as int,
      startMinute: map['startMinute'] as int,
      endMinute: map['endMinute'] as int,
      possessionTeamId: ClubId(map['possessionTeamId'] as String),
      ballState: BallState.values.byName(map['ballState'] as String),
      events: (map['events'] as List)
          .map((e) => MatchEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      opportunityGrade: map['opportunityGrade'] != null
          ? OpportunityGrade.values.byName(map['opportunityGrade'] as String)
          : null,
      isHighlight: map['isHighlight'] as bool? ?? false,
    );
  }

  final int index;
  final int startMinute;
  final int endMinute;
  final ClubId possessionTeamId;
  final BallState ballState;
  final List<MatchEvent> events;
  final OpportunityGrade? opportunityGrade;
  final bool isHighlight;

  Map<String, dynamic> toMap() => {
        'index': index,
        'startMinute': startMinute,
        'endMinute': endMinute,
        'possessionTeamId': possessionTeamId.value,
        'ballState': ballState.name,
        'events': events.map((e) => e.toMap()).toList(),
        if (opportunityGrade != null) 'opportunityGrade': opportunityGrade!.name,
        'isHighlight': isHighlight,
      };
}

/// Accumulated team statistics — emergent from segments.
class MatchTeamStats {
  const MatchTeamStats({
    this.possessionPct = 50,
    this.shots = 0,
    this.shotsOnTarget = 0,
    this.xg = 0,
    this.corners = 0,
    this.fouls = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory MatchTeamStats.fromMap(Map<String, dynamic> map) {
    return MatchTeamStats(
      possessionPct: map['possessionPct'] as int? ?? 50,
      shots: map['shots'] as int? ?? 0,
      shotsOnTarget: map['shotsOnTarget'] as int? ?? 0,
      xg: (map['xg'] as num?)?.toDouble() ?? 0,
      corners: map['corners'] as int? ?? 0,
      fouls: map['fouls'] as int? ?? 0,
      yellowCards: map['yellowCards'] as int? ?? 0,
      redCards: map['redCards'] as int? ?? 0,
    );
  }

  final int possessionPct;
  final int shots;
  final int shotsOnTarget;
  final double xg;
  final int corners;
  final int fouls;
  final int yellowCards;
  final int redCards;

  MatchTeamStats copyWith({
    int? possessionPct,
    int? shots,
    int? shotsOnTarget,
    double? xg,
    int? corners,
    int? fouls,
    int? yellowCards,
    int? redCards,
  }) {
    return MatchTeamStats(
      possessionPct: possessionPct ?? this.possessionPct,
      shots: shots ?? this.shots,
      shotsOnTarget: shotsOnTarget ?? this.shotsOnTarget,
      xg: xg ?? this.xg,
      corners: corners ?? this.corners,
      fouls: fouls ?? this.fouls,
      yellowCards: yellowCards ?? this.yellowCards,
      redCards: redCards ?? this.redCards,
    );
  }

  Map<String, dynamic> toMap() => {
        'possessionPct': possessionPct,
        'shots': shots,
        'shotsOnTarget': shotsOnTarget,
        'xg': xg,
        'corners': corners,
        'fouls': fouls,
        'yellowCards': yellowCards,
        'redCards': redCards,
      };
}

/// Hidden momentum state per team during simulation.
class MomentumState {
  const MomentumState({this.home = 0, this.away = 0});

  final double home;
  final double away;

  MomentumState copyWith({double? home, double? away}) {
    return MomentumState(
      home: home ?? this.home,
      away: away ?? this.away,
    );
  }

  double forTeam({required bool isHome}) => isHome ? home : away;

  MomentumState withTeam({required bool isHome, required double delta}) {
    return isHome
        ? copyWith(home: home + delta)
        : copyWith(away: away + delta);
  }
}
