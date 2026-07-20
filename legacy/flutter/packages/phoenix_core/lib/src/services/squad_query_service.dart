import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/domain/player.dart';

/// SSOT squad query — plantel derivado de [Player.clubId], nunca de Club.players[].
class SquadQueryService {
  const SquadQueryService(this._playersById);

  final Map<PlayerId, Player> _playersById;

  List<Player> getByClubId(ClubId clubId) {
    return _playersById.values
        .where((player) => player.clubId == clubId)
        .toList()
      ..sort((a, b) => b.currentAbility.compareTo(a.currentAbility));
  }

  int squadSize(ClubId clubId) => getByClubId(clubId).length;

  double averageAbility(ClubId clubId) {
    final squad = getByClubId(clubId);
    if (squad.isEmpty) {
      return 0;
    }
    final total = squad.fold<int>(0, (sum, p) => sum + p.currentAbility);
    return total / squad.length;
  }
}
