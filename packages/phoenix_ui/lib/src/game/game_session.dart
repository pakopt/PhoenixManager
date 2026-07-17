import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/achievement_entry.dart';
import 'package:phoenix_ui/src/game/career_stats.dart';
import 'package:phoenix_ui/src/game/cup_bracket_snapshot.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';
import 'package:phoenix_ui/src/game/recent_form.dart';
import 'package:phoenix_ui/src/game/season_honour.dart';

/// Read-only facade over [EngineContext] for UI — no duplicated game logic.
class GameSession {
  GameSession(this._context);

  final EngineContext _context;

  static const userClubId = ClubId('club-phoenix');
  static const primaryCompetitionId = CompetitionId('liga-phoenix');
  static const cupCompetitionId = CompetitionId('taca-phoenix');

  EngineContext get context => _context;
  WorldRegistry get registry => _context.registry;
  WorldState get worldState => _context.simulationEngine.worldState;
  GameDate get currentDate => worldState.currentDate;
  int get tick => worldState.tick;

  Club get userClub {
    final club = registry.getClub(userClubId);
    if (club == null) {
      throw StateError('User club not found: ${userClubId.value}');
    }
    return club;
  }

  ClubFinance? get userFinance => registry.clubFinances[userClubId];

  Coach? get userCoach {
    final coachId = userClub.coachId;
    if (coachId == null) {
      return null;
    }
    return registry.getCoach(coachId);
  }

  List<StaffMember> get userStaff =>
      registry.staffQuery.getByClubId(userClubId);

  StaffBonuses get staffBonuses => StaffBonuses.fromStaff(
        staff: userStaff,
        config: context.economyConfig.staff,
      );

  int get staffMonthlyWages =>
      userStaff.fold(0, (sum, s) => sum + s.salary);

  int get playerMonthlyWages =>
      squad.fold(0, (sum, p) => sum + p.salary);

  int get coachMonthlyWage {
    final coach = userCoach;
    if (coach == null) {
      return 0;
    }
    return coach.reputation * context.economyConfig.staff.coachWagePerReputation;
  }

  SalaryBreakdown get salaryBreakdown => SalaryBreakdown(
        players: playerMonthlyWages,
        staff: staffMonthlyWages,
        coach: coachMonthlyWage,
      );

  int get seasonYear =>
      registry.getCompetition(primaryCompetitionId)?.seasonYear ??
      currentDate.year;

  List<Player> get expiringContractsThisSeason => squad
      .where((p) => p.contractEndYear <= seasonYear)
      .toList()
    ..sort((a, b) => a.contractEndYear.compareTo(b.contractEndYear));

  List<Player> get contractsExpiringSoon => squad
      .where((p) => p.contractEndYear == seasonYear + 1)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  bool get hasContractAlerts =>
      expiringContractsThisSeason.isNotEmpty ||
      contractsExpiringSoon.isNotEmpty;

  ContractConfig get contractConfig => context.economyConfig.contract;

  ContractRenewalOffer? renewalOfferFor(PlayerId playerId, {int? years}) {
    return _context.economyRunner.contractEngine.previewRenewal(
      playerId: playerId,
      clubId: userClubId,
      seasonYear: seasonYear,
      extensionYears: years,
    );
  }

  bool canRenewPlayer(Player player) =>
      player.clubId == userClubId;

  /// Returns error message on failure, null on success.
  String? renewContract(PlayerId playerId, {int? extensionYears}) {
    return _context.economyRunner.contractEngine.renew(
      playerId: playerId,
      clubId: userClubId,
      seasonYear: seasonYear,
      date: currentDate,
      extensionYears: extensionYears,
    );
  }

  Player? getPlayer(PlayerId id) => registry.getPlayer(id);

  List<Player> get lowMoralePlayers =>
      squad.where((p) => p.morale < 60 && !p.isInjured).toList()
        ..sort((a, b) => a.morale.compareTo(b.morale));

  InjuryConfig get injuryConfig => context.economyConfig.injury;

