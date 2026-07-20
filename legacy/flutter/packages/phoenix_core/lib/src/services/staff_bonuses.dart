import 'package:phoenix_core/src/domain/economy/economy_config.dart';
import 'package:phoenix_core/src/domain/staff.dart';

/// Computes staff impact bonuses from levels (pure functions — testable).
class StaffBonuses {
  const StaffBonuses({
    required this.trainingChanceBonus,
    required this.injuryDaysReduction,
    required this.youthPaBonus,
    required this.moraleDailyBoost,
    required this.injuryChanceReduction,
  });

  factory StaffBonuses.fromStaff({
    required List<StaffMember> staff,
    required StaffConfig config,
  }) {
    int level(StaffRole role) =>
        staff.where((s) => s.role == role).fold(0, (max, s) => s.level > max ? s.level : max);

    final assistant = level(StaffRole.assistant);
    final fitness = level(StaffRole.fitnessCoach);
    final doctor = level(StaffRole.doctor);
    final scout = level(StaffRole.scout);
    final psychologist = level(StaffRole.psychologist);
    final nutritionist = level(StaffRole.nutritionist);

    return StaffBonuses(
      trainingChanceBonus: (assistant + fitness) * config.trainingBonusPerLevel,
      injuryDaysReduction: ((doctor * config.injuryDaysReductionPerLevel).floor())
          .clamp(0, config.maxInjuryDaysReduction),
      youthPaBonus: (scout * config.youthPaBonusPerLevel).floor(),
      moraleDailyBoost: (psychologist * config.moraleBoostPerLevel)
          .floor()
          .clamp(0, config.maxMoraleDailyBoost),
      injuryChanceReduction: (nutritionist * config.injuryChanceReductionPerLevel)
          .clamp(0.0, config.maxInjuryChanceReduction),
    );
  }

  factory StaffBonuses.empty() => const StaffBonuses(
        trainingChanceBonus: 0,
        injuryDaysReduction: 0,
        youthPaBonus: 0,
        moraleDailyBoost: 0,
        injuryChanceReduction: 0,
      );

  final double trainingChanceBonus;
  final int injuryDaysReduction;
  final int youthPaBonus;
  final int moraleDailyBoost;
  final double injuryChanceReduction;
}
