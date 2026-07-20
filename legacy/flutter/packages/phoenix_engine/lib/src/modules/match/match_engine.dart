import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/modules/match/match_commentary.dart';
import 'package:phoenix_engine/src/modules/match/momentum_system.dart';
import 'package:phoenix_engine/src/modules/match/segment_simulator.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// 45-segment Match Engine — xG, momentum, event-driven commentary.
class MatchEngine {
  MatchEngine({
    required WorldRegistry registry,
    required MatchEngineConfig config,
    MatchCommentaryGenerator? commentary,
    MomentumSystem? momentumSystem,
    SegmentSimulator? segmentSimulator,
  })  : _registry = registry,
        _config = config,
        _commentary = commentary ?? MatchCommentaryGenerator(),
        _segments = segmentSimulator ??
            SegmentSimulator(
              config: config,
              momentumSystem: momentumSystem ?? MomentumSystem(config: config),
            );

  final WorldRegistry _registry;
  final MatchEngineConfig _config;
  final MatchCommentaryGenerator _commentary;
  final SegmentSimulator _segments;

  MatchSimulationOutput simulate(MatchFixture fixture, {required int worldSeed}) {
    if (fixture.isPlayed) {
      final existing = _registry.matchResults[fixture.id];
      if (existing != null) {
        return MatchSimulationOutput(
          fixture: fixture,
          result: existing,
        );
      }
    }

    final stopwatch = Stopwatch()..start();

    final home = _registry.getClub(fixture.homeClubId);
    final away = _registry.getClub(fixture.awayClubId);
    if (home == null || away == null) {
      throw StateError('Club missing for fixture ${fixture.id}');
    }

    final competition = _registry.getCompetition(fixture.competitionId);
    final homeAdvantage = competition?.rules.homeAdvantage ?? 5;

    final homeStrength = _clubStrength(home) + homeAdvantage.toDouble();
    final awayStrength = _clubStrength(away);

    final matchSeed = worldSeed ^ fixture.id.value.hashCode;
    final rng = SeededRng(matchSeed);

    var homeScore = 0;
    var awayScore = 0;
    var momentum = const MomentumState();
    var homePossessionTicks = 0;
    var awayPossessionTicks = 0;
    var homeStats = const MatchTeamStats();
    var awayStats = const MatchTeamStats();
    final segments = <MatchSegment>[];
    final commentary = <String>[];
    final highlights = <String>[];

    for (var i = 0; i < _config.segmentCount; i++) {
      final outcome = _segments.simulate(
        index: i,
        rng: rng,
        homeClubId: fixture.homeClubId,
        awayClubId: fixture.awayClubId,
        homeStrength: homeStrength,
        awayStrength: awayStrength,
        momentum: momentum,
        homeScore: homeScore,
        awayScore: awayScore,
      );

      momentum = outcome.momentum;
      segments.add(outcome.segment);

      if (outcome.segment.possessionTeamId == fixture.homeClubId) {
        homePossessionTicks += 1;
      } else {
        awayPossessionTicks += 1;
      }

      if (outcome.shotTaken) {
        if (outcome.segment.possessionTeamId == fixture.homeClubId) {
          homeStats = homeStats.copyWith(
            shots: homeStats.shots + 1,
            xg: homeStats.xg + outcome.xgForAttacker,
            shotsOnTarget: outcome.shotOnTarget
                ? homeStats.shotsOnTarget + 1
                : homeStats.shotsOnTarget,
          );
        } else {
          awayStats = awayStats.copyWith(
            shots: awayStats.shots + 1,
            xg: awayStats.xg + outcome.xgForAttacker,
            shotsOnTarget: outcome.shotOnTarget
                ? awayStats.shotsOnTarget + 1
                : awayStats.shotsOnTarget,
          );
        }
      }

      if (outcome.goalScored) {
        if (outcome.isHomeGoal) {
          homeScore += 1;
        } else {
          awayScore += 1;
        }
      }

      final line = _commentary.forSegment(
        segment: outcome.segment,
        homeClubId: fixture.homeClubId,
        awayClubId: fixture.awayClubId,
        homeName: home.name,
        awayName: away.name,
        goalScored: outcome.goalScored,
      );
      commentary.add(line);
      if (outcome.segment.isHighlight) {
        highlights.add(line);
      }
    }

    final totalTicks = homePossessionTicks + awayPossessionTicks;
    homeStats = homeStats.copyWith(
      possessionPct: totalTicks == 0
          ? 50
          : ((homePossessionTicks / totalTicks) * 100).round(),
    );
    awayStats = awayStats.copyWith(
      possessionPct: totalTicks == 0
          ? 50
          : (100 - homeStats.possessionPct),
    );

    stopwatch.stop();

    final result = MatchResult(
      matchId: fixture.id,
      homeClubId: fixture.homeClubId,
      awayClubId: fixture.awayClubId,
      homeScore: homeScore,
      awayScore: awayScore,
      seed: matchSeed,
      homeStats: homeStats,
      awayStats: awayStats,
      segments: segments,
      commentary: commentary,
      highlights: highlights,
      durationMs: stopwatch.elapsedMicroseconds ~/ 1000,
    );

    final playedFixture = fixture.withResult(
      homeScore: homeScore,
      awayScore: awayScore,
    );

    return MatchSimulationOutput(fixture: playedFixture, result: result);
  }

  double _clubStrength(Club club) {
    final squadAvg = _registry.squadQuery.averageAbility(club.id);
    return club.reputation * 0.4 + squadAvg * 0.6;
  }
}
