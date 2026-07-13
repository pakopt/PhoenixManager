import 'package:phoenix_core/phoenix_core.dart';

/// Typed simulation events published through the Event Bus.
sealed class PhoenixEvent {
  const PhoenixEvent();
}

class DayAdvancedEvent extends PhoenixEvent {
  const DayAdvancedEvent({
    required this.previousDate,
    required this.currentDate,
    required this.tick,
  });

  final GameDate previousDate;
  final GameDate currentDate;
  final int tick;
}

class WorldInitializedEvent extends PhoenixEvent {
  const WorldInitializedEvent({required this.worldId, required this.seed});

  final String worldId;
  final int seed;
}

class WorldSavedEvent extends PhoenixEvent {
  const WorldSavedEvent({required this.saveId, required this.savedAt});

  final String saveId;
  final DateTime savedAt;
}

class MatchPlayedEvent extends PhoenixEvent {
  const MatchPlayedEvent({
    required this.fixture,
    required this.homeClubId,
    required this.awayClubId,
    required this.homeScore,
    required this.awayScore,
    this.homeXg = 0,
    this.awayXg = 0,
  });

  final MatchFixture fixture;
  final ClubId homeClubId;
  final ClubId awayClubId;
  final int homeScore;
  final int awayScore;
  final double homeXg;
  final double awayXg;
}

class SeasonFinishedEvent extends PhoenixEvent {
  const SeasonFinishedEvent({
    required this.competitionId,
    required this.seasonYear,
    required this.standings,
    required this.finishedOn,
  });

  final CompetitionId competitionId;
  final int seasonYear;
  final List<StandingEntry> standings;
  final GameDate finishedOn;
}

class SalariesPaidEvent extends PhoenixEvent {
  const SalariesPaidEvent({
    required this.clubId,
    required this.amount,
    required this.date,
  });

  final ClubId clubId;
  final int amount;
  final GameDate date;
}

class TicketRevenueEvent extends PhoenixEvent {
  const TicketRevenueEvent({
    required this.clubId,
    required this.amount,
    required this.attendance,
    required this.date,
  });

  final ClubId clubId;
  final int amount;
  final int attendance;
  final GameDate date;
}

class TransferCompletedEvent extends PhoenixEvent {
  const TransferCompletedEvent({
    required this.record,
    required this.playerName,
  });

  final TransferRecord record;
  final String playerName;
}

class YouthIntakeEvent extends PhoenixEvent {
  const YouthIntakeEvent({
    required this.clubId,
    required this.players,
    required this.seasonYear,
    required this.date,
  });

  final ClubId clubId;
  final List<Player> players;
  final int seasonYear;
  final GameDate date;
}

class PlayerInjuredEvent extends PhoenixEvent {
  const PlayerInjuredEvent({
    required this.playerId,
    required this.playerName,
    required this.clubId,
    required this.daysOut,
    required this.date,
  });

  final PlayerId playerId;
  final String playerName;
  final ClubId clubId;
  final int daysOut;
  final GameDate date;
}

class PlayerRecoveredEvent extends PhoenixEvent {
  const PlayerRecoveredEvent({
    required this.playerId,
    required this.playerName,
    required this.clubId,
  });

  final PlayerId playerId;
  final String playerName;
  final ClubId clubId;
}

class ContractRenewedEvent extends PhoenixEvent {
  const ContractRenewedEvent({
    required this.playerId,
    required this.playerName,
    required this.clubId,
    required this.extensionYears,
    required this.newSalary,
    required this.newContractEndYear,
    required this.date,
  });

  final PlayerId playerId;
  final String playerName;
  final ClubId clubId;
  final int extensionYears;
  final int newSalary;
  final int newContractEndYear;
  final GameDate date;
}

class AchievementUnlockedEvent extends PhoenixEvent {
  const AchievementUnlockedEvent({
    required this.achievementId,
    required this.clubId,
    required this.unlockedOn,
    required this.seasonYear,
  });

  final AchievementId achievementId;
  final ClubId clubId;
  final GameDate unlockedOn;
  final int seasonYear;
}

class NewSeasonStartedEvent extends PhoenixEvent {
  const NewSeasonStartedEvent({
    required this.seasonYear,
    required this.startDate,
  });

  final int seasonYear;
  final GameDate startDate;
}
