import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/achievements_panel.dart';
import 'package:phoenix_ui/src/screens/honours_panel.dart';
import 'package:phoenix_ui/src/screens/staff_panel.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/coach_labels.dart';
import 'package:phoenix_ui/src/widgets/common_widgets.dart';
import 'package:phoenix_ui/src/widgets/career_stats_card.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({
    required this.session,
    this.initialTab = 0,
    super.key,
  });

  final GameSession session;
  final int initialTab;

  static const tabCount = 4;

  @override
  Widget build(BuildContext context) {
    final tab = initialTab.clamp(0, tabCount - 1);

    return DefaultTabController(
      length: tabCount,
      initialIndex: tab,
      child: Column(
        children: [
          Material(
            color: PhoenixColors.headerBar,
            child: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Clube', icon: Icon(Icons.shield)),
                Tab(text: 'Staff', icon: Icon(Icons.groups)),
                Tab(text: 'Palmarés', icon: Icon(Icons.emoji_events)),
                Tab(text: 'Conquistas', icon: Icon(Icons.military_tech)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ClubOverviewPanel(session: session),
                StaffPanel(session: session),
                HonoursPanel(session: session),
                AchievementsPanel(session: session),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubOverviewPanel extends StatelessWidget {
  const _ClubOverviewPanel({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final club = session.userClub;
    final coach = session.userCoach;
    final finance = session.userFinance;
    final city = session.registry.cities[club.cityId];
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        children: [
          const ScreenPageHeader(
            title: 'Clube',
            subtitle: 'Identidade, staff e conquistas',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          ClubHeader(session: session),
          const SizedBox(height: 16),
          CareerStatsCard(session: session),
          const SizedBox(height: 16),
          Text('Treinador principal', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (coach != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: PhoenixColors.seed,
                      child: Text(
                        coach.name.characters.first,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coach.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(coach.licenseLabel),
                          Text(
                            coach.personality.labelPt,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Semantics(
                          label: 'Reputação: ${coach.reputation}',
                          excludeSemantics: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${coach.reputation}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Reputação',
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            const Card(
              child: EmptyState(
                icon: Icons.sports,
                message: 'Sem treinador atribuído.\nContrata staff na secção Staff.',
              ),
            ),
          const SizedBox(height: 16),
          Text('Infraestruturas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfraTile(
                icon: Icons.stadium,
                label: 'Estádio',
                value: '${club.stadiumCapacity} lugares',
              ),
              const SizedBox(width: 8),
              _InfraTile(
                icon: Icons.school,
                label: 'Academia',
                value: 'Nível ${finance?.academyLevel ?? 2}',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfraTile(
                icon: Icons.location_city,
                label: 'Cidade',
                value: city?.name ?? club.cityId.value,
              ),
              const SizedBox(width: 8),
              _InfraTile(
                icon: Icons.emoji_events,
                label: 'Reputação',
                value: '${club.reputation}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (session.leagueTitlesWon > 0 || session.cupTitlesWon > 0) ...[
            Text('Palmarés', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfraTile(
                  icon: Icons.leaderboard,
                  label: 'Ligas',
                  value: '${session.leagueTitlesWon}',
                ),
                const SizedBox(width: 8),
                _InfraTile(
                  icon: Icons.emoji_events,
                  label: 'Taças',
                  value: '${session.cupTitlesWon}',
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Text('Estado médico', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.medical_services,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${session.injuredPlayers.length} lesionados · '
                          '${session.fitPlayers.length} disponíveis',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Staff médico reduz dias de lesão. '
                    'Lesionados não evoluem em treino.',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (session.injuredPlayers.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...session.injuredPlayers.map(
                      (p) => Semantics(
                        label:
                            '${p.name}, ${p.injuredDaysRemaining} dias de lesão',
                        excludeSemantics: true,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.healing, size: 18),
                          title: Text(p.name),
                          trailing: Text('${p.injuredDaysRemaining} dias'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfraTile extends StatelessWidget {
  const _InfraTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
