import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

/// Minimal 2D pitch — segment highlights as event markers.
class MatchPitchView extends StatelessWidget {
  const MatchPitchView({
    required this.output,
    required this.session,
    super.key,
  });

  final MatchSimulationOutput output;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: CustomPaint(
        painter: _PitchPainter(
          highlights: output.result.highlights.length,
          homeXg: output.result.homeStats.xg,
          awayXg: output.result.awayStats.xg,
          primaryColor: Theme.of(context).colorScheme.primary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                session.clubName(output.fixture.homeClubId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                session.clubName(output.fixture.awayClubId),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  _PitchPainter({
    required this.highlights,
    required this.homeXg,
    required this.awayXg,
    required this.primaryColor,
  });

  final int highlights;
  final double homeXg;
  final double awayXg;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final pitch = Paint()..color = const Color(0xFF2E7D32);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      pitch,
    );

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      line,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.12,
      line,
    );

    final marker = Paint()..color = primaryColor.withValues(alpha: 0.85);
    for (var i = 0; i < highlights.clamp(0, 8); i++) {
      final x = size.width * (0.15 + (i * 0.1) % 0.7);
      final y = size.height * (i.isEven ? 0.25 : 0.75);
      canvas.drawCircle(Offset(x, y), 5, marker);
    }

    final xgText = TextPainter(
      text: TextSpan(
        text: 'xG ${homeXg.toStringAsFixed(2)} — ${awayXg.toStringAsFixed(2)}',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    xgText.paint(canvas, Offset(8, size.height - 18));
  }

  @override
  bool shouldRepaint(covariant _PitchPainter oldDelegate) => false;
}
