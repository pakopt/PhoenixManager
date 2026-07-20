import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/screens/achievements_panel.dart';
import 'package:phoenix_ui/src/screens/club_detail_screen.dart';
import 'package:phoenix_ui/src/screens/honours_panel.dart';
import 'package:phoenix_ui/src/screens/staff_panel.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/coach_labels.dart';
import 'package:phoenix_ui/src/widgets/common_widgets.dart';
import 'package:phoenix_ui/src/widgets/career_stats_card.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';
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
    final peerClubsWithTeams = session.registry.clubs.values
        .where((c) => c.id != GameSession.userClubId && c.teams.isNotEmpty)
        .toList();

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
          _ClubIdentityCard(session: session),
          for (final peer in peerClubsWithTeams) ...[
            const SizedBox(height: 16),
            _ClubTeamsCard(
              club: peer,
              onOpen: () => ClubDetailScreen.open(
                context,
                session: session,
                clubId: peer.id,
              ),
            ),
          ],
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

class _ClubIdentityCard extends StatelessWidget {
  const _ClubIdentityCard({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final club = session.userClub;
    final city = session.registry.cities[club.cityId];
    final region = city != null ? session.registry.regions[city.regionId] : null;
    final country =
        region != null ? session.registry.countries[region.countryId] : null;

    final rows = <(String, String)>[
      if (club.foundedOn != null)
        ('Fundação', formatClubFoundedDate(club.foundedOn!)),
      if (city != null) ('Cidade', city.name),
      if (country != null) ('País', country.name),
      if (club.association != null) ('Associação', club.association!),
      if (club.president != null) ('Presidente', club.president!),
      if (club.address != null) ('Morada', club.address!),
    ];

    if (rows.isEmpty && club.teams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ClubCrest(club: club, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identidade',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        club.displayShortName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PhoenixColors.muted,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final row in rows) ...[
              _IdentityRow(label: row.$1, value: row.$2),
              if (row != rows.last) const SizedBox(height: 8),
            ],
            if (club.teams.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Equipas',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              for (final team in club.teams) ...[
                _TeamChip(label: team),
                if (team != club.teams.last) const SizedBox(height: 6),
              ],
            ],
          ],
        ),
      ),
    );
  }

}

class _ClubTeamsCard extends StatelessWidget {
  const _ClubTeamsCard({
    required this.club,
    required this.onOpen,
  });

  final Club club;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final identityRows = <(String, String)>[
      if (club.foundedOn != null)
        ('Fundação', formatClubFoundedDate(club.foundedOn!)),
      if (club.association != null) ('Associação', club.association!),
      if (club.president != null) ('Presidente', club.president!),
    ];

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClubCrest(club: club, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.displayShortName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          club.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: PhoenixColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
              if (identityRows.isNotEmpty) ...[
                const SizedBox(height: 12),
                for (final row in identityRows) ...[
                  _IdentityRow(label: row.$1, value: row.$2),
                  if (row != identityRows.last) const SizedBox(height: 8),
                ],
              ],
              if (club.kitAsset != null && club.kitAsset!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Equipamento',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Image.asset(
                    club.kitAsset!,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
              if (club.teams.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Estrutura de equipas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                for (final team in club.teams) ...[
                  _TeamChip(label: team),
                  if (team != club.teams.last) const SizedBox(height: 6),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamChip extends StatelessWidget {
  const _TeamChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: PhoenixColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: PhoenixColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
