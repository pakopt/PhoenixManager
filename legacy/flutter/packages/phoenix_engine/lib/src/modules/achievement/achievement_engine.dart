import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/src/event_bus/event_bus.dart';
import 'package:phoenix_engine/src/event_bus/world_events.dart';
import 'package:phoenix_engine/src/modules/competition/competition_manager.dart';
import 'package:phoenix_engine/src/world/world_registry.dart';

/// Tracks career milestones for the user club via the event bus.
class AchievementEngine {
  AchievementEngine({
    required WorldRegistry registry,
    required EventBus eventBus,
    required CompetitionManager competitionManager,
    ClubId userClubId = const ClubId('club-phoenix'),
  })  : _registry = registry,
        _eventBus = eventBus,
        _competitionManager = competitionManager,
        _userClubId = userClubId {
    eventBus.subscribe<MatchPlayedEvent>(_onMatchPlayed);
    eventBus.subscribe<SeasonFinishedEvent>(_onSeasonFinished);
    eventBus.subscribe<ContractRenewedEvent>(_onContractRenewed);
    eventBus.subscribe<TransferCompletedEvent>(_onTransferCompleted);
    eventBus.subscribe<YouthIntakeEvent>(_onYouthIntake);
    eventBus.subscribe<NewSeasonStartedEvent>(_onNewSeasonStarted);
  }

  static const ligaId = CompetitionId('liga-phoenix');
  static const cupId = CompetitionId('taca-phoenix');

  final WorldRegistry _registry;
  final EventBus _eventBus;
  final CompetitionManager _competitionManager;
  final ClubId _userClubId;

  void _onMatchPlayed(MatchPlayedEvent event) {
    if (!_involvesUser(event.homeClubId, event.awayClubId)) {
      return;
    }

    final userWon = _userWonMatch(event);
    if (userWon) {
      _unlock(
        AchievementCatalog.firstWin,
        event.fixture.date,
        seasonYear: event.fixture.date.year,
      );
    }
  }

  void _onSeasonFinished(SeasonFinishedEvent event) {
    if (event.competitionId == ligaId) {
      final leader = event.standings.isNotEmpty ? event.standings.first : null;
      if (leader?.clubId == _userClubId) {
        _recordHonour(event.seasonYear, 'liga', event.finishedOn);
        _unlock(
          AchievementCatalog.leagueChampion,
          event.finishedOn,
          seasonYear: event.seasonYear,
        );
      }
      return;
    }

    if (event.competitionId == cupId) {
      final winner = _competitionManager.cupWinner(cupId);
      if (winner == _userClubId) {
        _recordHonour(event.seasonYear, 'taca', event.finishedOn);
        _unlock(
          AchievementCatalog.cupChampion,
          event.finishedOn,
          seasonYear: event.seasonYear,
        );
      }
      _unlock(
        AchievementCatalog.seasonComplete,
        event.finishedOn,
        seasonYear: event.seasonYear,
      );
    }
  }

  void _onNewSeasonStarted(NewSeasonStartedEvent event) {
    if (event.seasonYear <= 2026) {
      return;
    }
    _unlock(
      AchievementCatalog.careerContinues,
      event.startDate,
      seasonYear: event.seasonYear,
    );
  }

  void _onContractRenewed(ContractRenewedEvent event) {
    if (event.clubId != _userClubId) {
      return;
    }
    _unlock(
      AchievementCatalog.contractRenewed,
      event.date,
      seasonYear: event.date.year,
    );
  }

  void _onTransferCompleted(TransferCompletedEvent event) {
    final record = event.record;
    if (record.fromClubId != _userClubId && record.toClubId != _userClubId) {
      return;
    }
    _unlock(
      AchievementCatalog.transferDeal,
      record.date,
      seasonYear: record.date.year,
    );
  }

  void _onYouthIntake(YouthIntakeEvent event) {
    if (event.clubId != _userClubId) {
      return;
    }
    _unlock(
      AchievementCatalog.youthIntake,
      event.date,
      seasonYear: event.seasonYear,
    );

    final hasWonderkid = event.players.any(
      (player) => player.potentialAbility - player.currentAbility >= 15,
    );
    if (hasWonderkid) {
      _unlock(
        AchievementCatalog.wonderkid,
        event.date,
        seasonYear: event.seasonYear,
      );
    }
  }

  void _recordHonour(int seasonYear, String honour, GameDate date) {
    final honours = _registry.seasonHonours.putIfAbsent(seasonYear, () => {});
    honours.add(honour);
    if (honours.contains('liga') && honours.contains('taca')) {
      _unlock(
        AchievementCatalog.doubleWinner,
        date,
        seasonYear: seasonYear,
      );
    }
  }

  bool _involvesUser(ClubId home, ClubId away) =>
      home == _userClubId || away == _userClubId;

  bool _userWonMatch(MatchPlayedEvent event) {
    if (event.homeClubId == _userClubId) {
      return event.homeScore > event.awayScore;
    }
    if (event.awayClubId == _userClubId) {
      return event.awayScore > event.homeScore;
    }
    return false;
  }

  void _unlock(
    AchievementId id,
    GameDate date, {
    required int seasonYear,
  }) {
    if (_registry.unlockedAchievements.containsKey(id)) {
      return;
    }

    _registry.unlockedAchievements[id] = UnlockedAchievement(
      id: id,
      unlockedOn: date,
      seasonYear: seasonYear,
    );

    _eventBus.publish(
      AchievementUnlockedEvent(
        achievementId: id,
        clubId: _userClubId,
        unlockedOn: date,
        seasonYear: seasonYear,
      ),
    );
  }
}
