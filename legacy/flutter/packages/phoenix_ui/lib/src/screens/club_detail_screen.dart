import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/widgets/club_crest.dart';
import 'package:phoenix_ui/src/widgets/coach_labels.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';

/// Ficha de qualquer clube da liga (identidade, staff e estrutura).
class ClubDetailScreen extends StatelessWidget {
  const ClubDetailScreen({
    required this.session,
    required this.clubId,
    super.key,
  });

  final GameSession session;
  final ClubId clubId;

  static void open(
    BuildContext context, {
    required GameSession session,
    required ClubId clubId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClubDetailScreen(
          session: session,
          clubId: clubId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final club = session.registry.getClub(clubId);
    if (club == null) {
      return Scaffold(
        backgroundColor: PhoenixColors.surface,
        appBar: AppBar(
          title: const Text('Clube'),
          backgroundColor: PhoenixColors.headerBar,
        ),
        body: const Center(
          child: EmptyState(
            icon: Icons.shield_outlined,
            message: 'Clube não encontrado.',
          ),
        ),
      );
    }

    final city = session.registry.cities[club.cityId];
    final region = city != null ? session.registry.regions[city.regionId] : null;
    final country =
        region != null ? session.registry.countries[region.countryId] : null;
    final coach = club.coachId != null
        ? session.registry.getCoach(club.coachId!)
        : null;
    final squadSize =
        session.registry.squadQuery.getByClubId(clubId).length;
    final standingIndex = session.standings.indexWhere((e) => e.clubId == clubId);
    final standing =
        standingIndex >= 0 ? session.standings[standingIndex] : null;
    final isUser = clubId == GameSession.userClubId;
    final theme = Theme.of(context);

    final identityRows = <(String, String)>[
      if (club.foundedOn != null)
        ('Fundação', formatClubFoundedDate(club.foundedOn!)),
      if (city != null) ('Cidade', city.name),
      if (country != null) ('País', country.name),
      if (club.association != null) ('Associação', club.association!),
      if (club.president != null) ('Presidente', club.president!),
      if (club.address != null) ('Morada', club.address!),
    ];

    return Scaffold(
      backgroundColor: PhoenixColors.surface,
      appBar: AppBar(
        title: Text(club.displayShortName),
        backgroundColor: PhoenixColors.headerBar,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClubCrest(club: club, size: 72),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (club.shortName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            club.shortName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: PhoenixColors.muted,
                            ),
                          ),
                        ],
                        if (isUser) ...[
                          const SizedBox(height: 8),
                          Text(
                            'O teu clube',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: PhoenixColors.seed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (standing != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Posição',
                      value: '${standingIndex + 1}º',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Pontos',
                      value: '${standing.points}',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Jogos',
                      value: '${standing.played}',
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'DG',
                      value:
                          '${standing.goalDifference >= 0 ? '+' : ''}${standing.goalDifference}',
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Identidade',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (identityRows.isEmpty)
                    Text(
                      'Sem dados de identidade.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: PhoenixColors.muted,
                      ),
                    )
                  else
                    for (final row in identityRows) ...[
                      _DetailRow(label: row.$1, value: row.$2),
                      if (row != identityRows.last) const SizedBox(height: 8),
                    ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Clube',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Estádio',
                    value: '${club.stadiumCapacity} lugares',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Reputação',
                    value: '${club.reputation}',
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Plantel',
                    value: '$squadSize jogadores',
                  ),
                ],
              ),
            ),
          ),
          if (coach != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Treinador',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      coach.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(coach.licenseLabel),
                    Text(
                      coach.personality.labelPt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: PhoenixColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (club.kitAsset != null && club.kitAsset!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Equipamento',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset(
                        club.kitAsset!,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (club.teams.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Estrutura de equipas',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final team in club.teams) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PhoenixColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: PhoenixColors.cardBorder),
                        ),
                        child: Text(team),
                      ),
                      if (team != club.teams.last) const SizedBox(height: 6),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Data de fundação `YYYY-MM-DD` → texto PT curto.
String formatClubFoundedDate(String iso) {
  final parts = iso.split('-');
  if (parts.length != 3) {
    return iso;
  }
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) {
    return iso;
  }
  const months = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  if (month < 1 || month > 12) {
    return iso;
  }
  return '$day ${months[month - 1]} $year';
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: PhoenixColors.muted,
                ),
          ),
        ],
      ),
    );
  }
}
