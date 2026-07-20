import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';

enum CupSeasonOutcome {
  inProgress,
  champion,
  finalist,
  eliminated,
  notStarted,
}

class SeasonSummary {
  const SeasonSummary({
    required this.seasonYear,
    required this.leaguePosition,
    required this.leagueEntry,
    required this.cupOutcome,
    this.cupWinnerId,
    required this.achievementsThisSeason,
    required this.youthIntakeCount,
    required this.finance,
    required this.isFullyComplete,
    required this.honoursThisSeason,
  });

  final int seasonYear;
  final int leaguePosition;
  final StandingEntry leagueEntry;
  final CupSeasonOutcome cupOutcome;
  final ClubId? cupWinnerId;
  final List<UnlockedAchievement> achievementsThisSeason;
  final int youthIntakeCount;
  final ClubFinance? finance;
  final bool isFullyComplete;
  final List<String> honoursThisSeason;

  static SeasonSummary? fromSession(GameSession session) {
    if (!session.isSeasonComplete && !session.isCupComplete) {
      return null;
    }

    final leagueIndex = session.standings.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );
    if (leagueIndex < 0) {
      return null;
    }

    final youthCount = session.recentYouthIntakes
        .where((e) => e.seasonYear == session.seasonYear)
        .fold<int>(0, (sum, e) => sum + e.players.length);

    final achievements = session.registry.unlockedAchievements.values
        .where((a) => a.seasonYear == session.seasonYear)
        .toList()
      ..sort((a, b) => a.unlockedOn.compareTo(b.unlockedOn));

    return SeasonSummary(
      seasonYear: session.seasonYear,
      leaguePosition: leagueIndex + 1,
      leagueEntry: session.standings[leagueIndex],
      cupOutcome: _cupOutcome(session),
      cupWinnerId: session.cupWinner,
      achievementsThisSeason: achievements,
      youthIntakeCount: youthCount,
      finance: session.userFinance,
      isFullyComplete: session.isFullSeasonComplete,
      honoursThisSeason: session.honoursThisSeason,
    );
  }

  static CupSeasonOutcome _cupOutcome(GameSession session) {
    if (session.cupWinner == GameSession.userClubId) {
      return CupSeasonOutcome.champion;
    }
    if (_isCupFinalist(session)) {
      return CupSeasonOutcome.finalist;
    }
    if (session.isUserEliminatedFromCup) {
      return CupSeasonOutcome.eliminated;
    }
    if (session.isCupComplete) {
      return CupSeasonOutcome.eliminated;
    }
    if (session.nextCupFixture != null ||
        session.cupFixtures.any((f) => !f.isPlayed)) {
      return CupSeasonOutcome.inProgress;
    }
    return CupSeasonOutcome.notStarted;
  }

  static bool _isCupFinalist(GameSession session) {
    final finalMatch = session.cupBracket.finalMatch;
    if (finalMatch == null || !finalMatch.isPlayed) {
      return false;
    }
    if (!finalMatch.fixture.involvesClub(GameSession.userClubId)) {
      return false;
    }
    return session.cupWinner != GameSession.userClubId;
  }

  String cupOutcomeLabel(GameSession session) {
    return switch (cupOutcome) {
      CupSeasonOutcome.champion => 'Campeão da Taça',
      CupSeasonOutcome.finalist => 'Finalista',
      CupSeasonOutcome.eliminated => 'Eliminado',
      CupSeasonOutcome.inProgress => 'Taça em curso',
      CupSeasonOutcome.notStarted => 'Taça por iniciar',
    };
  }
}
