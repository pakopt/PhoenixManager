import 'package:phoenix_core/phoenix_core.dart';

/// Generates knockout cup fixtures — semi-finals seeded by reputation.
class CupScheduler {
  const CupScheduler();

  List<MatchFixture> generateSemiFinals({
    required Competition competition,
    required GameDate semiFinalDate,
    required List<ClubId> seededClubIds,
  }) {
    if (seededClubIds.length != 4) {
      throw ArgumentError('Cup MVP requires exactly 4 clubs');
    }

    return [
      MatchFixture(
        id: MatchId('${competition.id.value}-sf1'),
        competitionId: competition.id,
        round: 1,
        homeClubId: seededClubIds[0],
        awayClubId: seededClubIds[3],
        date: semiFinalDate,
      ),
      MatchFixture(
        id: MatchId('${competition.id.value}-sf2'),
        competitionId: competition.id,
        round: 1,
        homeClubId: seededClubIds[1],
        awayClubId: seededClubIds[2],
        date: semiFinalDate,
      ),
    ];
  }

  MatchFixture generateFinal({
    required Competition competition,
    required GameDate finalDate,
    required ClubId homeClubId,
    required ClubId awayClubId,
  }) {
    return MatchFixture(
      id: MatchId('${competition.id.value}-final'),
      competitionId: competition.id,
      round: 2,
      homeClubId: homeClubId,
      awayClubId: awayClubId,
      date: finalDate,
    );
  }
}