  List<Player> get squad =>
      registry.squadQuery.getByClubId(userClubId)
        ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));

  List<Player> get injuredPlayers =>
      squad.where((p) => p.isInjured).toList()
        ..sort((a, b) => b.injuredDaysRemaining.compareTo(a.injuredDaysRemaining));

  List<Player> get fitPlayers => squad.where((p) => !p.isInjured).toList();

  List<StandingEntry> get standings =>
      _context.competitionManager.standings(primaryCompetitionId);

  List<MatchFixture> get allFixtures {
    final fixtures = registry.fixtures.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return fixtures;
  }

  List<MatchFixture> get leagueFixtures => allFixtures
      .where((f) => f.competitionId == primaryCompetitionId)
      .toList();

  List<MatchFixture> get cupFixtures =>
      allFixtures.where((f) => f.competitionId == cupCompetitionId).toList();

  ClubId? get cupWinner =>
      _context.competitionManager.cupWinner(cupCompetitionId);

  CupBracketSnapshot get cupBracket => CupBracketSnapshot.fromSession(this);

  List<AchievementEntry> get achievementEntries {
    return AchievementCatalog.all
        .map(
          (definition) => AchievementEntry(
            definition: definition,
            unlocked: registry.unlockedAchievements[definition.id],
          ),
        )
        .toList();
  }

  int get unlockedAchievementCount =>
      registry.unlockedAchievements.length;

  List<SeasonHonourEntry> get seasonHonoursEntries {
    return registry.seasonHonours.entries
        .map(
          (entry) => SeasonHonourEntry(
            seasonYear: entry.key,
            honours: entry.value.toList()..sort(),
          ),
        )
        .toList()
      ..sort((a, b) => b.seasonYear.compareTo(a.seasonYear));
  }

  int get leagueTitlesWon =>
      registry.seasonHonours.values.where((h) => h.contains('liga')).length;

  int get cupTitlesWon =>
      registry.seasonHonours.values.where((h) => h.contains('taca')).length;

  List<String> get honoursThisSeason =>
      registry.seasonHonours[seasonYear]?.toList() ?? const [];

  CareerStats get careerStats => CareerStats.fromSession(this);

  List<RecentFormEntry> recentForm({int limit = 5}) =>
      RecentForm.fromSession(this, limit: limit);

  bool get isTransferWindowOpen =>
      context.economyConfig.transfer.isWindowOpen(currentDate.month);

  TransferConfig get transferConfig => context.economyConfig.transfer;

  int get leaguePosition {
    final index = standings.indexWhere((e) => e.clubId == userClubId);
    return index >= 0 ? index + 1 : 0;
  }

  String achievementTitle(AchievementId id) =>
      AchievementCatalog.find(id)?.title ?? id.value;

  String competitionName(CompetitionId id) =>
      registry.getCompetition(id)?.name ?? id.value;

  List<MatchFixture> get upcomingFixtures =>
      allFixtures.where((f) => !f.isPlayed).toList();

  MatchFixture? get nextLeagueFixture => _nextUserFixtureIn(leagueFixtures);

  MatchFixture? get nextCupFixture => _nextUserFixtureIn(cupFixtures);

  MatchFixture? get nextFixture {
    MatchFixture? earliest;
    for (final fixture in upcomingFixtures) {
      if (!fixture.involvesClub(userClubId)) {
        continue;
      }
      if (earliest == null || fixture.date.compareTo(earliest.date) < 0) {
        earliest = fixture;
      }
    }
    return earliest;
  }

  bool get isCupComplete =>
      _context.competitionManager.isSeasonComplete(cupCompetitionId);

  bool get isFullSeasonComplete => isSeasonComplete && isCupComplete;

  bool get isUserEliminatedFromCup {
    if (cupWinner == userClubId) {
      return false;
    }
    if (cupFixtures.any(
      (f) => !f.isPlayed && f.involvesClub(userClubId),
    )) {
      return false;
    }

    final playedUserCup = cupFixtures.where(
      (f) => f.isPlayed && f.involvesClub(userClubId),
    );
    if (playedUserCup.isEmpty) {
      return false;
    }

    for (final fixture in playedUserCup) {
      final winner = resolveCupWinner(
        fixture: fixture,
        registry: registry,
      );
      if (winner == userClubId) {
        continue;
      }
      return true;
    }

    return cupWinner != null && cupWinner != userClubId;
  }

  String cupRoundLabel(MatchFixture fixture) {
    if (fixture.competitionId != cupCompetitionId) {
      return '';
    }
    return switch (fixture.round) {
      1 => 'Meia-final',
      2 => 'Final',
      _ => 'Eliminatória',
    };
  }

  MatchFixture? _nextUserFixtureIn(List<MatchFixture> fixtures) {
    for (final fixture in fixtures) {
      if (!fixture.isPlayed && fixture.involvesClub(userClubId)) {
        return fixture;
      }
    }
    return null;
  }

  bool get isSeasonComplete =>
      _context.competitionManager.isSeasonComplete(primaryCompetitionId);

  int get matchesPlayed =>
      allFixtures.where((f) => f.isPlayed).length;

  TrainingConfig get trainingConfig => context.economyConfig.training;

  YouthConfig get youthConfig => context.economyConfig.youth;

  List<Player> get academyPlayers {
    final maxAge = youthConfig.maxAge;
    return squad.where((p) => p.age <= maxAge).toList()
      ..sort((a, b) => b.potentialAbility.compareTo(a.potentialAbility));
  }

  List<Player> get wonderkids =>
      academyPlayers.where((p) => p.potentialAbility - p.currentAbility >= 15).toList();

  List<YouthIntakeEvent> get recentYouthIntakes {
    return _context.eventBus.history
        .whereType<YouthIntakeEvent>()
        .where((e) => e.clubId == userClubId)
        .toList()
        .reversed
        .take(3)
        .toList();
  }

  List<Player> get trainablePlayers => squad
      .where(
        (p) =>
            !p.isInjured &&
            p.age <= trainingConfig.maxAgeForGrowth &&
            p.currentAbility < p.potentialAbility,
      )
      .toList();

  double get squadAverageCa {
    if (squad.isEmpty) {
      return 0;
    }
    return squad.map((p) => p.currentAbility).reduce((a, b) => a + b) /
        squad.length;
  }

  double get squadAverageForm {
    if (squad.isEmpty) {
      return 0;
    }
    return squad.map((p) => p.form).reduce((a, b) => a + b) / squad.length;
  }

  List<TransferRecord> get clubTransfers => registry.transfers
      .where(
        (t) => t.fromClubId == userClubId || t.toClubId == userClubId,
      )
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  List<PhoenixEvent> get recentEvents {
    final events = _context.eventBus.history;
    return events.length <= 12
        ? List<PhoenixEvent>.from(events.reversed)
        : events.sublist(events.length - 12).reversed.toList();
  }

  /// Eventos relevantes para a Inbox (sem dias vazios / boot).
  List<PhoenixEvent> get inboxEvents {
    final events = _context.eventBus.history;
    return events.reversed.where(_isInboxEvent).take(80).toList();
  }

  bool _isInboxEvent(PhoenixEvent event) {
    return switch (event) {
      DayAdvancedEvent() ||
      WorldInitializedEvent() ||
      WorldSavedEvent() =>
        false,
      MatchPlayedEvent e =>
        e.homeClubId == userClubId || e.awayClubId == userClubId,
      TransferCompletedEvent e =>
        e.record.fromClubId == userClubId || e.record.toClubId == userClubId,
      ContractRenewedEvent e => e.clubId == userClubId,
      PlayerInjuredEvent e => e.clubId == userClubId,
      PlayerRecoveredEvent e => e.clubId == userClubId,
      AchievementUnlockedEvent e => e.clubId == userClubId,
      SalariesPaidEvent e => e.clubId == userClubId,
      TicketRevenueEvent e => e.clubId == userClubId,
      YouthIntakeEvent e => e.clubId == userClubId,
      SeasonFinishedEvent() || NewSeasonStartedEvent() => true,
    };
  }

  /// Returns error message on failure, null on success.
  String? beginNextSeason() {
    if (!isFullSeasonComplete) {
      return 'A época ainda não terminou';
    }

    final nextYear = seasonYear + 1;
    final seasonStart = GameDate(year: nextYear, month: 8, day: 15);

    final error = _context.competitionManager.beginNextSeason(
      leagueId: primaryCompetitionId,
      cupId: cupCompetitionId,
      leagueSeasonStart: seasonStart,
    );
    if (error != null) {
      return error;
    }

    _context.worldManager.loadState(
      worldState.copyWith(currentDate: seasonStart),
    );
    _context.economyRunner.resetSeasonFinanceStats();
    return null;
  }

  void advanceDay() {
    _context.simulationEngine.tickOneDay();
  }

  void advanceWeek() {
    _context.timeController.advance(SimulationStep.week);
  }

  void advanceToNextUserMatch() {
    final next = nextFixture;
    if (next == null) {
      return;
    }
    final days = _daysUntil(next.date);
    if (days > 0) {
      _context.simulationEngine.tickDays(days);
    }
  }

  MatchSimulationOutput? simulateFixture(MatchFixture fixture) {
    if (fixture.isPlayed) {
      final result = registry.matchResults[fixture.id];
      if (result == null) {
        return null;
      }
      return MatchSimulationOutput(
        fixture: fixture,
        result: result,
      );
    }
    final output = _context.matchSimulator.simulate(fixture);
    _context.competitionManager.recordResult(output.fixture);
    final played = output.fixture;
    final matchEvent = MatchPlayedEvent(
      fixture: played,
      homeClubId: played.homeClubId,
      awayClubId: played.awayClubId,
      homeScore: played.homeScore!,
      awayScore: played.awayScore!,
      homeXg: output.result.homeStats.xg,
      awayXg: output.result.awayStats.xg,
    );
    _context.eventBus.publish(matchEvent);
    _context.economyRunner.onMatchPlayed(matchEvent);
    return output;
  }

  MatchSimulationOutput? getUserMatchOnDate(GameDate date) {
    for (final fixture in registry.fixturesOnDate(date)) {
      if (!fixture.involvesClub(userClubId) || !fixture.isPlayed) {
        continue;
      }
      final result = registry.matchResults[fixture.id];
      if (result == null) {
        continue;
      }
      return MatchSimulationOutput(fixture: fixture, result: result);
    }
    return null;
  }

  String clubName(ClubId id) => registry.getClub(id)?.name ?? id.value;

  String exportSave() {
    return _context.saveManager.save(
      state: worldState,
      registry: registry,
    );
  }

  void importSave(String json) {
    final envelope = _context.saveManager.deserializeEnvelope(json);
    _context.worldManager.loadState(envelope.world);
    registry.replaceWith(envelope.registry);
    _context.eventBus.clearHistory();
  }

  /// After advancing to match day, returns the user's most recent played match.
  MatchSimulationOutput? getLatestUserMatch() {
    MatchFixture? latestFixture;
    for (final fixture in allFixtures) {
      if (!fixture.isPlayed || !fixture.involvesClub(userClubId)) {
        continue;
      }
      if (latestFixture == null ||
          fixture.date.compareTo(latestFixture.date) > 0) {
        latestFixture = fixture;
      }
    }
    if (latestFixture == null) {
      return null;
    }
    final result = registry.matchResults[latestFixture.id];
    if (result == null) {
      return null;
    }
    return MatchSimulationOutput(fixture: latestFixture, result: result);
  }

  int _daysUntil(GameDate target) {
    var days = 0;
    var cursor = currentDate;
    while (cursor.compareTo(target) < 0) {
      cursor = cursor.addDays(1);
      days += 1;
    }
    return days;
  }
}

/// Monthly wage bill split — mirrors [FinanceEngine] salary calculation.
class SalaryBreakdown {
  const SalaryBreakdown({
    required this.players,
    required this.staff,
    required this.coach,
  });

  final int players;
  final int staff;
  final int coach;

  int get total => players + staff + coach;

  double fractionOf(int part) => total <= 0 ? 0 : part / total;
}
