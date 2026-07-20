import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/finance/finance_engine.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Manual player contract renewals — extends deals and updates wage bill.
class ContractEngine {
  ContractEngine({
    required WorldRegistry registry,
    required ContractConfig config,
    required FinanceEngine financeEngine,
    required EventBus eventBus,
    ContractRenewalService? renewalService,
  })  : _registry = registry,
        _config = config,
        _financeEngine = financeEngine,
        _eventBus = eventBus,
        _renewalService = renewalService ?? const ContractRenewalService();

  final WorldRegistry _registry;
  final ContractConfig _config;
  final FinanceEngine _financeEngine;
  final EventBus _eventBus;
  final ContractRenewalService _renewalService;

  ContractRenewalOffer? previewRenewal({
    required PlayerId playerId,
    required ClubId clubId,
    required int seasonYear,
    int? extensionYears,
  }) {
    final player = _registry.getPlayer(playerId);
    if (player == null ||
        !_renewalService.canRenew(player: player, clubId: clubId)) {
      return null;
    }
    return _renewalService.buildOffer(
      player: player,
      seasonYear: seasonYear,
      config: _config,
      extensionYears: extensionYears,
    );
  }

  String? renew({
    required PlayerId playerId,
    required ClubId clubId,
    required int seasonYear,
    required GameDate date,
    int? extensionYears,
  }) {
    final player = _registry.getPlayer(playerId);
    if (player == null) {
      return 'Jogador não encontrado';
    }
    if (!_renewalService.canRenew(player: player, clubId: clubId)) {
      return 'Jogador não pertence ao clube';
    }

    final offer = _renewalService.buildOffer(
      player: player,
      seasonYear: seasonYear,
      config: _config,
      extensionYears: extensionYears,
    );

    if (offer.newContractEndYear <= player.contractEndYear &&
        offer.newSalary <= player.salary) {
      return 'Contrato já vigente';
    }

    final updated = player.copyWith(
      salary: offer.newSalary,
      contractEndYear: offer.newContractEndYear,
      morale: (player.morale + _config.moraleBoostOnRenewal).clamp(1, 100),
    );
    _registry.players[playerId] = updated;
    _financeEngine.refreshMonthlyWages(clubId);

    _eventBus.publish(
      ContractRenewedEvent(
        playerId: playerId,
        playerName: player.name,
        clubId: clubId,
        extensionYears: offer.extensionYears,
        newSalary: offer.newSalary,
        newContractEndYear: offer.newContractEndYear,
        date: date,
      ),
    );

    return null;
  }
}
