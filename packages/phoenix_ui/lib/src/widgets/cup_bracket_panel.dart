import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/cup_bracket_snapshot.dart';
import 'package:phoenix_ui/src/game/game_session.dart';

class CupBracketPanel extends StatelessWidget {
  const CupBracketPanel({
    required this.session,
    required this.bracket,
    this.onMatchTap,
    super.key,
  });

  final GameSession session;
  final CupBracketSnapshot bracket;
  final void Function(MatchFixture fixture)? onMatchTap;

  @override
  Widget build(BuildContext context) {
    if (bracket.semiFinals.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chave eliminatória',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (wide)
                  _WideBracket(
                    session: session,
                    bracket: bracket,
                    onMatchTap: onMatchTap,
                  )
                else
                  _NarrowBracket(
                    session: session,
                    bracket: bracket,
                    onMatchTap: onMatchTap,
                  ),
                if (bracket.championId != null) ...[
                  const SizedBox(height: 16),
                  _ChampionBanner(
                    session: session,
                    championId: bracket.championId!,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WideBracket extends StatelessWidget {
  const _WideBracket({
    required this.session,
    required this.bracket,
    this.onMatchTap,
  });

  final GameSession session;
  final CupBracketSnapshot bracket;
  final void Function(MatchFixture fixture)? onMatchTap;

  @override
  Widget build(BuildContext context) {
    final semi1 = bracket.semiFinals.isNotEmpty ? bracket.semiFinals[0] : null;
    final semi2 = bracket.semiFinals.length > 1 ? bracket.semiFinals[1] : null;
    final finalMatch = bracket.finalMatch;

    return SizedBox(
      height: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (semi1 != null)
                  _BracketMatchCard(
                    session: session,
                    slot: semi1,
                    label: 'Meia-final 1',
                    onTap: onMatchTap,
                  ),
                if (semi2 != null)
                  _BracketMatchCard(
                    session: session,
                    slot: semi2,
                    label: 'Meia-final 2',
                    onTap: onMatchTap,
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: CustomPaint(
              painter: _WideBracketLinesPainter(
                color: Theme.of(context).dividerColor,
                hasFinal: finalMatch != null,
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (finalMatch != null)
                  _BracketMatchCard(
                    session: session,
                    slot: finalMatch,
                    label: 'Final',
                    onTap: onMatchTap,
                    emphasized: true,
                  )
                else
                  _PendingFinalCard(
                    session: session,
                    semiFinals: bracket.semiFinals,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NarrowBracket extends StatelessWidget {
  const _NarrowBracket({
    required this.session,
    required this.bracket,
    this.onMatchTap,
  });

  final GameSession session;
  final CupBracketSnapshot bracket;
  final void Function(MatchFixture fixture)? onMatchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < bracket.semiFinals.length; i++) ...[
          _BracketMatchCard(
            session: session,
            slot: bracket.semiFinals[i],
            label: 'Meia-final ${i + 1}',
            onTap: onMatchTap,
          ),
          if (i < bracket.semiFinals.length - 1) const _BracketConnector(),
        ],
        const _BracketConnector(),
        if (bracket.finalMatch != null)
          _BracketMatchCard(
            session: session,
            slot: bracket.finalMatch!,
            label: 'Final',
            onTap: onMatchTap,
            emphasized: true,
          )
        else
          _PendingFinalCard(
            session: session,
            semiFinals: bracket.semiFinals,
          ),
      ],
    );
  }
}

class _BracketConnector extends StatelessWidget {
  const _BracketConnector();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Center(
        child: Container(
          width: 2,
          height: 20,
          color: Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}

class _PendingFinalCard extends StatelessWidget {
  const _PendingFinalCard({
    required this.session,
    required this.semiFinals,
  });

  final GameSession session;
  final List<CupMatchSlot> semiFinals;

  @override
  Widget build(BuildContext context) {
    final allSemisPlayed =
        semiFinals.isNotEmpty && semiFinals.every((s) => s.isPlayed);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Final',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            allSemisPlayed
                ? 'A aguardar sorteio da final…'
                : 'Disponível após as meias-finais',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BracketMatchCard extends StatelessWidget {
  const _BracketMatchCard({
    required this.session,
    required this.slot,
    required this.label,
    this.onTap,
    this.emphasized = false,
  });

  final GameSession session;
  final CupMatchSlot slot;
  final String label;
  final void Function(MatchFixture fixture)? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final fixture = slot.fixture;
    final canTap = slot.isPlayed && onTap != null;
    final borderColor = emphasized
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
        : Theme.of(context).dividerColor;

    return Material(
      color: emphasized
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
          : Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: canTap ? () => onTap!(fixture) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  Text(
                    _formatDate(fixture.date),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _TeamRow(
                name: session.clubName(fixture.homeClubId),
                score: fixture.homeScore,
                isWinner: slot.winnerId == fixture.homeClubId,
                isUserClub: fixture.homeClubId == GameSession.userClubId,
                isPlayed: slot.isPlayed,
              ),
              const Divider(height: 12),
              _TeamRow(
                name: session.clubName(fixture.awayClubId),
                score: fixture.awayScore,
                isWinner: slot.winnerId == fixture.awayClubId,
                isUserClub: fixture.awayClubId == GameSession.userClubId,
                isPlayed: slot.isPlayed,
              ),
              if (canTap) ...[
                const SizedBox(height: 6),
                Text(
                  'Ver relatório',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(GameDate date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.name,
    required this.score,
    required this.isWinner,
    required this.isUserClub,
    required this.isPlayed,
  });

  final String name;
  final int? score;
  final bool isWinner;
  final bool isUserClub;
  final bool isPlayed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: isWinner ? FontWeight.w700 : FontWeight.w500,
      color: isUserClub
          ? theme.colorScheme.primary
          : theme.textTheme.bodyMedium?.color,
    );

    return Row(
      children: [
        if (isPlayed && isWinner)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Icon(
              Icons.check_circle,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          )
        else if (isPlayed)
          const SizedBox(width: 22),
        Expanded(child: Text(name, style: nameStyle, overflow: TextOverflow.ellipsis)),
        if (isPlayed)
          Text(
            '${score ?? 0}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
            ),
          )
        else
          Text('—', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _ChampionBanner extends StatelessWidget {
  const _ChampionBanner({
    required this.session,
    required this.championId,
  });

  final GameSession session;
  final ClubId championId;

  @override
  Widget build(BuildContext context) {
    final isUser = championId == GameSession.userClubId;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campeão da Taça',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(
                  session.clubName(championId),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          if (isUser)
            Chip(
              label: const Text('O teu clube'),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

class _WideBracketLinesPainter extends CustomPainter {
  _WideBracketLinesPainter({
    required this.color,
    required this.hasFinal,
  });

  final Color color;
  final bool hasFinal;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final midX = size.width / 2;
    final topY = size.height * 0.22;
    final bottomY = size.height * 0.78;
    final centerY = size.height * 0.5;

    // Semi 1 → merge point
    canvas.drawLine(Offset(0, topY), Offset(midX, topY), paint);
    canvas.drawLine(Offset(midX, topY), Offset(midX, centerY), paint);

    // Semi 2 → merge point
    canvas.drawLine(Offset(0, bottomY), Offset(midX, bottomY), paint);
    canvas.drawLine(Offset(midX, bottomY), Offset(midX, centerY), paint);

    // Merge → final
    canvas.drawLine(Offset(midX, centerY), Offset(size.width, centerY), paint);
  }

  @override
  bool shouldRepaint(covariant _WideBracketLinesPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.hasFinal != hasFinal;
}
