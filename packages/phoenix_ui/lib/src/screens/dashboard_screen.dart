import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/game/season_summary.dart';
import 'package:phoenix_ui/src/screens/match_detail_screen.dart';
import 'package:phoenix_ui/src/widgets/achievement_progress_card.dart';
import 'package:phoenix_ui/src/widgets/career_stats_card.dart';
import 'package:phoenix_ui/src/widgets/common_widgets.dart';
import 'package:phoenix_ui/src/widgets/cup_status_card.dart';
import 'package:phoenix_ui/src/widgets/express_match_transition.dart';
import 'package:phoenix_ui/src/widgets/form_strip.dart';
import 'package:phoenix_ui/src/widgets/season_summary_card.dart';
import 'package:phoenix_ui/src/util/date_format.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.controller,
    this.onOpenAchievements,
    super.key,
  });

  final GameController controller;
  final VoidCallback? onOpenAchievements;

  @override
  Widget build(BuildContext context) {
    final session = controller.session!;
    final next = session.nextFixture;
    final userStanding = session.standings.indexWhere(
      (e) => e.clubId == GameSession.userClubId,
    );
    final seasonSummary = SeasonSummary.fromSession(session);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClubHeader(session: session),
          const SizedBox(height: 16),
          Row(
            children: [
              StatChip(
                label: 'Posição',
                value: userStanding >= 0 ? '${userStanding + 1}º' : '—',
              ),
              const SizedBox(width: 8),
              StatChip(
                label: 'Jogos',
                value: '${session.matchesPlayed}/${session.allFixtures.length}',
              ),
              const SizedBox(width: 8),
              StatChip(
                label: 'Plantel',
                value: '${session.squad.length}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          CareerStatsCard(session: session, compact: true),
          const SizedBox(height: 16),
          AchievementProgressCard(
            session: session,
            onTap: onOpenAchievements,
          ),
          const SizedBox(height: 16),
          FormStrip(session: session),
          const SizedBox(height: 16),
          if (seasonSummary != null) ...[
            SeasonSummaryCard(session: session, summary: seasonSummary),
            const SizedBox(height: 16),
          ],
          _StatusOverview(session: session),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Próximo jogo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (next != null) ...[
                    Text(
                      '${session.clubName(next.homeClubId)} vs '
                      '${session.clubName(next.awayClubId)} · ${next.date}',
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.competitionName(next.competitionId) +
                          (next.competitionId == GameSession.cupCompetitionId
                              ? ' · ${session.cupRoundLabel(next)}'
                              : ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ] else if (session.isFullSeasonComplete)
                    const Text('Época concluída (liga e taça)')
                  else if (session.isSeasonComplete)
                    const Text('Liga concluída · taça em curso')
                  else
                    const Text('Sem jogos agendados'),
                  const SizedBox(height: 16),
                  if (session.isFullSeasonComplete)
                    FilledButton.icon(
                      onPressed: () => _startNextSeason(context),
                      icon: const Icon(Icons.restart_alt),
                      label: Text('Iniciar época ${session.seasonYear + 1}'),
                    )
                  else if (controller.playMode == PlayMode.express)
                    FilledButton.icon(
                      onPressed: session.isFullSeasonComplete
                          ? null
                          : () {
                              UiFeedback.action();
                              _simulateExpressRound(context);
                            },
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Simular jornada (Express)'),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: session.isFullSeasonComplete
                              ? null
                              : () {
                                  UiFeedback.tap();
                                  controller.advanceDay();
                                },
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Avançar 1 dia'),
                        ),
                        OutlinedButton.icon(
                          onPressed: session.isFullSeasonComplete
                              ? null
                              : () {
                                  UiFeedback.tap();
                                  controller.advanceWeek();
                                },
                          icon: const Icon(Icons.date_range),
                          label: const Text('Avançar 1 semana'),
                        ),
                        if (next != null && !session.isFullSeasonComplete)
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CupStatusCard(session: session),
          const SizedBox(height: 16),
          if (session.getUserMatchOnDate(session.currentDate) != null) ...[
            Text('Jogo de hoje', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _TodayMatchCard(
              controller: controller,
              output: session.getUserMatchOnDate(session.currentDate)!,
            ),
            const SizedBox(height: 16),
          ],
          Text('Eventos recentes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (session.recentEvents.isEmpty)
            const EmptyState(
              icon: Icons.history,
              message:
                  'Ainda sem eventos. Avança dias ou simula jogos para ver o feed.',
            )
          else
            ...session.recentEvents.map(
              (event) => _EventTile(event: event, session: session),
            ),
        ],
      ),
    );
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
        content: Text(
          'Época ${controller.session!.seasonYear} iniciada',
        ),
      ),
    );
  }
}

class _StatusOverview extends StatelessWidget {
  const _StatusOverview({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final finance = session.userFinance;
    final breakdown = session.salaryBreakdown;
    final injured = session.injuredPlayers;
    final expiring = session.expiringContractsThisSeason;
    final soon = session.contractsExpiringSoon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (finance != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Finanças rápidas', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          label: 'Saldo',
                          value: MoneyFormat.compact(finance.balance),
                        ),
                      ),
                      Expanded(
                        child: _MiniStat(
                          label: 'Salários/mês',
                          value: MoneyFormat.compact(breakdown.total),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jogadores ${MoneyFormat.compact(breakdown.players)} · '
                    'Staff ${MoneyFormat.compact(breakdown.staff)} · '
                    'Treinador ${MoneyFormat.compact(breakdown.coach)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (injured.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.healing, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Lesionados (${injured.length})',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...injured.take(3).map(
                        (p) => Text(
                          '${p.name} · ${p.injuredDaysRemaining} dias',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
        if (session.hasContractAlerts) ...[
          const SizedBox(height: 8),
          Card(
            color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.35),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.assignment_late,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contratos',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Época ${session.seasonYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (expiring.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Expiram esta época (${expiring.length})',
                      style: theme.textTheme.labelMedium,
                    ),
                    ...expiring.take(3).map(
                          (p) => Text(
                            '${p.name} · ${p.contractEndYear}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                  ],
                  if (soon.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Expiram na próxima época (${soon.length})',
                      style: theme.textTheme.labelMedium,
                    ),
                    ...soon.take(3).map(
                          (p) => Text(
                            '${p.name} · ${p.contractEndYear}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
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
    return Card(
      child: ListTile(
        title: Text(
          '${session.clubName(output.fixture.homeClubId)} '
          '${output.result.homeScore}-${output.result.awayScore} '
          '${session.clubName(output.fixture.awayClubId)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
      leading: Icon(_iconFor(event), size: 18),
      title: Text(_labelFor(event), style: Theme.of(context).textTheme.bodySmall),
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
        '${session.clubName(e.homeClubId)} ${e.homeScore}-${e.awayScore} '
        '${session.clubName(e.awayClubId)}',
      TransferCompletedEvent e =>
        '${e.playerName} → ${session.clubName(e.record.toClubId)}',
      YouthIntakeEvent e =>
        '${session.clubName(e.clubId)}: ${e.players.length} jovens',
      PlayerInjuredEvent e =>
        '${e.playerName} lesionado (${e.daysOut} dias)',
      PlayerRecoveredEvent e => '${e.playerName} recuperado',
      ContractRenewedEvent e =>
        '${e.playerName} renovado até ${e.newContractEndYear} '
        '(€${e.newSalary}/m)',
      AchievementUnlockedEvent e =>
        'Conquista: ${session.achievementTitle(e.achievementId)}',
      SeasonFinishedEvent e =>
        '${session.competitionName(e.competitionId)} · época ${e.seasonYear} terminada',
      NewSeasonStartedEvent e =>
        'Nova época ${e.seasonYear} · início ${e.startDate}',
      SalariesPaidEvent e =>
        'Salários ${session.clubName(e.clubId)}: €${e.amount}',
      TicketRevenueEvent e =>
        'Bilheteira ${session.clubName(e.clubId)}: €${e.amount}',
      DayAdvancedEvent e => 'Dia ${DateFormatUtil.gameDate(e.currentDate)}',
      _ => 'Actualização do clube',
    };
  }
}
