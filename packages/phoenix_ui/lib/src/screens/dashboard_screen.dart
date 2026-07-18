import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/match_fixture_extensions.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/game/season_summary.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/achievement_progress_card.dart';
import 'package:phoenix_ui/src/widgets/career_stats_card.dart';
import 'package:phoenix_ui/src/widgets/cup_status_card.dart';
import 'package:phoenix_ui/src/widgets/dashboard_tip_card.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/express_match_transition.dart';
import 'package:phoenix_ui/src/widgets/fixture_list_tile.dart';
import 'package:phoenix_ui/src/widgets/form_dots.dart';
import 'package:phoenix_ui/src/widgets/match_day_hero.dart';
import 'package:phoenix_ui/src/widgets/mini_standings.dart';
import 'package:phoenix_ui/src/widgets/season_summary_card.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.controller,
    this.onOpenAchievements,
    this.onOpenStandings,
    this.onOpenFixtures,
    this.onOpenFinances,
    this.onOpenSquad,
    super.key,
  });

  final GameController controller;
  final VoidCallback? onOpenAchievements;
  final VoidCallback? onOpenStandings;
  final VoidCallback? onOpenFixtures;
  final VoidCallback? onOpenFinances;
  final VoidCallback? onOpenSquad;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1100;
    final seasonSummary = SeasonSummary.fromSession(session);

    final center = _buildCenter(context, session, seasonSummary);
    final right = _buildRight(context, session);
    // Em desktop largo o painel direito cresce um pouco com a janela.
    final rightWidth = wide
        ? (width * 0.26).clamp(320.0, 420.0)
        : 320.0;

    return SafeArea(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 16, 24),
                    children: center,
                  ),
                ),
                SizedBox(
                  width: rightWidth,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(8, 16, 24, 24),
                    children: right,
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                ...center,
                const SizedBox(height: 8),
                ...right,
              ],
            ),
    );
  }

  List<Widget> _buildCenter(
    BuildContext context,
    GameSession session,
    SeasonSummary? seasonSummary,
  ) {
    final next = session.nextFixture;
    final upcoming = session.upcomingFixtures
        .where((f) => f.involvesClub(GameSession.userClubId))
        .take(5)
        .toList();
    final recent = session.recentForm(limit: 5);

    return _spaced([
      MatchDayHero(
        session: session,
        onGoToMatch: next == null || session.isFullSeasonComplete
            ? null
            : () {
                UiFeedback.action();
                if (controller.playMode == PlayMode.express) {
                  _simulateExpressRound(context);
                } else {
                  controller.advanceToNextMatch();
                }
              },
        ctaLabel: controller.playMode == PlayMode.express
            ? 'Simular jornada'
            : 'Ir ao jogo',
      ),
      _AdvanceControls(
        controller: controller,
        onExpress: () => _simulateExpressRound(context),
        onStartNextSeason: () => _startNextSeason(context),
      ),
      if (controller.playMode == PlayMode.director &&
          next != null &&
          !session.isFullSeasonComplete)
        _PreMatchAlertCard(session: session),
      SectionCard(
        title: 'Próximos jogos',
        trailing: onOpenFixtures == null
            ? null
            : TextButton(
                onPressed: onOpenFixtures,
                child: const Text('Calendário'),
              ),
        child: upcoming.isEmpty
            ? const Text(
                'Sem jogos agendados.',
                style: TextStyle(color: PhoenixColors.muted),
              )
            : Column(
                children: [
                  for (final fixture in upcoming)
                    FixtureListTile(
                      fixture: fixture,
                      session: session,
                      dense: true,
                    ),
                ],
              ),
      ),
      SectionCard(
        title: 'Resultados recentes',
        child: recent.isEmpty
            ? const Text(
                'Ainda sem jogos disputados.',
                style: TextStyle(color: PhoenixColors.muted),
              )
            : Column(
                children: [
                  FormDots(session: session, limit: 5),
                  const SizedBox(height: 12),
                  for (final entry in recent)
                    FixtureListTile(
                      fixture: entry.fixture,
                      session: session,
                      dense: true,
                      onTap: () {
                        final result =
                            session.registry.matchResults[entry.fixture.id];
                        if (result == null) {
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MatchDetailScreen(
                              session: session,
                              output: MatchSimulationOutput(
                                fixture: entry.fixture,
                                result: result,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
      DashboardTipCard(
        playMode: controller.playMode,
        matchesPlayed: session.matchesPlayed,
      ),
      if (seasonSummary != null)
        SeasonSummaryCard(session: session, summary: seasonSummary),
      CupStatusCard(session: session),
      if (session.getUserMatchOnDate(session.currentDate) != null)
        _TodayMatchCard(
          controller: controller,
          output: session.getUserMatchOnDate(session.currentDate)!,
        ),
      SectionCard(
        title: 'Eventos recentes',
        child: session.recentEvents.isEmpty
            ? const EmptyState(
                icon: Icons.history,
                message:
                    'Ainda sem eventos. Avança dias ou simula jogos para ver o feed.',
              )
            : Column(
                children: [
                  for (final event in session.recentEvents.take(8))
                    _EventTile(event: event, session: session),
                ],
              ),
      ),
    ]);
  }

  List<Widget> _buildRight(BuildContext context, GameSession session) {
    final finance = session.userFinance;
    final injured = session.injuredPlayers;
    final userStanding = session.standings.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );

    return _spaced([
      MiniStandings(session: session, onOpenFull: onOpenStandings),
      SectionCard(
        title: 'Forma',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormDots(session: session),
            const SizedBox(height: 8),
            Text(
              userStanding >= 0
                  ? '${userStanding + 1}º · ${session.matchesPlayed} jogos'
                  : '${session.matchesPlayed} jogos',
              style: const TextStyle(color: PhoenixColors.muted, fontSize: 12),
            ),
          ],
        ),
      ),
      SectionCard(
        title: 'Plantel',
        trailing: onOpenSquad == null
            ? null
            : TextButton(onPressed: onOpenSquad, child: const Text('Ver')),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${session.squad.length} jogadores',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: PhoenixColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              injured.isEmpty
                  ? 'Sem lesionados'
                  : '${injured.length} lesionado${injured.length == 1 ? '' : 's'}',
              style: TextStyle(
                color:
                    injured.isEmpty ? PhoenixColors.muted : PhoenixColors.warning,
                fontSize: 13,
              ),
            ),
            if (injured.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final p in injured.take(3))
                Text(
                  '· ${p.name} (${p.injuredDaysRemaining}d)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: PhoenixColors.textSecondary,
                  ),
                ),
            ],
          ],
        ),
      ),
      if (finance != null)
        SectionCard(
          title: 'Finanças',
          trailing: onOpenFinances == null
              ? null
              : TextButton(
                  onPressed: onOpenFinances,
                  child: const Text('Abrir'),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MoneyFormat.compact(finance.balance),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: PhoenixColors.positive,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Salários ${MoneyFormat.compact(session.salaryBreakdown.total)}/mês',
                style: const TextStyle(
                  color: PhoenixColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      CareerStatsCard(session: session, compact: true),
      AchievementProgressCard(
        session: session,
        onTap: onOpenAchievements,
      ),
    ]);
  }

  Future<void> _simulateExpressRound(BuildContext context) async {
    final session = controller.session!;
    final output = controller.advanceExpressRound();
    if (output == null) {
      if (!context.mounted) {
        return;
      }
      final message = session.isFullSeasonComplete
          ? 'Época concluída — inicia a próxima época.'
          : session.nextFixture == null
              ? 'Não há jogos agendados neste momento.'
              : 'Não foi possível simular a jornada.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    await controller.saveGame();
    if (!context.mounted) {
      return;
    }
    await openExpressMatchScreen(
      context,
      MatchDetailScreen(
        session: controller.session!,
        output: output,
        expressMode: true,
      ),
    );
  }

  Future<void> _startNextSeason(BuildContext context) async {
    final error = controller.startNextSeason();
    if (error != null) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    await controller.saveGame();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Época ${controller.session!.seasonYear} iniciada'),
      ),
    );
  }
}

List<Widget> _spaced(List<Widget> children, {double gap = 16}) {
  final out = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    out.add(children[i]);
    if (i < children.length - 1) {
      out.add(SizedBox(height: gap));
    }
  }
  return out;
}

