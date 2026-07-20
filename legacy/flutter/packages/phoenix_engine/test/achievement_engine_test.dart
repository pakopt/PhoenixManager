import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:test/test.dart';

void main() {
  group('AchievementEngine', () {
    late EngineContext context;

    setUp(() async {
      context = await AppBootstrap().boot(worldId: 'achievement-test');
    });

    test('unlocks first win when user club wins', () {
      context.eventBus.publish(
        MatchPlayedEvent(
          fixture: MatchFixture(
            id: MatchId('m1'),
            competitionId: AchievementEngine.ligaId,
            round: 1,
            homeClubId: GameSession.userClubId,
            awayClubId: const ClubId('club-union'),
            date: GameDate(year: 2026, month: 8, day: 15),
            homeScore: 2,
            awayScore: 1,
            status: MatchStatus.played,
          ),
          homeClubId: GameSession.userClubId,
          awayClubId: const ClubId('club-union'),
          homeScore: 2,
          awayScore: 1,
        ),
      );

      expect(
        context.registry.unlockedAchievements
            .containsKey(AchievementCatalog.firstWin),
        isTrue,
      );
      expect(
        context.eventBus.history.whereType<AchievementUnlockedEvent>().length,
        1,
      );
    });

    test('unlocks contract renewal for user club', () {
      context.eventBus.publish(
        ContractRenewedEvent(
          playerId: const PlayerId('p-phx-1'),
          playerName: 'Rui Costa',
          clubId: GameSession.userClubId,
          extensionYears: 2,
          newSalary: 50000,
          newContractEndYear: 2030,
          date: GameDate(year: 2026, month: 9, day: 1),
        ),
      );

      expect(
        context.registry.unlockedAchievements
            .containsKey(AchievementCatalog.contractRenewed),
        isTrue,
      );
    });

    test('persists achievements through save round-trip', () {
      context.eventBus.publish(
        ContractRenewedEvent(
          playerId: const PlayerId('p-phx-1'),
          playerName: 'Rui Costa',
          clubId: GameSession.userClubId,
          extensionYears: 2,
          newSalary: 50000,
          newContractEndYear: 2030,
          date: GameDate(year: 2026, month: 9, day: 1),
        ),
      );

      final json = context.saveManager.save(
        state: context.simulationEngine.worldState,
        registry: context.registry,
      );
      final loaded = context.saveManager.deserializeRegistry(json);

      expect(
        loaded.unlockedAchievements.containsKey(AchievementCatalog.contractRenewed),
        isTrue,
      );
    });

    test('unlocks season complete when cup season ends', () {
      context.eventBus.publish(
        SeasonFinishedEvent(
          competitionId: AchievementEngine.cupId,
          seasonYear: 2026,
          standings: const [],
          finishedOn: GameDate(year: 2026, month: 10, day: 24),
        ),
      );

      expect(
        context.registry.unlockedAchievements
            .containsKey(AchievementCatalog.seasonComplete),
        isTrue,
      );
    });

    test('records league honour and unlocks champion', () {
      context.eventBus.publish(
        SeasonFinishedEvent(
          competitionId: AchievementEngine.ligaId,
          seasonYear: 2026,
          standings: const [
            StandingEntry(clubId: GameSession.userClubId, points: 30),
          ],
          finishedOn: GameDate(year: 2026, month: 5, day: 15),
        ),
      );

      expect(context.registry.seasonHonours[2026], contains('liga'));
      expect(
        context.registry.unlockedAchievements
            .containsKey(AchievementCatalog.leagueChampion),
        isTrue,
      );
    });

    test('unlocks career continues on second season start', () {
      context.eventBus.publish(
        const NewSeasonStartedEvent(
          seasonYear: 2027,
          startDate: GameDate(year: 2027, month: 8, day: 15),
        ),
      );

      expect(
        context.registry.unlockedAchievements
            .containsKey(AchievementCatalog.careerContinues),
        isTrue,
      );
    });
  });
}

// Test helper — mirrors UI user club id.
abstract final class GameSession {
  static const userClubId = ClubId('club-phoenix');
}
