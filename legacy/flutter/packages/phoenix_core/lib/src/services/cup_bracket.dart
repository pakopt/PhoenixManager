import 'package:phoenix_core/phoenix_core.dart';

/// Knockout cup winner resolution — draws go to higher reputation.
ClubId resolveCupWinner({
  required MatchFixture fixture,
  required WorldRegistryReader registry,
}) {
  final homeScore = fixture.homeScore ?? 0;
  final awayScore = fixture.awayScore ?? 0;
  if (homeScore > awayScore) {
    return fixture.homeClubId;
  }
  if (awayScore > homeScore) {
    return fixture.awayClubId;
  }

  final homeRep = registry.getClub(fixture.homeClubId)?.reputation ?? 0;
  final awayRep = registry.getClub(fixture.awayClubId)?.reputation ?? 0;
  if (homeRep >= awayRep) {
    return fixture.homeClubId;
  }
  return fixture.awayClubId;
}

/// Minimal read interface for cup resolution (engine registry implements).
abstract class WorldRegistryReader {
  Club? getClub(ClubId id);
}
