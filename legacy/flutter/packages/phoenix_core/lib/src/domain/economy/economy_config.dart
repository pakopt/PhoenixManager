/// Economy configuration — finance, transfer, training, youth (YAML-driven).
class EconomyConfig {
  const EconomyConfig({
    this.finance = const FinanceConfig(),
    this.transfer = const TransferConfig(),
    this.training = const TrainingConfig(),
    this.youth = const YouthConfig(),
    this.injury = const InjuryConfig(),
    this.staff = const StaffConfig(),
    this.contract = const ContractConfig(),
  });

  factory EconomyConfig.fromMap(Map<String, dynamic> map) {
    return EconomyConfig(
      finance: FinanceConfig.fromMap(
        map['finance'] != null
            ? Map<String, dynamic>.from(map['finance'] as Map)
            : null,
      ),
      transfer: TransferConfig.fromMap(
        map['transfer'] != null
            ? Map<String, dynamic>.from(map['transfer'] as Map)
            : null,
      ),
      training: TrainingConfig.fromMap(
        map['training'] != null
            ? Map<String, dynamic>.from(map['training'] as Map)
            : null,
      ),
      youth: YouthConfig.fromMap(
        map['youth'] != null
            ? Map<String, dynamic>.from(map['youth'] as Map)
            : null,
      ),
      injury: InjuryConfig.fromMap(
        map['injury'] != null
            ? Map<String, dynamic>.from(map['injury'] as Map)
            : null,
      ),
      staff: StaffConfig.fromMap(
        map['staff'] != null
            ? Map<String, dynamic>.from(map['staff'] as Map)
            : null,
      ),
      contract: ContractConfig.fromMap(
        map['contract'] != null
            ? Map<String, dynamic>.from(map['contract'] as Map)
            : null,
      ),
    );
  }

  final FinanceConfig finance;
  final TransferConfig transfer;
  final TrainingConfig training;
  final YouthConfig youth;
  final InjuryConfig injury;
  final StaffConfig staff;
  final ContractConfig contract;

  Map<String, dynamic> toMap() => {
        'finance': finance.toMap(),
        'transfer': transfer.toMap(),
        'training': training.toMap(),
        'youth': youth.toMap(),
        'injury': injury.toMap(),
        'staff': staff.toMap(),
        'contract': contract.toMap(),
      };
}

class FinanceConfig {
  const FinanceConfig({
    this.salaryPaymentDay = 1,
    this.ticketPricePerSeat = 25,
    this.attendanceRate = 0.72,
    this.dailySponsorIncome = 1500,
    this.ffpWageRatioLimit = 0.65,
  });

  factory FinanceConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const FinanceConfig();
    }
    return FinanceConfig(
      salaryPaymentDay: map['salaryPaymentDay'] as int? ?? 1,
      ticketPricePerSeat: map['ticketPricePerSeat'] as int? ?? 25,
      attendanceRate: (map['attendanceRate'] as num?)?.toDouble() ?? 0.72,
      dailySponsorIncome: map['dailySponsorIncome'] as int? ?? 1500,
      ffpWageRatioLimit: (map['ffpWageRatioLimit'] as num?)?.toDouble() ?? 0.65,
    );
  }

  final int salaryPaymentDay;
  final int ticketPricePerSeat;
  final double attendanceRate;
  final int dailySponsorIncome;
  final double ffpWageRatioLimit;

  Map<String, dynamic> toMap() => {
        'salaryPaymentDay': salaryPaymentDay,
        'ticketPricePerSeat': ticketPricePerSeat,
        'attendanceRate': attendanceRate,
        'dailySponsorIncome': dailySponsorIncome,
        'ffpWageRatioLimit': ffpWageRatioLimit,
      };
}

class TransferConfig {
  const TransferConfig({
    this.windowMonths = const [1, 7, 8],
    this.minBudgetToBuy = 500000,
    this.feeAcceptRatio = 0.85,
    this.maxTransfersPerClubPerWindow = 2,
  });

  factory TransferConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const TransferConfig();
    }
    return TransferConfig(
      windowMonths: (map['windowMonths'] as List? ?? [1, 7, 8]).cast<int>(),
      minBudgetToBuy: map['minBudgetToBuy'] as int? ?? 500000,
      feeAcceptRatio: (map['feeAcceptRatio'] as num?)?.toDouble() ?? 0.85,
      maxTransfersPerClubPerWindow:
          map['maxTransfersPerClubPerWindow'] as int? ?? 2,
    );
  }

  final List<int> windowMonths;
  final int minBudgetToBuy;
  final double feeAcceptRatio;
  final int maxTransfersPerClubPerWindow;

  bool isWindowOpen(int month) => windowMonths.contains(month);

  Map<String, dynamic> toMap() => {
        'windowMonths': windowMonths,
        'minBudgetToBuy': minBudgetToBuy,
        'feeAcceptRatio': feeAcceptRatio,
        'maxTransfersPerClubPerWindow': maxTransfersPerClubPerWindow,
      };
}

