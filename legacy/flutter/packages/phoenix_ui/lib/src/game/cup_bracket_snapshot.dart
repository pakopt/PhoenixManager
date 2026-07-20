import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

/// Read-only projection of cup knockout state for UI.
class CupMatchSlot {
  const CupMatchSlot({
    required this.fixture,
    this.winnerId,
  });

  final MatchFixture fixture;
  final ClubId? winnerId;

  bool get isPlayed => fixture.isPlayed;
}

class CupBracketSnapshot {
  const CupBracketSnapshot({
    required this.semiFinals,
    this.finalMatch,
    this.championId,
  });

  final List<CupMatchSlot> semiFinals;
  final CupMatchSlot? finalMatch;
  final ClubId? championId;

  bool get hasFinal => finalMatch != null;

  static CupBracketSnapshot fromSession(GameSession session) {
    final semis = session.cupFixtures
        .where((f) => f.round == 1)
        .toList()
      ..sort((a, b) => a.id.value.compareTo(b.id.value));

    final finalFixture = session.cupFixtures
        .where((f) => f.round == 2)
        .firstOrNull;

    CupMatchSlot slot(MatchFixture fixture) {
      return CupMatchSlot(
        fixture: fixture,
        winnerId: fixture.isPlayed
            ? resolveCupWinner(fixture: fixture, registry: session.registry)
            : null,
      );
    }

    return CupBracketSnapshot(
      semiFinals: semis.map(slot).toList(),
      finalMatch: finalFixture != null ? slot(finalFixture) : null,
      championId: session.cupWinner,
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) {
      return null;
    }
    return iterator.current;
  }
}
