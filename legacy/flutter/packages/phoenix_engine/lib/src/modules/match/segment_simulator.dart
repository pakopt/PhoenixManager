import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/modules/match/momentum_system.dart';

/// Simulates a single 2-minute match segment.
class SegmentSimulator {
  SegmentSimulator({
    required MatchEngineConfig config,
    required MomentumSystem momentumSystem,
  })  : _config = config,
        _momentum = momentumSystem;

  final MatchEngineConfig _config;
  final MomentumSystem _momentum;

  SegmentOutcome simulate({
    required int index,
    required SeededRng rng,
    required ClubId homeClubId,
    required ClubId awayClubId,
    required double homeStrength,
    required double awayStrength,
    required MomentumState momentum,
    required int homeScore,
    required int awayScore,
  }) {
    final startMinute = index * _config.minutesPerSegment;
    final endMinute = startMinute + _config.minutesPerSegment;

    final homeInitiative = homeStrength +
        _momentum.initiativeBonus(momentum, isHome: true);
    final awayInitiative = awayStrength +
        _momentum.initiativeBonus(momentum, isHome: false);
    final total = homeInitiative + awayInitiative;
    final homePossessionRoll = rng.nextDouble() * total;
    final possessionIsHome = homePossessionRoll < homeInitiative;
    final attackingTeam = possessionIsHome ? homeClubId : awayClubId;
    final defendingTeam = possessionIsHome ? awayClubId : homeClubId;
    final attackStrength = possessionIsHome ? homeStrength : awayStrength;
    final defendStrength = possessionIsHome ? awayStrength : homeStrength;

    var events = <MatchEvent>[];
    var ballState = BallState.midfield;
    OpportunityGrade? grade;
    var goalScored = false;
    var isHomeGoal = false;
    var updatedMomentum = _momentum.decay(momentum);

    // Chance creation roll — higher attack vs defence = more likely
    final chanceRoll = rng.nextDouble();
    final chanceThreshold = 0.55 - (attackStrength - defendStrength) / 200;

    if (chanceRoll > chanceThreshold.clamp(0.25, 0.85)) {
      ballState = BallState.attack;
      events = _buildEventChain(
        rng: rng,
        attackingTeam: attackingTeam,
        minute: endMinute,
        attackStrength: attackStrength,
        defendStrength: defendStrength,
      );

      grade = _pickGrade(rng, attackStrength, defendStrength);
      final xg = _config.xg.forGrade(grade);
      events.last = MatchEvent(
        type: MatchEventType.shot,
        teamId: attackingTeam,
        minute: endMinute,
        xg: xg,
      );

      final goalRoll = rng.nextDouble();
      if (goalRoll < xg) {
        goalScored = true;
        isHomeGoal = possessionIsHome;
        events.add(
          MatchEvent(
            type: MatchEventType.goal,
            teamId: attackingTeam,
            minute: endMinute,
            xg: xg,
            description: 'goal',
          ),
        );
        updatedMomentum = _momentum.onGoal(updatedMomentum, scorerIsHome: isHomeGoal);
      } else if (xg >= _config.xg.dangerous) {
        events.add(
          MatchEvent(
            type: MatchEventType.save,
            teamId: defendingTeam,
            minute: endMinute,
          ),
        );
        updatedMomentum = _momentum.onBigChanceMiss(
          updatedMomentum,
          isHome: possessionIsHome,
        );
      } else {
        events.add(
          MatchEvent(
            type: MatchEventType.miss,
            teamId: attackingTeam,
            minute: endMinute,
            xg: xg,
          ),
        );
      }
    } else {
      events = [
        MatchEvent(
          type: MatchEventType.possession,
          teamId: attackingTeam,
          minute: endMinute,
        ),
      ];
    }

    final isHighlight = grade != null &&
        _gradeRank(grade) >= _gradeRank(_config.highlightMinGrade);

    final segment = MatchSegment(
      index: index,
      startMinute: startMinute,
      endMinute: endMinute,
      possessionTeamId: attackingTeam,
      ballState: ballState,
      events: events,
      opportunityGrade: grade,
      isHighlight: isHighlight || goalScored,
    );

    return SegmentOutcome(
      segment: segment,
      momentum: updatedMomentum,
      goalScored: goalScored,
      isHomeGoal: isHomeGoal,
      xgForAttacker: grade != null ? _config.xg.forGrade(grade) : 0,
      shotTaken: grade != null,
      shotOnTarget: goalScored ||
          (grade != null && _config.xg.forGrade(grade) >= _config.xg.moderate),
    );
  }

  List<MatchEvent> _buildEventChain({
    required SeededRng rng,
    required ClubId attackingTeam,
    required int minute,
    required double attackStrength,
    required double defendStrength,
  }) {
    final chainLength = 2 + rng.nextInt(3);
    final types = [
      MatchEventType.pass,
      MatchEventType.pass,
      MatchEventType.cross,
      MatchEventType.pass,
    ];
    return List.generate(chainLength, (i) {
      return MatchEvent(
        type: types[i % types.length],
        teamId: attackingTeam,
        minute: minute - (chainLength - i),
      );
    });
  }

  OpportunityGrade _pickGrade(
    SeededRng rng,
    double attack,
    double defend,
  ) {
    final roll = rng.nextDouble() + (attack - defend) / 300;
    if (roll > 0.92) {
      return OpportunityGrade.oneOnOne;
    }
    if (roll > 0.82) {
      return OpportunityGrade.certain;
    }
    if (roll > 0.65) {
      return OpportunityGrade.dangerous;
    }
    if (roll > 0.45) {
      return OpportunityGrade.moderate;
    }
    return OpportunityGrade.weak;
  }

  int _gradeRank(OpportunityGrade grade) {
    return switch (grade) {
      OpportunityGrade.weak => 1,
      OpportunityGrade.moderate => 2,
      OpportunityGrade.dangerous => 3,
      OpportunityGrade.certain => 4,
      OpportunityGrade.oneOnOne => 5,
      OpportunityGrade.penalty => 5,
    };
  }
}

class SegmentOutcome {
  const SegmentOutcome({
    required this.segment,
    required this.momentum,
    required this.goalScored,
    required this.isHomeGoal,
    required this.xgForAttacker,
    required this.shotTaken,
    required this.shotOnTarget,
  });

  final MatchSegment segment;
  final MomentumState momentum;
  final bool goalScored;
  final bool isHomeGoal;
  final double xgForAttacker;
  final bool shotTaken;
  final bool shotOnTarget;
}
