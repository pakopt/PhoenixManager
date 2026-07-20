/// Configuration for Match Engine — loaded from YAML (zero magic numbers).
class MatchEngineConfig {
  const MatchEngineConfig({
    this.segmentCount = 45,
    this.minutesPerSegment = 2,
    this.momentum = const MomentumConfig(),
    this.xg = const ExpectedGoalsConfig(),
    this.highlightMinGrade = OpportunityGrade.dangerous,
  });

  factory MatchEngineConfig.fromMap(Map<String, dynamic> map) {
    return MatchEngineConfig(
      segmentCount: map['segmentCount'] as int? ?? 45,
      minutesPerSegment: map['minutesPerSegment'] as int? ?? 2,
      momentum: MomentumConfig.fromMap(
        map['momentum'] != null
            ? Map<String, dynamic>.from(map['momentum'] as Map)
            : null,
      ),
      xg: ExpectedGoalsConfig.fromMap(
        map['xg'] != null
            ? Map<String, dynamic>.from(map['xg'] as Map)
            : null,
      ),
      highlightMinGrade: OpportunityGrade.values.byName(
        map['highlightMinGrade'] as String? ?? 'dangerous',
      ),
    );
  }

  final int segmentCount;
  final int minutesPerSegment;
  final MomentumConfig momentum;
  final ExpectedGoalsConfig xg;
  final OpportunityGrade highlightMinGrade;

  int get totalMinutes => segmentCount * minutesPerSegment;

  Map<String, dynamic> toMap() => {
        'segmentCount': segmentCount,
        'minutesPerSegment': minutesPerSegment,
        'momentum': momentum.toMap(),
        'xg': xg.toMap(),
        'highlightMinGrade': highlightMinGrade.name,
      };
}

class MomentumConfig {
  const MomentumConfig({
    this.goalBoost = 15,
    this.concedePenalty = -12,
    this.bigChanceMiss = -8,
    this.decayPerSegment = 1.5,
    this.min = -50,
    this.max = 50,
  });

  factory MomentumConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const MomentumConfig();
    }
    return MomentumConfig(
      goalBoost: (map['goalBoost'] as num?)?.toDouble() ?? 15,
      concedePenalty: (map['concedePenalty'] as num?)?.toDouble() ?? -12,
      bigChanceMiss: (map['bigChanceMiss'] as num?)?.toDouble() ?? -8,
      decayPerSegment: (map['decayPerSegment'] as num?)?.toDouble() ?? 1.5,
      min: (map['min'] as num?)?.toDouble() ?? -50,
      max: (map['max'] as num?)?.toDouble() ?? 50,
    );
  }

  final double goalBoost;
  final double concedePenalty;
  final double bigChanceMiss;
  final double decayPerSegment;
  final double min;
  final double max;

  Map<String, dynamic> toMap() => {
        'goalBoost': goalBoost,
        'concedePenalty': concedePenalty,
        'bigChanceMiss': bigChanceMiss,
        'decayPerSegment': decayPerSegment,
        'min': min,
        'max': max,
      };
}

class ExpectedGoalsConfig {
  const ExpectedGoalsConfig({
    this.penalty = 0.76,
    this.headerBox = 0.62,
    this.oneOnOne = 0.45,
    this.dangerous = 0.22,
    this.moderate = 0.12,
    this.weak = 0.04,
  });

  factory ExpectedGoalsConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ExpectedGoalsConfig();
    }
    return ExpectedGoalsConfig(
      penalty: (map['penalty'] as num?)?.toDouble() ?? 0.76,
      headerBox: (map['headerBox'] as num?)?.toDouble() ?? 0.62,
      oneOnOne: (map['oneOnOne'] as num?)?.toDouble() ?? 0.45,
      dangerous: (map['dangerous'] as num?)?.toDouble() ?? 0.22,
      moderate: (map['moderate'] as num?)?.toDouble() ?? 0.12,
      weak: (map['weak'] as num?)?.toDouble() ?? 0.04,
    );
  }

  final double penalty;
  final double headerBox;
  final double oneOnOne;
  final double dangerous;
  final double moderate;
  final double weak;

  double forGrade(OpportunityGrade grade) {
    return switch (grade) {
      OpportunityGrade.certain => headerBox,
      OpportunityGrade.dangerous => dangerous,
      OpportunityGrade.moderate => moderate,
      OpportunityGrade.weak => weak,
      OpportunityGrade.penalty => penalty,
      OpportunityGrade.oneOnOne => oneOnOne,
    };
  }

  Map<String, dynamic> toMap() => {
        'penalty': penalty,
        'headerBox': headerBox,
        'oneOnOne': oneOnOne,
        'dangerous': dangerous,
        'moderate': moderate,
        'weak': weak,
      };
}

enum OpportunityGrade {
  certain,
  dangerous,
  moderate,
  weak,
  penalty,
  oneOnOne,
}

enum BallState {
  defence,
  buildUp,
  midfield,
  attack,
  box,
  shot,
}

enum AttackPhase {
  recovery,
  pass,
  progression,
  finalPass,
  shot,
  outcome,
}

enum MatchEventType {
  possession,
  pass,
  cross,
  shot,
  goal,
  save,
  corner,
  foul,
  card,
  miss,
}
