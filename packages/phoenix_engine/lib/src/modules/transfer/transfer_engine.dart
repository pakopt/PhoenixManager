import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/finance/finance_engine.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// AI transfer market — off-screen club-to-club moves during windows.
class TransferEngine {
  TransferEngine({
    required WorldRegistry registry,
    required TransferConfig config,
    required FinanceEngine financeEngine,
    required EventBus eventBus,
    required SeededRng rng,
    PlayerValueService? valueService,
  })  : _registry = registry,
        _config = config,
        _financeEngine = financeEngine,
        _eventBus = eventBus,
        _rng = rng,
        _valueService = valueService ?? const PlayerValueService();

  final WorldRegistry _registry;
  final TransferConfig _config;
  final FinanceEngine _financeEngine;
  final EventBus _eventBus;
  final SeededRng _rng;
  final PlayerValueService _valueService;
  var _transferCounter = 0;

  int runDaily(GameDate date) {
    if (!_config.isWindowOpen(date.month)) {
      return 0;
    }

    var completed = 0;
    final buyers = _registry.clubs.values.toList();
    _shuffleClubs(buyers, date);

    for (final buyer in buyers) {
      final buyerFinance = _registry.clubFinances[buyer.id];
      if (buyerFinance == null ||
          buyerFinance.balance < _config.minBudgetToBuy ||
          buyerFinance.transfersCompletedThisWindow >=
              _config.maxTransfersPerClubPerWindow) {
        continue;
      }

      final squadAvg = _registry.squadQuery.averageAbility(buyer.id);
      if (squadAvg >= 72) {
        continue;
      }

      final target = _findTransferTarget(buyer.id, buyerFinance.balance, date);
      if (target == null) {
        continue;
      }

      final player = target.$1;
      final sellerId = player.clubId;
      if (sellerId == buyer.id) {
        continue;
      }

      final fee = _valueService.calculate(
        player,
        club: _registry.getClub(sellerId),
      );
      final minAccept = (fee * _config.feeAcceptRatio).round();
      if (buyerFinance.balance < minAccept) {
        continue;
      }

      _executeTransfer(
        player: player,
        fromClubId: sellerId,
        toClubId: buyer.id,
        fee: minAccept,
        date: date,
      );
      completed += 1;
    }

    return completed;
  }

  int processExpiredContracts(GameDate date) {
    var freeTransfers = 0;
    for (final player in _registry.players.values.toList()) {
      if (player.contractEndYear > date.year) {
        continue;
      }

      final weakestClub = _registry.clubs.values.reduce(
        (a, b) => a.reputation < b.reputation ? a : b,
      );

      _executeTransfer(
        player: player,
        fromClubId: player.clubId,
        toClubId: weakestClub.id,
        fee: 0,
        date: date,
        isFree: true,
      );
      freeTransfers += 1;
    }
    return freeTransfers;
  }

  void resetWindowCounters() {
    for (final entry in _registry.clubFinances.entries) {
      _registry.clubFinances[entry.key] = entry.value.copyWith(
        transfersCompletedThisWindow: 0,
      );
    }
  }

  /// Compra iniciada pelo jogador. Devolve mensagem de erro ou `null` se OK.
  String? tryUserBuy({
    required ClubId buyerId,
    required PlayerId playerId,
    required GameDate date,
  }) {
    if (!_config.isWindowOpen(date.month)) {
      return 'A janela de transferências está fechada.';
    }

    final player = _registry.getPlayer(playerId);
    if (player == null) {
      return 'Jogador não encontrado.';
    }
    if (player.clubId == buyerId) {
      return 'Este jogador já está no teu plantel.';
    }

    final buyerFinance = _registry.clubFinances[buyerId];
    if (buyerFinance == null) {
      return 'Finanças do clube indisponíveis.';
    }
    if (buyerFinance.transfersCompletedThisWindow >=
        _config.maxTransfersPerClubPerWindow) {
      return 'Limite de transferências nesta janela '
          '(${_config.maxTransfersPerClubPerWindow}).';
    }

    if (_alreadyTransferredThisMonth(playerId, date)) {
      return 'Este jogador já foi transferido este mês.';
    }

    final sellerId = player.clubId;
    final fee = _valueService.calculate(
      player,
      club: _registry.getClub(sellerId),
    );
    final ask = (fee * _config.feeAcceptRatio).round();
    if (buyerFinance.balance < ask) {
      return 'Saldo insuficiente para esta oferta.';
    }

    _executeTransfer(
      player: player,
      fromClubId: sellerId,
      toClubId: buyerId,
      fee: ask,
      date: date,
    );
    return null;
  }

