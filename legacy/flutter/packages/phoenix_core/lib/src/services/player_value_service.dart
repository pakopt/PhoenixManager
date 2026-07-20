import 'package:phoenix_core/src/domain/club.dart';
import 'package:phoenix_core/src/domain/player.dart';
import 'package:phoenix_core/src/services/squad_query_service.dart';

/// Single source for player market value — Regra de Ouro #1.
class PlayerValueService {
  const PlayerValueService();

  int calculate(Player player, {Club? club, SquadQueryService? squad}) {
    final abilityFactor = player.currentAbility * 10000;
    final potentialBonus =
        (player.potentialAbility - player.currentAbility).clamp(0, 30) * 5000;
    final ageFactor = _ageMultiplier(player.age);
    final moraleFactor = 1 + (player.morale - 50) / 200;
    final clubRepBonus = club != null ? club.reputation * 1000 : 0;

    return ((abilityFactor + potentialBonus + clubRepBonus) *
            ageFactor *
            moraleFactor)
        .round()
        .clamp(50000, 200000000);
  }

  double _ageMultiplier(int age) {
    if (age <= 21) {
      return 1.2;
    }
    if (age <= 27) {
      return 1.0;
    }
    if (age <= 32) {
      return 0.75;
    }
    return 0.4;
  }
}