class TrainingConfig {
  const TrainingConfig({
    this.dailyCaGainMax = 1,
    this.dailyCaGainChance = 0.15,
    this.maxAgeForGrowth = 28,
    this.matchWinMoraleBoost = 3,
    this.matchLossMoralePenalty = 2,
    this.matchFormWinBoost = 5,
    this.matchFormLossPenalty = 4,
  });

  factory TrainingConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const TrainingConfig();
    }
    return TrainingConfig(
      dailyCaGainMax: map['dailyCaGainMax'] as int? ?? 1,
      dailyCaGainChance: (map['dailyCaGainChance'] as num?)?.toDouble() ?? 0.15,
      maxAgeForGrowth: map['maxAgeForGrowth'] as int? ?? 28,
      matchWinMoraleBoost: map['matchWinMoraleBoost'] as int? ?? 3,
      matchLossMoralePenalty: map['matchLossMoralePenalty'] as int? ?? 2,
      matchFormWinBoost: map['matchFormWinBoost'] as int? ?? 5,
      matchFormLossPenalty: map['matchFormLossPenalty'] as int? ?? 4,
    );
  }

  final int dailyCaGainMax;
  final double dailyCaGainChance;
  final int maxAgeForGrowth;
  final int matchWinMoraleBoost;
  final int matchLossMoralePenalty;
  final int matchFormWinBoost;
  final int matchFormLossPenalty;

  Map<String, dynamic> toMap() => {
        'dailyCaGainMax': dailyCaGainMax,
        'dailyCaGainChance': dailyCaGainChance,
        'maxAgeForGrowth': maxAgeForGrowth,
        'matchWinMoraleBoost': matchWinMoraleBoost,
        'matchLossMoralePenalty': matchLossMoralePenalty,
        'matchFormWinBoost': matchFormWinBoost,
        'matchFormLossPenalty': matchFormLossPenalty,
      };
}

class YouthConfig {
  const YouthConfig({
    this.baseIntakePerClub = 2,
    this.minAge = 16,
    this.maxAge = 18,
    this.baseCa = 35,
    this.caVariance = 12,
    this.basePa = 55,
    this.paVariance = 25,
    this.traditionPaBonus = 0.3,
  });

  factory YouthConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const YouthConfig();
    }
    return YouthConfig(
      baseIntakePerClub: map['baseIntakePerClub'] as int? ?? 2,
      minAge: map['minAge'] as int? ?? 16,
      maxAge: map['maxAge'] as int? ?? 18,
      baseCa: map['baseCa'] as int? ?? 35,
      caVariance: map['caVariance'] as int? ?? 12,
      basePa: map['basePa'] as int? ?? 55,
      paVariance: map['paVariance'] as int? ?? 25,
      traditionPaBonus: (map['traditionPaBonus'] as num?)?.toDouble() ?? 0.3,
    );
  }

  final int baseIntakePerClub;
  final int minAge;
  final int maxAge;
  final int baseCa;
  final int caVariance;
  final int basePa;
  final int paVariance;
  final double traditionPaBonus;

  Map<String, dynamic> toMap() => {
        'baseIntakePerClub': baseIntakePerClub,
        'minAge': minAge,
        'maxAge': maxAge,
        'baseCa': baseCa,
        'caVariance': caVariance,
        'basePa': basePa,
        'paVariance': paVariance,
        'traditionPaBonus': traditionPaBonus,
      };
}

class InjuryConfig {
  const InjuryConfig({
    this.matchInjuryChance = 0.035,
    this.minDaysOut = 3,
    this.maxDaysOut = 21,
    this.maxInjuredPerClubPerMatch = 1,
  });

  factory InjuryConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const InjuryConfig();
    }
    return InjuryConfig(
      matchInjuryChance:
          (map['matchInjuryChance'] as num?)?.toDouble() ?? 0.035,
      minDaysOut: map['minDaysOut'] as int? ?? 3,
      maxDaysOut: map['maxDaysOut'] as int? ?? 21,
      maxInjuredPerClubPerMatch:
          map['maxInjuredPerClubPerMatch'] as int? ?? 1,
    );
  }

  final double matchInjuryChance;
  final int minDaysOut;
  final int maxDaysOut;
  final int maxInjuredPerClubPerMatch;

  Map<String, dynamic> toMap() => {
        'matchInjuryChance': matchInjuryChance,
        'minDaysOut': minDaysOut,
        'maxDaysOut': maxDaysOut,
        'maxInjuredPerClubPerMatch': maxInjuredPerClubPerMatch,
      };
}