  /// Contratação a custo zero (contrato a acabar / livre).
  String? tryUserSignFree({
    required ClubId buyerId,
    required PlayerId playerId,
    required GameDate date,
  }) {
    if (!_config.isWindowOpen(date.month)) {
      return 'A janela de transferências está fechada.';
    }

    final player = _registry.getPlayer(playerId);
    if (player == null) {
      return 'Jogador não encontrado.';
    }
    if (player.clubId == buyerId) {
      return 'Este jogador já está no teu plantel.';
    }
    if (player.contractEndYear > date.year) {
      return 'Este jogador ainda tem contrato em vigor.';
    }

    final buyerFinance = _registry.clubFinances[buyerId];
    if (buyerFinance == null) {
      return 'Finanças do clube indisponíveis.';
    }
    if (buyerFinance.transfersCompletedThisWindow >=
        _config.maxTransfersPerClubPerWindow) {
      return 'Limite de transferências nesta janela '
          '(${_config.maxTransfersPerClubPerWindow}).';
    }

    _executeTransfer(
      player: player,
      fromClubId: player.clubId,
      toClubId: buyerId,
      fee: 0,
      date: date,
      isFree: true,
    );
    return null;
  }

  (Player, int)? _findTransferTarget(
    ClubId buyerId,
    int maxBudget,
    GameDate date,
  ) {
    Player? best;
    var bestCa = 0;

    for (final player in _registry.players.values) {
      if (player.clubId == buyerId) {
        continue;
      }
      if (_alreadyTransferredThisMonth(player.id, date)) {
        continue;
      }
      final fee = _valueService.calculate(
        player,
        club: _registry.getClub(player.clubId),
      );
      if (fee > maxBudget) {
        continue;
      }
      if (player.currentAbility > bestCa ||
          (player.currentAbility == bestCa &&
              best != null &&
              _rng.nextDouble() > 0.5)) {
        bestCa = player.currentAbility;
        best = player;
      }
    }

    if (best == null) {
      return null;
    }
    return (best, bestCa);
  }

  void _executeTransfer({
    required Player player,
    required ClubId fromClubId,
    required ClubId toClubId,
    required int fee,
    required GameDate date,
    bool isFree = false,
  }) {
    _registry.players[player.id] = player.copyWith(clubId: toClubId);

    if (!isFree && fee > 0) {
      _financeEngine.applyTransferFee(
        buyerId: toClubId,
        sellerId: fromClubId,
        fee: fee,
      );
    }

    final buyerFinance = _registry.clubFinances[toClubId];
    if (buyerFinance != null) {
      _registry.clubFinances[toClubId] = buyerFinance.copyWith(
        transfersCompletedThisWindow:
            buyerFinance.transfersCompletedThisWindow + 1,
      );
    }

    // Plantel mudou — massa salarial tem de reflectir comprador e vendedor.
    _financeEngine.refreshMonthlyWages(fromClubId);
    _financeEngine.refreshMonthlyWages(toClubId);

    _transferCounter += 1;
    final record = TransferRecord(
      id: TransferId('transfer-$_transferCounter-${player.id.value}'),
      playerId: player.id,
      fromClubId: fromClubId,
      toClubId: toClubId,
      fee: fee,
      date: date,
      isFree: isFree,
    );
    _registry.transfers.add(record);

    _eventBus.publish(
      TransferCompletedEvent(
        record: record,
        playerName: player.name,
      ),
    );
  }

  int _rngShuffleSeed(GameDate date) =>
      date.year * 10000 + date.month * 100 + date.day;

  void _shuffleClubs(List<Club> clubs, GameDate date) {
    final shuffleRng = SeededRng(_rngShuffleSeed(date));
    for (var i = clubs.length - 1; i > 0; i--) {
      final j = shuffleRng.nextInt(i + 1);
      final tmp = clubs[i];
      clubs[i] = clubs[j];
      clubs[j] = tmp;
    }
  }

  bool _alreadyTransferredThisMonth(PlayerId playerId, GameDate date) {
    return _registry.transfers.any(
      (transfer) =>
          transfer.playerId == playerId &&
          transfer.date.year == date.year &&
          transfer.date.month == date.month,
    );
  }
}
