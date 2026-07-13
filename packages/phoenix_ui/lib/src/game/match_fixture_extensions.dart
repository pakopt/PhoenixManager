import 'package:phoenix_core/phoenix_core.dart';

extension MatchFixtureClub on MatchFixture {
  bool involvesClub(ClubId clubId) =>
      homeClubId == clubId || awayClubId == clubId;
}
