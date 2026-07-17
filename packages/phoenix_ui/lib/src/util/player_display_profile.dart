import 'package:phoenix_core/phoenix_core.dart';

/// Perfil de apresentação (posição / pé / altura / atributos) derivado do jogador.
class PlayerDisplayProfile {
  const PlayerDisplayProfile({
    required this.position,
    required this.positionLabel,
    required this.preferredFoot,
    required this.heightCm,
    required this.attributes,
  });

  final String position;
  final String positionLabel;
  final String preferredFoot;
  final int heightCm;
  final List<PlayerAttribute> attributes;

  factory PlayerDisplayProfile.from(Player player) {
    const roles = [
      ('GR', 'Guarda-redes'),
      ('DF', 'Defesa'),
      ('MD', 'Médio'),
      ('MO', 'Médio ofensivo'),
      ('PL', 'Ponta de lança'),
      ('EX', 'Extremo'),
    ];
    final role = roles[Object.hash(player.id.value, 'role').abs() % roles.length];
    final rightFoot = Object.hash(player.id.value, 'foot').isEven;
    final height = 170 + (Object.hash(player.id.value, 'h').abs() % 21);

    int attr(String key, [int bias = 0]) {
      const spread = 14;
      final delta =
          (Object.hash(player.id.value, key).abs() % (spread * 2 + 1)) - spread;
      return (player.currentAbility + delta + bias).clamp(35, 99);
    }

    return PlayerDisplayProfile(
      position: role.$1,
      positionLabel: role.$2,
      preferredFoot: rightFoot ? 'Pé direito' : 'Pé esquerdo',
      heightCm: height,
      attributes: [
        PlayerAttribute('Ritmo', attr('pace', role.$1 == 'EX' ? 4 : 0)),
        PlayerAttribute(
          'Finalização',
          attr('fin', role.$1 == 'PL' ? 6 : -2),
        ),
        PlayerAttribute(
          'Passe',
          attr('pass', role.$1 == 'MD' || role.$1 == 'MO' ? 4 : 0),
        ),
        PlayerAttribute('Técnica', attr('tec')),
        PlayerAttribute('Físico', attr('phy', role.$1 == 'DF' ? 3 : 0)),
        PlayerAttribute(
          'Defesa',
          attr('def', role.$1 == 'DF' || role.$1 == 'GR' ? 6 : -4),
        ),
        PlayerAttribute('Posicionamento', attr('pos')),
      ],
    );
  }
}

class PlayerAttribute {
  const PlayerAttribute(this.label, this.value);
  final String label;
  final int value;
}
