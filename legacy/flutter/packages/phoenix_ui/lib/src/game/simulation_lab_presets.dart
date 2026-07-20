/// Match and economy YAML presets for Simulation Lab balance runs.
library;

enum SimulationLabMatchPreset {
  defaultPreset('Padrão', 'xG equilibrado (produção)'),
  highScoring('Alto xG', 'Mais remates convertidos'),
  lowScoring('Baixo xG', 'Menos remates convertidos');

  const SimulationLabMatchPreset(this.label, this.description);
  final String label;
  final String description;

  String get yaml => switch (this) {
        SimulationLabMatchPreset.defaultPreset => _defaultMatchYaml,
        SimulationLabMatchPreset.highScoring => _highScoringMatchYaml,
        SimulationLabMatchPreset.lowScoring => _lowScoringMatchYaml,
      };
}

enum SimulationLabEconomyPreset {
  defaultPreset('Padrão', 'Economia de produção'),
  generous('Generosa', 'Mais receita e transferências'),
  tight('Apertada', 'Menos receita e mercado activo');

  const SimulationLabEconomyPreset(this.label, this.description);
  final String label;
  final String description;

  String get yaml => switch (this) {
        SimulationLabEconomyPreset.defaultPreset => _defaultEconomyYaml,
        SimulationLabEconomyPreset.generous => _generousEconomyYaml,
        SimulationLabEconomyPreset.tight => _tightEconomyYaml,
      };
}

const _defaultMatchYaml = '''
segmentCount: 45
minutesPerSegment: 2
highlightMinGrade: dangerous
momentum:
  goalBoost: 15
  concedePenalty: -12
  bigChanceMiss: -8
  decayPerSegment: 1.5
  min: -50
  max: 50
xg:
  penalty: 0.76
  headerBox: 0.62
  oneOnOne: 0.45
  dangerous: 0.22
  moderate: 0.12
  weak: 0.04
''';

const _highScoringMatchYaml = '''
segmentCount: 45
minutesPerSegment: 2
highlightMinGrade: dangerous
momentum:
  goalBoost: 18
  concedePenalty: -10
  bigChanceMiss: -6
  decayPerSegment: 1.5
  min: -50
  max: 50
xg:
  penalty: 0.84
  headerBox: 0.70
  oneOnOne: 0.55
  dangerous: 0.30
  moderate: 0.16
  weak: 0.06
''';

const _lowScoringMatchYaml = '''
segmentCount: 45
minutesPerSegment: 2
highlightMinGrade: dangerous
momentum:
  goalBoost: 12
  concedePenalty: -14
  bigChanceMiss: -10
  decayPerSegment: 1.5
  min: -50
  max: 50
xg:
  penalty: 0.68
  headerBox: 0.52
  oneOnOne: 0.35
  dangerous: 0.15
  moderate: 0.08
  weak: 0.02
''';

const _defaultEconomyYaml = '''
finance:
  salaryPaymentDay: 1
  ticketPricePerSeat: 25
  attendanceRate: 0.72
  dailySponsorIncome: 1500
  ffpWageRatioLimit: 0.65
transfer:
  windowMonths: [1, 7, 8]
  minBudgetToBuy: 500000
  feeAcceptRatio: 0.85
  maxTransfersPerClubPerWindow: 2
training:
  dailyCaGainMax: 1
  dailyCaGainChance: 0.15
  maxAgeForGrowth: 28
  matchWinMoraleBoost: 3
  matchLossMoralePenalty: 2
  matchFormWinBoost: 5
  matchFormLossPenalty: 4
youth:
  baseIntakePerClub: 2
  minAge: 16
  maxAge: 18
  baseCa: 35
  caVariance: 12
  basePa: 55
  paVariance: 25
  traditionPaBonus: 0.3
injury:
  matchInjuryChance: 0.035
  minDaysOut: 3
  maxDaysOut: 21
  maxInjuredPerClubPerMatch: 1
staff:
  trainingBonusPerLevel: 0.0008
  injuryDaysReductionPerLevel: 0.04
  maxInjuryDaysReduction: 5
  youthPaBonusPerLevel: 0.05
  coachWagePerReputation: 500
  moraleBoostPerLevel: 0.02
  maxMoraleDailyBoost: 2
  injuryChanceReductionPerLevel: 0.0003
  maxInjuryChanceReduction: 0.015
contract:
  defaultExtensionYears: 2
  minExtensionYears: 1
  maxExtensionYears: 4
  salaryIncreaseRatio: 0.10
  moraleBoostOnRenewal: 5
''';

