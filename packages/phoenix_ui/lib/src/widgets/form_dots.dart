import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/recent_form.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';

/// Pontos V/E/D compactos (coluna direita / resumos).
class FormDots extends StatelessWidget {
  const FormDots({
    required this.session,
    this.limit = 5,
    this.showLabels = true,
    super.key,
  });

  final GameSession session;
  final int limit;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final entries = session.recentForm(limit: limit);
    if (entries.isEmpty) {
      return Text(
        'Sem jogos',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PhoenixColors.muted,
            ),
      );
    }

    return Row(
      children: [
        for (final entry in entries.reversed) ...[
          _Dot(outcome: entry.outcome, showLabel: showLabels),
          const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.outcome, required this.showLabel});

  final MatchOutcome outcome;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final (color, label, semantics) = switch (outcome) {
      MatchOutcome.win => (PhoenixColors.positive, 'V', 'Vitória'),
      MatchOutcome.draw => (PhoenixColors.draw, 'E', 'Empate'),
      MatchOutcome.loss => (PhoenixColors.negative, 'D', 'Derrota'),
    };

    return Semantics(
      label: semantics,
      child: Container(
        width: showLabel ? 26 : 12,
        height: showLabel ? 26 : 12,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(showLabel ? 6 : 99),
        ),
        child: showLabel
            ? Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              )
            : null,
      ),
    );
  }
}
