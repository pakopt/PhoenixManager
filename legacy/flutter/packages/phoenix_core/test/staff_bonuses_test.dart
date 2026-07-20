import 'package:phoenix_core/phoenix_core.dart';
import 'package:test/test.dart';

void main() {
  group('StaffBonuses', () {
    const config = StaffConfig(
      trainingBonusPerLevel: 0.001,
      injuryDaysReductionPerLevel: 0.1,
      maxInjuryDaysReduction: 5,
      youthPaBonusPerLevel: 0.1,
      moraleBoostPerLevel: 0.02,
      maxMoraleDailyBoost: 2,
      injuryChanceReductionPerLevel: 0.0003,
      maxInjuryChanceReduction: 0.015,
    );

    test('computes bonuses from staff levels', () {
      const staff = [
        StaffMember(
          id: StaffId('s1'),
          name: 'A',
          clubId: ClubId('c1'),
          role: StaffRole.assistant,
          level: 80,
        ),
        StaffMember(
          id: StaffId('s2'),
          name: 'B',
          clubId: ClubId('c1'),
          role: StaffRole.fitnessCoach,
          level: 60,
        ),
        StaffMember(
          id: StaffId('s3'),
          name: 'C',
          clubId: ClubId('c1'),
          role: StaffRole.doctor,
          level: 50,
        ),
        StaffMember(
          id: StaffId('s4'),
          name: 'D',
          clubId: ClubId('c1'),
          role: StaffRole.scout,
          level: 70,
        ),
        StaffMember(
          id: StaffId('s5'),
          name: 'E',
          clubId: ClubId('c1'),
          role: StaffRole.psychologist,
          level: 90,
        ),
        StaffMember(
          id: StaffId('s6'),
          name: 'F',
          clubId: ClubId('c1'),
          role: StaffRole.nutritionist,
          level: 80,
        ),
      ];

      final bonuses = StaffBonuses.fromStaff(staff: staff, config: config);

      expect(bonuses.trainingChanceBonus, closeTo(0.14, 0.001));
      expect(bonuses.injuryDaysReduction, 5);
      expect(bonuses.youthPaBonus, 7);
      expect(bonuses.moraleDailyBoost, 1);
      expect(bonuses.injuryChanceReduction, closeTo(0.015, 0.001));
    });
  });
}
