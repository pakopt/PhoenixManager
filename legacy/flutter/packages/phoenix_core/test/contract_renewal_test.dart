import 'package:phoenix_core/phoenix_core.dart';
import 'package:test/test.dart';

void main() {
  group('ContractRenewalService', () {
    const config = ContractConfig(
      defaultExtensionYears: 2,
      salaryIncreaseRatio: 0.10,
    );
    const service = ContractRenewalService();

    const player = Player(
      id: PlayerId('p1'),
      name: 'Test',
      clubId: ClubId('club-phoenix'),
      age: 28,
      currentAbility: 70,
      potentialAbility: 75,
      salary: 40000,
      contractEndYear: 2027,
    );

    test('buildOffer extends from contract end year with salary bump', () {
      final offer = service.buildOffer(
        player: player,
        seasonYear: 2026,
        config: config,
        extensionYears: 2,
      );

      expect(offer.newContractEndYear, 2029);
      expect(offer.newSalary, 44000);
      expect(offer.salaryIncrease, 4000);
    });

    test('canRenew only for same club', () {
      expect(
        service.canRenew(player: player, clubId: const ClubId('club-phoenix')),
        isTrue,
      );
      expect(
        service.canRenew(player: player, clubId: const ClubId('club-union')),
        isFalse,
      );
    });
  });
}