class _AdvanceControls extends StatelessWidget {
  const _AdvanceControls({
    required this.controller,
    required this.onExpress,
    required this.onStartNextSeason,
  });

  final GameController controller;
  final VoidCallback onExpress;
  final VoidCallback onStartNextSeason;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;

    return SectionCard(
      title: 'Avançar',
      child: session.isFullSeasonComplete
          ? FilledButton.icon(
              onPressed: onStartNextSeason,
              icon: const Icon(Icons.restart_alt),
              label: Text('Iniciar época ${session.seasonYear + 1}'),
            )
          : controller.playMode == PlayMode.express
              ? FilledButton.icon(
                  onPressed: onExpress,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Simular jornada (Express)'),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        UiFeedback.tap();
                        controller.advanceDay();
                      },
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Avançar 1 dia'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        UiFeedback.tap();
                        controller.advanceWeek();
                      },
                      icon: const Icon(Icons.date_range),
                      label: const Text('Avançar 1 semana'),
                    ),
                    if (session.nextFixture != null)
                      OutlinedButton.icon(
                        onPressed: () {
                          UiFeedback.tap();
                          controller.advanceToNextMatch();
                        },
                        icon: const Icon(Icons.sports_soccer),
                        label: const Text('Ir ao próximo jogo'),
                      ),
                  ],
                ),
    );
  }
}