const _generousEconomyYaml = '''
finance:
  salaryPaymentDay: 1
  ticketPricePerSeat: 32
  attendanceRate: 0.85
  dailySponsorIncome: 2500
  ffpWageRatioLimit: 0.75
transfer:
  windowMonths: [1, 6, 7, 8]
  minBudgetToBuy: 250000
  feeAcceptRatio: 0.92
  maxTransfersPerClubPerWindow: 4
training:
  dailyCaGainMax: 1
  dailyCaGainChance: 0.20
  maxAgeForGrowth: 28
  matchWinMoraleBoost: 4
  matchLossMoralePenalty: 2
  matchFormWinBoost: 6
  matchFormLossPenalty: 3
youth:
  baseIntakePerClub: 3
  minAge: 16
  maxAge: 18
  baseCa: 38
  caVariance: 14
  basePa: 58
  paVariance: 28
  traditionPaBonus: 0.35
injury:
  matchInjuryChance: 0.025
  minDaysOut: 2
  maxDaysOut: 18
  maxInjuredPerClubPerMatch: 1
staff:
  trainingBonusPerLevel: 0.001
  injuryDaysReductionPerLevel: 0.05
  maxInjuryDaysReduction: 6
  youthPaBonusPerLevel: 0.06
  coachWagePerReputation: 500
  moraleBoostPerLevel: 0.025
  maxMoraleDailyBoost: 3
  injuryChanceReductionPerLevel: 0.0004
  maxInjuryChanceReduction: 0.02
contract:
  defaultExtensionYears: 2
  minExtensionYears: 1
  maxExtensionYears: 4
  salaryIncreaseRatio: 0.08
  moraleBoostOnRenewal: 6
''';

const _tightEconomyYaml = '''
finance:
  salaryPaymentDay: 1
  ticketPricePerSeat: 18
  attendanceRate: 0.55
  dailySponsorIncome: 900
  ffpWageRatioLimit: 0.55
transfer:
  windowMonths: [7, 8]
  minBudgetToBuy: 1000000
  feeAcceptRatio: 0.75
  maxTransfersPerClubPerWindow: 1
training:
  dailyCaGainMax: 1
  dailyCaGainChance: 0.10
  maxAgeForGrowth: 26
  matchWinMoraleBoost: 2
  matchLossMoralePenalty: 3
  matchFormWinBoost: 4
  matchFormLossPenalty: 5
youth:
  baseIntakePerClub: 1
  minAge: 16
  maxAge: 18
  baseCa: 32
  caVariance: 10
  basePa: 50
  paVariance: 20
  traditionPaBonus: 0.2
injury:
  matchInjuryChance: 0.045
  minDaysOut: 4
  maxDaysOut: 28
  maxInjuredPerClubPerMatch: 2
staff:
  trainingBonusPerLevel: 0.0006
  injuryDaysReductionPerLevel: 0.03
  maxInjuryDaysReduction: 4
  youthPaBonusPerLevel: 0.04
  coachWagePerReputation: 550
  moraleBoostPerLevel: 0.015
  maxMoraleDailyBoost: 1
  injuryChanceReductionPerLevel: 0.0002
  maxInjuryChanceReduction: 0.01
contract:
  defaultExtensionYears: 2
  minExtensionYears: 1
  maxExtensionYears: 3
  salaryIncreaseRatio: 0.12
  moraleBoostOnRenewal: 4
''';
