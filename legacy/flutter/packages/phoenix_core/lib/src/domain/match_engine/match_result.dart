import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/domain/match.dart';
import 'package:phoenix_core/src/domain/match_engine/match_models.dart';

/// Full match output — segments, stats, commentary, replay seed.
class MatchResult {
  const MatchResult({
    required this.matchId,
    required this.homeClubId,
    required this.awayClubId,
    required this.homeScore,
    required this.awayScore,
    required this.seed,
    required this.homeStats,
    required this.awayStats,
    required this.segments,
    required this.commentary,
    required this.highlights,
    required this.durationMs,
  });

  factory MatchResult.fromMap(Map<String, dynamic> map) {
    return MatchResult(
      matchId: MatchId(map['matchId'] as String),
      homeClubId: ClubId(map['homeClubId'] as String),
      awayClubId: ClubId(map['awayClubId'] as String),
      homeScore: map['homeScore'] as int,
      awayScore: map['awayScore'] as int,
      seed: map['seed'] as int,
      homeStats: MatchTeamStats.fromMap(
        Map<String, dynamic>.from(map['homeStats'] as Map),
      ),
      awayStats: MatchTeamStats.fromMap(
        Map<String, dynamic>.from(map['awayStats'] as Map),
      ),
      segments: (map['segments'] as List)
          .map((s) => MatchSegment.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList(),
      commentary: (map['commentary'] as List).cast<String>(),
      highlights: (map['highlights'] as List).cast<String>(),
      durationMs: map['durationMs'] as int? ?? 0,
    );
  }

  final MatchId matchId;
  final ClubId homeClubId;
  final ClubId awayClubId;
  final int homeScore;
  final int awayScore;
  final int seed;
  final MatchTeamStats homeStats;
  final MatchTeamStats awayStats;
  final List<MatchSegment> segments;
  final List<String> commentary;
  final List<String> highlights;
  final int durationMs;

  Map<String, dynamic> toMap() => {
        'matchId': matchId.value,
        'homeClubId': homeClubId.value,
        'awayClubId': awayClubId.value,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'seed': seed,
        'homeStats': homeStats.toMap(),
        'awayStats': awayStats.toMap(),
        'segments': segments.map((s) => s.toMap()).toList(),
        'commentary': commentary,
        'highlights': highlights,
        'durationMs': durationMs,
      };
}

/// Output bundle from [MatchEngine.simulate].
class MatchSimulationOutput {
  const MatchSimulationOutput({
    required this.fixture,
    required this.result,
  });

  final MatchFixture fixture;
  final MatchResult result;
}
