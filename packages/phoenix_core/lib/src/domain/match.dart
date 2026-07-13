import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/time/game_date.dart';

enum MatchStatus {
  scheduled,
  played,
}

/// Scheduled or played fixture.
class MatchFixture {
  const MatchFixture({
    required this.id,
    required this.competitionId,
    required this.round,
    required this.homeClubId,
    required this.awayClubId,
    required this.date,
    this.homeScore,
    this.awayScore,
    this.status = MatchStatus.scheduled,
  });

  factory MatchFixture.fromMap(Map<String, dynamic> map) {
    return MatchFixture(
      id: MatchId(map['id'] as String),
      competitionId: CompetitionId(map['competitionId'] as String),
      round: map['round'] as int,
      homeClubId: ClubId(map['homeClubId'] as String),
      awayClubId: ClubId(map['awayClubId'] as String),
      date: GameDate.fromMap(
        Map<String, dynamic>.from(map['date'] as Map),
      ),
      homeScore: map['homeScore'] as int?,
      awayScore: map['awayScore'] as int?,
      status: MatchStatus.values.byName(map['status'] as String? ?? 'scheduled'),
    );
  }

  final MatchId id;
  final CompetitionId competitionId;
  final int round;
  final ClubId homeClubId;
  final ClubId awayClubId;
  final GameDate date;
  final int? homeScore;
  final int? awayScore;
  final MatchStatus status;

  bool get isPlayed => status == MatchStatus.played;

  MatchFixture withResult({required int homeScore, required int awayScore}) {
    return MatchFixture(
      id: id,
      competitionId: competitionId,
      round: round,
      homeClubId: homeClubId,
      awayClubId: awayClubId,
      date: date,
      homeScore: homeScore,
      awayScore: awayScore,
      status: MatchStatus.played,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'competitionId': competitionId.value,
        'round': round,
        'homeClubId': homeClubId.value,
        'awayClubId': awayClubId.value,
        'date': date.toMap(),
        if (homeScore != null) 'homeScore': homeScore,
        if (awayScore != null) 'awayScore': awayScore,
        'status': status.name,
      };
}