class _PreMatchAlertCard extends StatelessWidget {
  const _PreMatchAlertCard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final injured = session.injuredPlayers;
    final expiring = session.expiringContractsThisSeason;
    if (injured.isEmpty && expiring.isEmpty) {
      return const SizedBox.shrink();
    }

    return SectionCard(
      title: 'Antes do próximo jogo',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (injured.isNotEmpty) ...[
            Text(
              'Lesionados (${injured.length})',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            ...injured.take(3).map(
                  (p) => Text(
                    '· ${p.name} (${p.injuredDaysRemaining} dias)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
          ],
          if (injured.isNotEmpty && expiring.isNotEmpty)
            const SizedBox(height: 8),
          if (expiring.isNotEmpty) ...[
            Text(
              'Contratos a expirar esta época (${expiring.length})',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            ...expiring.take(3).map(
                  (p) => Text(
                    '· ${p.name} (até ${p.contractEndYear})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _TodayMatchCard extends StatelessWidget {
  const _TodayMatchCard({
    required this.controller,
    required this.output,
  });

  final GameController controller;
  final MatchSimulationOutput output;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;
    final home = session.clubName(output.fixture.homeClubId);
    final away = session.clubName(output.fixture.awayClubId);
    final homeScore = output.result.homeScore;
    final awayScore = output.result.awayScore;
    return Card(
      child: ListTile(
        title: Semantics(
          label: '$home $homeScore a $awayScore $away',
          excludeSemantics: true,
          child: Text(
            '$home $homeScore-$awayScore $away',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: Text(
          'xG ${output.result.homeStats.xg.toStringAsFixed(2)} — '
          '${output.result.awayStats.xg.toStringAsFixed(2)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final screen = MatchDetailScreen(
            session: session,
            output: output,
            expressMode: controller.playMode == PlayMode.express,
          );
          if (controller.playMode == PlayMode.express) {
            await openExpressMatchScreen(context, screen);
          } else {
            await Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => screen),
            );
          }
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.session});

  final PhoenixEvent event;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(_iconFor(event), size: 18, color: PhoenixColors.muted),
      title: Text(
        _labelFor(event),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  IconData _iconFor(PhoenixEvent event) {
    return switch (event) {
      MatchPlayedEvent() => Icons.sports_soccer,
      TransferCompletedEvent() => Icons.swap_horiz,
      YouthIntakeEvent() => Icons.school,
      PlayerInjuredEvent() => Icons.healing,
      PlayerRecoveredEvent() => Icons.check_circle,
      ContractRenewedEvent() => Icons.assignment_turned_in,
      AchievementUnlockedEvent() => Icons.military_tech,
      SeasonFinishedEvent() => Icons.emoji_events,
      NewSeasonStartedEvent() => Icons.restart_alt,
      SalariesPaidEvent() => Icons.payments,
      TicketRevenueEvent() => Icons.confirmation_number,
      _ => Icons.notifications_none,
    };
  }

  String _labelFor(PhoenixEvent event) {
    return switch (event) {
      MatchPlayedEvent e =>
        '${session.clubName(e.homeClubId)} ${e.homeScore} a ${e.awayScore} '
            '${session.clubName(e.awayClubId)}',
      TransferCompletedEvent e =>
        '${e.playerName} → ${session.clubName(e.record.toClubId)}',
      YouthIntakeEvent e =>
        '${session.clubName(e.clubId)}: ${e.players.length} jovens',
      PlayerInjuredEvent e => '${e.playerName} lesionado (${e.daysOut} dias)',
      PlayerRecoveredEvent e => '${e.playerName} recuperado',
      ContractRenewedEvent e =>
        '${e.playerName} renovado até ${e.newContractEndYear} '
            '(${MoneyFormat.perMonth(e.newSalary)})',
      AchievementUnlockedEvent e =>
        'Conquista: ${session.achievementTitle(e.achievementId)}',
      SeasonFinishedEvent e =>
        '${session.competitionName(e.competitionId)} · época ${e.seasonYear} terminada',
      NewSeasonStartedEvent e =>
        'Nova época ${e.seasonYear} · início ${DateFormatUtil.gameDate(e.startDate)}',
      SalariesPaidEvent e =>
        'Salários ${session.clubName(e.clubId)}: ${MoneyFormat.compact(e.amount)}',
      TicketRevenueEvent e =>
        'Bilheteira ${session.clubName(e.clubId)}: ${MoneyFormat.compact(e.amount)}',
      DayAdvancedEvent e => 'Dia ${DateFormatUtil.gameDate(e.currentDate)}',
      _ => 'Actualização do clube',
    };
  }
}
