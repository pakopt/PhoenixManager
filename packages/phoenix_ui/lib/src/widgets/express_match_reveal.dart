import 'package:flutter/material.dart';

/// Anima filho num intervalo do controlador master [0..1].
class ExpressRevealSection extends StatelessWidget {
  const ExpressRevealSection({
    required this.animation,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
    this.slideOffset = 0.08,
    super.key,
  });

  final Animation<double> animation;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;
  final double slideOffset;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(intervalStart, intervalEnd, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, slideOffset),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Placar com pop elástico e contagem dos golos.
class ExpressAnimatedScoreboard extends StatelessWidget {
  const ExpressAnimatedScoreboard({
    required this.animation,
    required this.homeName,
    required this.awayName,
    required this.homeScore,
    required this.awayScore,
    required this.dateLabel,
    this.resultChip,
    super.key,
  });

  final Animation<double> animation;
  final String homeName;
  final String awayName;
  final int homeScore;
  final int awayScore;
  final String dateLabel;
  final Widget? resultChip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreAnim = CurvedAnimation(
      parent: animation,
      curve: const Interval(0, 0.45, curve: Curves.elasticOut),
    );
    final metaAnim = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
    );

    return Semantics(
      label: 'Placar: $homeName $homeScore-$awayScore $awayName',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    homeName,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ScaleTransition(
                    scale: scoreAnim,
                    child: _AnimatedScoreLine(
                      animation: scoreAnim,
                      homeScore: homeScore,
                      awayScore: awayScore,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(awayName, style: theme.textTheme.titleMedium),
                ),
              ],
            ),
            FadeTransition(
              opacity: metaAnim,
              child: Column(
                children: [
                  Text(dateLabel, style: theme.textTheme.bodySmall),
                  if (resultChip != null) ...[
                    const SizedBox(height: 8),
                    resultChip!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedScoreLine extends StatelessWidget {
  const _AnimatedScoreLine({
    required this.animation,
    required this.homeScore,
    required this.awayScore,
    this.style,
  });

  final Animation<double> animation;
  final int homeScore;
  final int awayScore;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value.clamp(0.0, 1.0);
        final home = (homeScore * t).round();
        final away = (awayScore * t).round();
        return Text('$home - $away', style: style);
      },
    );
  }
}

/// Highlight Express com entrada escalonada.
class ExpressHighlightTile extends StatelessWidget {
  const ExpressHighlightTile({
    required this.animation,
    required this.index,
    required this.line,
    super.key,
  });

  final Animation<double> animation;
  final int index;
  final String line;

  @override
  Widget build(BuildContext context) {
    final start = 0.52 + (index * 0.07).clamp(0.0, 0.35);
    final end = (start + 0.14).clamp(0.0, 1.0);

    return ExpressRevealSection(
      animation: animation,
      intervalStart: start,
      intervalEnd: end,
      slideOffset: 0.05,
      child: Card(
        margin: const EdgeInsets.only(bottom: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sports_soccer,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(line)),
            ],
          ),
        ),
      ),
    );
  }
}
