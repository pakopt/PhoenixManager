import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/widgets/express_match_reveal.dart';
import 'package:phoenix_ui/src/widgets/match_pitch_view.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/widgets/match_stat_bar.dart';

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({
    required this.session,
    required this.output,
    this.expressMode = false,
    super.key,
  });

  final GameSession session;
  final MatchSimulationOutput output;
  final bool expressMode;

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _revealController;
  var _revealStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.expressMode) {
      _revealController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealStarted || _revealController == null) {
      return;
    }
    _revealStarted = true;
    if (!MediaQuery.disableAnimationsOf(context)) {
      _revealController!.forward();
    }
  }

  @override
  void dispose() {
    _revealController?.dispose();
    super.dispose();
  }

  bool get _useExpressReveal =>
      widget.expressMode &&
      _revealController != null &&
      !MediaQuery.disableAnimationsOf(context);

  @override
  Widget build(BuildContext context) {
    final result = widget.output.result;
    final home = widget.session.clubName(widget.output.fixture.homeClubId);
    final away = widget.session.clubName(widget.output.fixture.awayClubId);
    final isUserHome =
        widget.output.fixture.homeClubId == GameSession.userClubId;
    final isUserAway =
        widget.output.fixture.awayClubId == GameSession.userClubId;
    final userWon = (isUserHome && result.homeScore > result.awayScore) ||
        (isUserAway && result.awayScore > result.homeScore);
    final userDraw =
        result.homeScore == result.awayScore && (isUserHome || isUserAway);

    Widget? resultChip;
    if (isUserHome || isUserAway) {
      resultChip = Chip(
        avatar: Icon(
          userDraw
              ? Icons.horizontal_rule
              : userWon
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
          size: 16,
        ),
        label: Text(userDraw
            ? 'Empate'
            : userWon
                ? 'Vitória'
                : 'Derrota'),
      );
    }

    final highlights = result.highlights
        .take(widget.expressMode ? expressHighlightLimit : 10)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$home vs $away'),
        actions: [
          if (widget.expressMode)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.flash_on, size: 20),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
          _buildScoreSection(
            home: home,
            away: away,
            homeScore: result.homeScore,
            awayScore: result.awayScore,
            dateLabel: DateFormatUtil.gameDate(widget.output.fixture.date),
            resultChip: resultChip,
          ),
          const SizedBox(height: 16),
          _wrapSection(
            intervalStart: 0.28,
            intervalEnd: 0.58,
            child:
                MatchPitchView(output: widget.output, session: widget.session),
          ),
          const SizedBox(height: 16),
          _wrapSection(
            intervalStart: 0.35,
            intervalEnd: 0.62,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    MatchStatBar(
                      label: 'Posse',
                      homeValue: result.homeStats.possessionPct,
                      awayValue: result.awayStats.possessionPct,
                      formatter: (v) => '${v.round()}%',
                    ),
                    MatchStatBar(
                      label: 'Remates',
                      homeValue: result.homeStats.shots,
                      awayValue: result.awayStats.shots,
                    ),
                    MatchStatBar(
                      label: 'Enquadrados',
                      homeValue: result.homeStats.shotsOnTarget,
                      awayValue: result.awayStats.shotsOnTarget,
                    ),
                    MatchStatBar(
                      label: 'xG',
                      homeValue: result.homeStats.xg,
                      awayValue: result.awayStats.xg,
                      formatter: (v) => v.toStringAsFixed(2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (widget.expressMode) ...[
            _wrapSection(
              intervalStart: 0.42,
              intervalEnd: 0.58,
              child: Chip(
                avatar: const Icon(Icons.flash_on, size: 16),
                label: Text(
                  'Modo Express · top $expressHighlightLimit destaques',
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _wrapSection(
            intervalStart: 0.48,
            intervalEnd: 0.62,
            child: Text(
              widget.expressMode ? 'Destaques Express' : 'Destaques',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          if (_useExpressReveal)
            for (var i = 0; i < highlights.length; i++)
              ExpressHighlightTile(
                animation: _revealController!,
                index: i,
                line: highlights[i],
              )
          else
            for (final line in highlights)
              Card(
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
          if (!widget.expressMode && result.commentary.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Ver relato completo'),
                subtitle: Text('${result.commentary.length} momentos'),
                children: result.commentary
                    .map(
                      (line) => ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.circle,
                          size: 6,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        title: Text(
                          line,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildScoreSection({
    required String home,
    required String away,
    required int homeScore,
    required int awayScore,
    required String dateLabel,
    Widget? resultChip,
  }) {
    if (_useExpressReveal) {
      return ExpressAnimatedScoreboard(
        animation: _revealController!,
        homeName: home,
        awayName: away,
        homeScore: homeScore,
        awayScore: awayScore,
        dateLabel: dateLabel,
        resultChip: resultChip,
      );
    }

    return Semantics(
      label: 'Placar: $home $homeScore-$awayScore $away',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    home,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$homeScore - $awayScore',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Expanded(
                  child: Text(away,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              ],
            ),
            Text(dateLabel, style: Theme.of(context).textTheme.bodySmall),
            if (resultChip != null) ...[
              const SizedBox(height: 8),
              resultChip,
            ],
          ],
        ),
      ),
    );
  }

  Widget _wrapSection({
    required double intervalStart,
    required double intervalEnd,
    required Widget child,
  }) {
    if (!_useExpressReveal) {
      return child;
    }
    return ExpressRevealSection(
      animation: _revealController!,
      intervalStart: intervalStart,
      intervalEnd: intervalEnd,
      child: child,
    );
  }
}
