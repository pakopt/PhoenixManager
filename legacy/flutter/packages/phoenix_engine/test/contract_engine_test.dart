import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('ContractEngine', () {
    late EngineContext context;
    late ContractEngine contractEngine;

    setUp(() async {
      context = await AppBootstrap().boot(worldId: 'contract-test');
      contractEngine = context.container.get<ContractEngine>();
    });

    test('renews player contract and updates wage bill', () {
      const playerId = PlayerId('p-phx-3');
      const clubId = ClubId('club-phoenix');
      final before = context.registry.getPlayer(playerId)!;
      final wagesBefore = context.registry.clubFinances[clubId]!.monthlyWages;

      final error = contractEngine.renew(
        playerId: playerId,
        clubId: clubId,
        seasonYear: 2026,
        date: const GameDate(year: 2026, month: 9, day: 1),
        extensionYears: 2,
      );

      expect(error, isNull);
      final after = context.registry.getPlayer(playerId)!;
      expect(after.contractEndYear, greaterThan(before.contractEndYear));
      expect(after.salary, greaterThan(before.salary));
      expect(
        context.registry.clubFinances[clubId]!.monthlyWages,
        greaterThan(wagesBefore),
      );
    });

    test('rejects renewal for other club players', () {
      final error = contractEngine.renew(
        playerId: const PlayerId('p-uni-1'),
        clubId: const ClubId('club-phoenix'),
        seasonYear: 2026,
        date: const GameDate(year: 2026, month: 9, day: 1),
      );

      expect(error, isNotNull);
    });
  });
}
