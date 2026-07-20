import 'package:phoenix_core/src/domain/economy/economy_config.dart';
import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/domain/player.dart';

/// Proposed terms for a contract renewal.
class ContractRenewalOffer {
  const ContractRenewalOffer({
    required this.extensionYears,
    required this.newSalary,
    required this.newContractEndYear,
    required this.salaryIncrease,
  });

  final int extensionYears;
  final int newSalary;
  final int newContractEndYear;
  final int salaryIncrease;
}

/// Pure contract renewal logic — testable without engine.
class ContractRenewalService {
  const ContractRenewalService();

  ContractRenewalOffer buildOffer({
    required Player player,
    required int seasonYear,
    required ContractConfig config,
    int? extensionYears,
  }) {
    final years = (extensionYears ?? config.defaultExtensionYears)
        .clamp(config.minExtensionYears, config.maxExtensionYears);
    final baseYear =
        player.contractEndYear > seasonYear ? player.contractEndYear : seasonYear;
    final newSalary =
        (player.salary * (1 + config.salaryIncreaseRatio)).round();

    return ContractRenewalOffer(
      extensionYears: years,
      newSalary: newSalary,
      newContractEndYear: baseYear + years,
      salaryIncrease: newSalary - player.salary,
    );
  }

  bool canRenew({
    required Player player,
    required ClubId clubId,
  }) =>
      player.clubId == clubId;
}
