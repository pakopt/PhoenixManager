import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';

class ClubHeader extends StatelessWidget {
  const ClubHeader({required this.session, super.key});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final club = session.userClub;
    final finance = session.userFinance;
    final theme = Theme.of(context);
    final city = session.registry.cities[club.cityId];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PhoenixColors.seed.withValues(alpha: 0.18),
            PhoenixColors.card,
          ],
        ),
        border: Border.all(
          color: PhoenixColors.seed.withValues(alpha: 0.28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClubCrest(club: club, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PhoenixColors.textPrimary,
                    ),
                  ),
                  Text(
                    [
                      if (city != null) city.name,
                      DateFormatUtil.gameDate(session.currentDate),
                      'Jornada ${session.tick}',
                    ].join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PhoenixColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (finance != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    MoneyFormat.compact(finance.balance),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: PhoenixColors.positive,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Orçamento',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PhoenixColors.muted,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  const StatChip({
    required this.label,
    required this.value,
    this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