class StaffConfig {
  const StaffConfig({
    this.trainingBonusPerLevel = 0.0008,
    this.injuryDaysReductionPerLevel = 0.04,
    this.maxInjuryDaysReduction = 5,
    this.youthPaBonusPerLevel = 0.05,
    this.coachWagePerReputation = 500,
    this.moraleBoostPerLevel = 0.02,
    this.maxMoraleDailyBoost = 2,
    this.injuryChanceReductionPerLevel = 0.0003,
    this.maxInjuryChanceReduction = 0.015,
  });

  factory StaffConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const StaffConfig();
    }
    return StaffConfig(
      trainingBonusPerLevel:
          (map['trainingBonusPerLevel'] as num?)?.toDouble() ?? 0.0008,
      injuryDaysReductionPerLevel:
          (map['injuryDaysReductionPerLevel'] as num?)?.toDouble() ?? 0.04,
      maxInjuryDaysReduction: map['maxInjuryDaysReduction'] as int? ?? 5,
      youthPaBonusPerLevel:
          (map['youthPaBonusPerLevel'] as num?)?.toDouble() ?? 0.05,
      coachWagePerReputation: map['coachWagePerReputation'] as int? ?? 500,
      moraleBoostPerLevel:
          (map['moraleBoostPerLevel'] as num?)?.toDouble() ?? 0.02,
      maxMoraleDailyBoost: map['maxMoraleDailyBoost'] as int? ?? 2,
      injuryChanceReductionPerLevel:
          (map['injuryChanceReductionPerLevel'] as num?)?.toDouble() ?? 0.0003,
      maxInjuryChanceReduction:
          (map['maxInjuryChanceReduction'] as num?)?.toDouble() ?? 0.015,
    );
  }

  final double trainingBonusPerLevel;
  final double injuryDaysReductionPerLevel;
  final int maxInjuryDaysReduction;
  final double youthPaBonusPerLevel;
  final int coachWagePerReputation;
  final double moraleBoostPerLevel;
  final int maxMoraleDailyBoost;
  final double injuryChanceReductionPerLevel;
  final double maxInjuryChanceReduction;

  Map<String, dynamic> toMap() => {
        'trainingBonusPerLevel': trainingBonusPerLevel,
        'injuryDaysReductionPerLevel': injuryDaysReductionPerLevel,
        'maxInjuryDaysReduction': maxInjuryDaysReduction,
        'youthPaBonusPerLevel': youthPaBonusPerLevel,
        'coachWagePerReputation': coachWagePerReputation,
        'moraleBoostPerLevel': moraleBoostPerLevel,
        'maxMoraleDailyBoost': maxMoraleDailyBoost,
        'injuryChanceReductionPerLevel': injuryChanceReductionPerLevel,
        'maxInjuryChanceReduction': maxInjuryChanceReduction,
      };
}

class ContractConfig {
  const ContractConfig({
    this.defaultExtensionYears = 2,
    this.minExtensionYears = 1,
    this.maxExtensionYears = 4,
    this.salaryIncreaseRatio = 0.10,
    this.moraleBoostOnRenewal = 5,
  });

  factory ContractConfig.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ContractConfig();
    }
    return ContractConfig(
      defaultExtensionYears: map['defaultExtensionYears'] as int? ?? 2,
      minExtensionYears: map['minExtensionYears'] as int? ?? 1,
      maxExtensionYears: map['maxExtensionYears'] as int? ?? 4,
      salaryIncreaseRatio:
          (map['salaryIncreaseRatio'] as num?)?.toDouble() ?? 0.10,
      moraleBoostOnRenewal: map['moraleBoostOnRenewal'] as int? ?? 5,
    );
  }

  final int defaultExtensionYears;
  final int minExtensionYears;
  final int maxExtensionYears;
  final double salaryIncreaseRatio;
  final int moraleBoostOnRenewal;

  Map<String, dynamic> toMap() => {
        'defaultExtensionYears': defaultExtensionYears,
        'minExtensionYears': minExtensionYears,
        'maxExtensionYears': maxExtensionYears,
        'salaryIncreaseRatio': salaryIncreaseRatio,
        'moraleBoostOnRenewal': moraleBoostOnRenewal,
      };
}
