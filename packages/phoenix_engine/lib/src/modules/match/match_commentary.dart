import 'package:phoenix_core/phoenix_core.dart';

/// Generates event-driven commentary from segment chains.
class MatchCommentaryGenerator {
  String forSegment({
    required MatchSegment segment,
    required ClubId homeClubId,
    required ClubId awayClubId,
    required String homeName,
    required String awayName,
    required bool goalScored,
  }) {
    if (segment.events.isEmpty) {
      return '${segment.startMinute}\' — Jogo equilibrado no meio-campo.';
    }

    final attackingTeam = segment.possessionTeamId;
    final teamName = _teamName(attackingTeam, homeClubId, homeName, awayName);

    if (goalScored) {
      return '${segment.endMinute}\' — GOLO! $teamName marca após ${segment.events.length} acções!';
    }

    final last = segment.events.last;
    return switch (last.type) {
      MatchEventType.shot => '${segment.endMinute}\' — Remate de $teamName (${_xgLabel(last.xg)}).',
      MatchEventType.save => '${segment.endMinute}\' — Grande defesa do guarda-redes face a $teamName.',
      MatchEventType.corner => '${segment.endMinute}\' — Canto para $teamName.',
      MatchEventType.foul => '${segment.endMinute}\' — Falta sobre $teamName.',
      MatchEventType.card => '${segment.endMinute}\' — Cartão amarelo para $teamName.',
      MatchEventType.miss => '${segment.endMinute}\' — $teamName falha grande oportunidade!',
      _ => '${segment.endMinute}\' — $teamName controla o segmento.',
    };
  }

  String _teamName(ClubId id, ClubId homeId, String home, String away) {
    return id == homeId ? home : away;
  }

  String _xgLabel(double? xg) {
    if (xg == null) {
      return 'xG n/a';
    }
    return 'xG ${xg.toStringAsFixed(2)}';
  }
}
