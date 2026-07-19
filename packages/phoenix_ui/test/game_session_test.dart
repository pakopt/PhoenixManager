import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/season_summary.dart';

void main() {
  test('GameSession user club is Phoenix FC; PT peers have identity', () async {
    expect(GameSession.userClubId.value, 'club-phoenix');
    final context = await AppBootstrap().boot(worldId: 'coruja-ui-test');
    final session = GameSession(context);
    expect(session.userClub.name, 'Phoenix FC');
    expect(session.userClub.shortName, 'Phoenix');
    expect(session.userClub.logoAsset, isNull);

    final coruja = context.registry.clubs[const ClubId('club-coruja')];
    expect(coruja, isNotNull);
    expect(coruja!.name, contains('Coruja'));
    expect(coruja.shortName, 'A Coruja');
    expect(coruja.president, 'José Gomes');
    expect(coruja.association, 'AF Madeira');
    expect(coruja.foundedOn, '1976-04-09');
    expect(coruja.logoAsset, 'assets/clubs/coruja.png');
    expect(
      coruja.teams,
      [
        'Equipa Principal',
        'Jun.A S19',
        'Jun.B S17',
        'Jun.C S15',
        'Jun.D S13',
        'Veteranos',
        'Fut.7 Jun.D S12',
        'Fut.7 Jun.E S11',
      ],
    );

    final sindicato = context.registry.clubs[const ClubId('club-sindicato')];
    expect(sindicato, isNotNull);
    expect(sindicato!.name, 'Grupo Desportivo Recreativo «O Sindicato»');
    expect(sindicato.shortName, 'GDR «O Sindicato»');
    expect(sindicato.president, 'João Raimundo');
    expect(sindicato.association, 'AAF Setúbal');
    expect(sindicato.foundedOn, '1977-02-06');
    expect(sindicato.logoAsset, 'assets/clubs/sindicato.png');
    expect(sindicato.kitAsset, 'assets/clubs/sindicato-kit.png');
    expect(sindicato.cityId.value, 'setubal');
    expect(
      sindicato.teams,
      [
        'Equipa Principal',
        'Jun.A S19',
        'Jun.B S17',
        'Jun.C S15',
        'Jun.D S13',
        'Fut.7 Jun.D S13',
        'Fut.7 Jun.D S12',
        'Fut.7 Jun.E S11',
        'Fut.7 Jun.E S10',
        'Fut.7 Jun.F S9',
      ],
    );

    final squad = context.registry.squadQuery
        .getByClubId(const ClubId('club-sindicato'));
    expect(squad.length, 37);
    expect(squad.any((p) => p.name == 'Diogo Correia'), isTrue);
    expect(squad.any((p) => p.name == 'João Raimundo'), isTrue);
    expect(
      squad.where((p) => p.nationalityId?.value == 'brazil').length,
      6,
    );
    expect(
      squad.where((p) => p.nationalityId?.value == 'angola').length,
      5,
    );
  });

  test('salaryBreakdown matches club finance monthly wages', () async {
    final context = await AppBootstrap().boot(worldId: 'finance-ui-test');
    final session = GameSession(context);
    final finance = session.userFinance;
    final breakdown = session.salaryBreakdown;

    expect(finance, isNotNull);
    expect(breakdown.total, finance!.monthlyWages);
    expect(breakdown.players, greaterThan(0));
    expect(breakdown.staff, greaterThan(0));
    expect(breakdown.coach, greaterThan(0));
  });

  test('clubTransfersThisSeason excludes prior seasons', () async {
    final context = await AppBootstrap().boot(worldId: 'transfers-season-test');
    final session = GameSession(context);
    final year = session.seasonYear;
    final user = GameSession.userClubId;
    final peer = context.registry.clubs.values
        .firstWhere((c) => c.id != user)
        .id;
    final player = context.registry.players.values.first;

    context.registry.transfers.addAll([
      TransferRecord(
        id: const TransferId('t-old'),
        playerId: player.id,
        fromClubId: user,
        toClubId: peer,
        fee: 100000,
        date: GameDate(year: year - 1, month: 9, day: 1),
      ),
      TransferRecord(
        id: const TransferId('t-current'),
        playerId: player.id,
        fromClubId: peer,
        toClubId: user,
        fee: 200000,
        date: GameDate(year: year, month: 9, day: 1),
      ),
    ]);

    expect(session.clubTransfers.length, greaterThanOrEqualTo(2));
    expect(
      session.clubTransfersThisSeason.map((t) => t.id.value),
      contains('t-current'),
    );
    expect(
      session.clubTransfersThisSeason.map((t) => t.id.value),
      isNot(contains('t-old')),
    );
  });

  test('importSave rehydrates inbox feed from registry', () async {
    final context = await AppBootstrap().boot(worldId: 'rehydrate-inbox-test');
    final session = GameSession(context);
    final user = GameSession.userClubId;
    final peer = context.registry.clubs.values
        .firstWhere((c) => c.id != user)
        .id;
    final player = context.registry.players.values.first;

    context.registry.transfers.add(
      TransferRecord(
        id: const TransferId('t-rehydrate'),
        playerId: player.id,
        fromClubId: peer,
        toClubId: user,
        fee: 150000,
        date: session.currentDate,
      ),
    );
    context.eventBus.clearHistory();
    expect(session.inboxEvents, isEmpty);

    final json = session.exportSave();
    session.importSave(json);

    expect(
      session.inboxEvents.whereType<TransferCompletedEvent>().any(
            (e) => e.record.id.value == 't-rehydrate',
          ),
      isTrue,
    );
  });

  test('contractsExpiringSoon lists players ending next season', () async {
    final context = await AppBootstrap().boot(worldId: 'contracts-test');
    final session = GameSession(context);

    expect(session.seasonYear, 2026);
    expect(session.contractsExpiringSoon, isNotEmpty);
    expect(
      session.contractsExpiringSoon.every(
        (p) => p.contractEndYear == session.seasonYear + 1,
      ),
      isTrue,
    );
  });

  test('renewContract updates player and wages', () async {
    final context = await AppBootstrap().boot(worldId: 'renew-ui-test');
    final session = GameSession(context);
    const playerId = PlayerId('p-phx-3');
    final before = session.getPlayer(playerId)!;
    final wagesBefore = session.userFinance!.monthlyWages;

    final error = session.renewContract(playerId, extensionYears: 2);

    expect(error, isNull);
    final after = session.getPlayer(playerId)!;
    expect(after.contractEndYear, greaterThan(before.contractEndYear));
    expect(after.salary, greaterThan(before.salary));
    expect(session.userFinance!.monthlyWages, greaterThan(wagesBefore));
  });

  test('league and cup fixtures are separated', () async {
    final context = await AppBootstrap().boot(worldId: 'cup-ui-test');
    final session = GameSession(context);

    expect(session.leagueFixtures.length, 30);
    expect(session.cupFixtures.length, 2);
    expect(
      session.leagueFixtures.every(
        (f) => f.competitionId == GameSession.primaryCompetitionId,
      ),
      isTrue,
    );
    expect(
      session.cupFixtures.every(
        (f) => f.competitionId == GameSession.cupCompetitionId,
      ),
      isTrue,
    );
    expect(session.competitionName(GameSession.cupCompetitionId), 'Taça Phoenix');
  });

  test('cupBracket exposes semi-finals and pending final', () async {
    final context = await AppBootstrap().boot(worldId: 'cup-bracket-test');
    final session = GameSession(context);
    final bracket = session.cupBracket;

    expect(bracket.semiFinals.length, 2);
    expect(bracket.finalMatch, isNull);
    expect(bracket.championId, isNull);
    expect(bracket.semiFinals.every((s) => !s.isPlayed), isTrue);
  });

  test('nextFixture prefers earliest user match across competitions', () async {
    final context = await AppBootstrap().boot(worldId: 'next-fixture-test');
    final session = GameSession(context);
    final next = session.nextFixture;

    expect(next, isNotNull);
    expect(
      next!.homeClubId == GameSession.userClubId ||
          next.awayClubId == GameSession.userClubId,
      isTrue,
    );

    final userUpcoming = session.upcomingFixtures
        .where(
          (f) =>
              f.homeClubId == GameSession.userClubId ||
              f.awayClubId == GameSession.userClubId,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    expect(next.date, userUpcoming.first.date);
  });

  test('isUserEliminatedFromCup is false before cup starts', () async {
    final context = await AppBootstrap().boot(worldId: 'cup-elim-test');
    final session = GameSession(context);

    expect(session.isUserEliminatedFromCup, isFalse);
    expect(session.nextCupFixture, isNotNull);
  });

  test('achievementEntries lists catalog with unlock state', () async {
    final context = await AppBootstrap().boot(worldId: 'ach-ui-test');
    final session = GameSession(context);

    expect(session.achievementEntries.length, AchievementCatalog.all.length);
    expect(session.unlockedAchievementCount, 0);

    session.renewContract(const PlayerId('p-phx-3'), extensionYears: 1);

    expect(session.unlockedAchievementCount, 1);
    expect(
      session.achievementEntries
          .firstWhere((e) => e.definition.id == AchievementCatalog.contractRenewed)
          .isUnlocked,
      isTrue,
    );
  });

  test('seasonSummary is null before league ends', () async {
    final context = await AppBootstrap().boot(worldId: 'season-summary-test');
    final session = GameSession(context);

    expect(SeasonSummary.fromSession(session), isNull);
  });

  test('seasonHonoursEntries is empty at career start', () async {
    final context = await AppBootstrap().boot(worldId: 'honours-test');
    final session = GameSession(context);

    expect(session.seasonHonoursEntries, isEmpty);
    expect(session.leagueTitlesWon, 0);
    expect(session.cupTitlesWon, 0);
    expect(session.achievementEntries.length, 10);
  });
}
