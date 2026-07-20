import 'package:flutter/material.dart';

/// Side-by-side stat comparison for match detail (home vs away).
class MatchStatBar extends StatelessWidget {
  const MatchStatBar({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    this.formatter,
    super.key,
  });

  final String label;
  final num homeValue;
  final num awayValue;
  final String Function(num value)? formatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = homeValue + awayValue;
    final homeFraction =
        total <= 0 ? 0.5 : (homeValue / total).clamp(0.05, 0.95);
    final homeText = formatter?.call(homeValue) ?? homeValue.toString();
    final awayText = formatter?.call(awayValue) ?? awayValue.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  homeText,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  awayText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: (homeFraction * 100).round(),
                    child: ColoredBox(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    flex: ((1 - homeFraction) * 100).round().clamp(1, 100),
                    child: ColoredBox(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
