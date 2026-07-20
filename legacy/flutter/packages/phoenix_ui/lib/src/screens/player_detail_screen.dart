import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/player_stat_bar.dart';

/// Ficha do jogador (estilo FootSim × Phoenix) ao clicar no plantel.
class PlayerDetailScreen extends StatelessWidget {
  const PlayerDetailScreen({
    required this.controller,
    required this.playerId,
    super.key,
  });

  final GameController controller;
  final PlayerId playerId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final session = controller.session!;
        final player = session.getPlayer(playerId);
        if (player == null) {
          return Scaffold(
            backgroundColor: PhoenixColors.surface,
            appBar: AppBar(
              title: const Text('Jogador'),
              backgroundColor: PhoenixColors.headerBar,
            ),
            body: const Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                message: 'Jogador não encontrado no plantel.',
              ),
            ),
          );
        }
        return _PlayerDetailBody(
          controller: controller,
          session: session,
          player: player,
        );
      },
    );
  }
}

class _PlayerDetailBody extends StatelessWidget {
  const _PlayerDetailBody({
    required this.controller,
    required this.session,
    required this.player,
  });

  final GameController controller;
  final GameSession session;
  final Player player;

  @override
  Widget build(BuildContext context) {
    final gap = player.potentialAbility - player.currentAbility;
    final isYouth = player.age <= session.youthConfig.maxAge;
    final isWonderkid = gap >= 15;
    final canRenew = session.canRenewPlayer(player);
    final defaultOffer = canRenew ? session.renewalOfferFor(player.id) : null;
    final isExpiring = player.contractEndYear <= session.seasonYear + 1;
    final value = const PlayerValueService().calculate(
      player,
      club: session.registry.getClub(player.clubId),
    );
    final nationality = player.nationalityId == null
        ? null
        : session.registry.countries[player.nationalityId!]?.name;
    final profile = PlayerDisplayProfile.from(player);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: PhoenixColors.surface,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Voltar ao plantel'),
                    style: TextButton.styleFrom(
                      foregroundColor: PhoenixColors.muted,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: _PlayerHeader(
                  player: player,
                  profile: profile,
                  nationality: nationality,
                  isYouth: isYouth,
                  isWonderkid: isWonderkid,
                  canRenew: canRenew && defaultOffer != null,
                  onRenew: () {
                    UiFeedback.tap();
                    _showRenewDialog(
                      context,
                      controller,
                      player,
                      defaultOffer!.extensionYears,
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: PhoenixColors.textPrimary,
                  unselectedLabelColor: PhoenixColors.muted,
                  indicatorColor: PhoenixColors.seed,
                  dividerColor: PhoenixColors.cardBorder,
                  tabs: [
                    Tab(text: 'Visão geral'),
                    Tab(text: 'Desenvolvimento'),
                    Tab(text: 'Contrato'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(
                      player: player,
                      session: session,
                      value: value,
                      nationality: nationality,
                      profile: profile,
                    ),
                    _DevelopmentTab(
                      player: player,
                      attrs: profile.attributes,
                      gap: gap,
                    ),
                    _ContractTab(
                      player: player,
                      session: session,
                      value: value,
                      canRenew: canRenew && defaultOffer != null,
                      defaultOffer: defaultOffer,
                      isExpiring: isExpiring,
                      onRenew: () {
                        UiFeedback.tap();
                        _showRenewDialog(
                          context,
                          controller,
                          player,
                          defaultOffer!.extensionYears,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({
    required this.player,
    required this.profile,
    required this.nationality,
    required this.isYouth,
    required this.isWonderkid,
    required this.canRenew,
    required this.onRenew,
  });

  final Player player;
  final PlayerDisplayProfile profile;
  final String? nationality;
  final bool isYouth;
  final bool isWonderkid;
  final bool canRenew;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PhoenixColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetaChip(label: profile.position, emphasized: true),
                  if (nationality != null) _MetaChip(label: nationality!),
                  _MetaChip(label: 'Idade ${player.age}'),
                  _MetaChip(label: profile.preferredFoot),
                  _MetaChip(label: '${profile.heightCm} cm'),
                  if (player.isInjured)
                    const _MetaChip(
                      label: 'Lesionado',
                      tone: _ChipTone.danger,
                    ),
                  if (isWonderkid)
                    const _MetaChip(
                      label: 'Estrela',
                      tone: _ChipTone.gold,
                    )
                  else if (isYouth)
                    const _MetaChip(
                      label: 'Academia',
                      tone: _ChipTone.info,
                    ),
                ],
              ),
              if (canRenew) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: onRenew,
                  icon: const Icon(Icons.edit_document, size: 18),
                  label: const Text('Oferecer renovação'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        _OverallBadge(overall: player.currentAbility),
      ],
    );
  }
}

class _OverallBadge extends StatelessWidget {
  const _OverallBadge({required this.overall});

  final int overall;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: PhoenixColors.seed.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PhoenixColors.seed.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Text(
            '$overall',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: PhoenixColors.positive,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'OVERALL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: PhoenixColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChipTone { neutral, emphasized, danger, gold, info }

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.emphasized = false,
    this.tone = _ChipTone.neutral,
  });

  final String label;
  final bool emphasized;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final resolved = emphasized ? _ChipTone.emphasized : tone;
    final (bg, fg, border) = switch (resolved) {
      _ChipTone.emphasized => (
          PhoenixColors.seed.withValues(alpha: 0.22),
          PhoenixColors.positive,
          PhoenixColors.seed.withValues(alpha: 0.5),
        ),
      _ChipTone.danger => (
          PhoenixColors.negative.withValues(alpha: 0.18),
          const Color(0xFFFF8A80),
          PhoenixColors.negative.withValues(alpha: 0.45),
        ),
      _ChipTone.gold => (
          PhoenixColors.draw.withValues(alpha: 0.18),
          PhoenixColors.draw,
          PhoenixColors.draw.withValues(alpha: 0.45),
        ),
      _ChipTone.info => (
          Colors.blueAccent.withValues(alpha: 0.16),
          Colors.lightBlueAccent,
          Colors.blueAccent.withValues(alpha: 0.4),
        ),
      _ChipTone.neutral => (
          PhoenixColors.card,
          PhoenixColors.textSecondary,
          PhoenixColors.cardBorder,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.player,
    required this.session,
    required this.value,
    required this.nationality,
    required this.profile,
  });

  final Player player;
  final GameSession session;
  final int value;
  final String? nationality;
  final PlayerDisplayProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Forma',
                value: '${player.form}',
                highlight: player.form >= 70,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Moral',
                value: '${player.morale}%',
                highlight: player.morale >= 75,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Potencial',
                value: '${player.potentialAbility}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Valor',
                value: MoneyFormat.compact(value),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Perfil',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                _InfoRow(label: 'Posição', value: profile.positionLabel),
                _InfoRow(label: 'Pé preferido', value: profile.preferredFoot),
                _InfoRow(label: 'Altura', value: '${profile.heightCm} cm'),
                _InfoRow(label: 'Idade', value: '${player.age} anos'),
                if (nationality != null)
                  _InfoRow(label: 'Nacionalidade', value: nationality!),
                _InfoRow(
                  label: 'Clube',
                  value: session.clubName(player.clubId),
                ),
                _InfoRow(
                  label: 'Estado',
                  value: player.isInjured
                      ? 'Lesionado (${player.injuredDaysRemaining} dias)'
                      : 'Disponível',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                PlayerStatBar(
                  label: 'CA → PA',
                  value: player.currentAbility,
                  max: player.potentialAbility,
                ),
                PlayerStatBar(
                  label: 'Forma',
                  value: player.form,
                  max: 100,
                  color: Colors.blueAccent,
                ),
                PlayerStatBar(
                  label: 'Moral',
                  value: player.morale,
                  max: 100,
                  color: Colors.amber,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DevelopmentTab extends StatelessWidget {
  const _DevelopmentTab({
    required this.player,
    required this.attrs,
    required this.gap,
  });

  final Player player;
  final List<PlayerAttribute> attrs;
  final int gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Resumo',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Capacidade',
                value: '${player.currentAbility}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Potencial',
                value: '${player.potentialAbility}',
                highlight: gap >= 10,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Idade',
                value: '${player.age}',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Moral',
                value: '${player.morale}%',
                highlight: player.morale >= 75,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Evolução de capacidade',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Margem até ao potencial: +$gap',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PhoenixColors.muted,
                  ),
                ),
                const SizedBox(height: 16),
                _AbilityTrendChart(
                  current: player.currentAbility,
                  potential: player.potentialAbility,
                ),
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
                  'Atributos',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perfil derivado da capacidade actual',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: PhoenixColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                for (final attr in attrs) ...[
                  _AttributeRow(attribute: attr),
                  if (attr != attrs.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ContractTab extends StatelessWidget {
  const _ContractTab({
    required this.player,
    required this.session,
    required this.value,
    required this.canRenew,
    required this.defaultOffer,
    required this.isExpiring,
    required this.onRenew,
  });

  final Player player;
  final GameSession session;
  final int value;
  final bool canRenew;
  final ContractRenewalOffer? defaultOffer;
  final bool isExpiring;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Card(
          color: isExpiring
              ? PhoenixColors.warning.withValues(alpha: 0.12)
              : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Contrato',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'Salário',
                  value: MoneyFormat.perMonth(player.salary),
                ),
                _InfoRow(
                  label: 'Válido até',
                  value: '${player.contractEndYear}',
                ),
                _InfoRow(
                  label: 'Valor de mercado',
                  value: MoneyFormat.compact(value),
                ),
                _InfoRow(
                  label: 'Clube',
                  value: session.clubName(player.clubId),
                ),
              ],
            ),
          ),
        ),
        if (canRenew && defaultOffer != null) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Renovação disponível',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isExpiring
                        ? 'Contrato expira em ${player.contractEndYear}'
                        : 'Contrato válido até ${player.contractEndYear}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PhoenixColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Proposta (+${defaultOffer!.extensionYears} anos): '
                    '${MoneyFormat.perMonth(defaultOffer!.newSalary)} '
                    '(+${MoneyFormat.compact(defaultOffer!.salaryIncrease)}) · '
                    'até ${defaultOffer!.newContractEndYear}',
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: onRenew,
                    icon: const Icon(Icons.edit_document),
                    label: const Text('Renovar contrato'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: PhoenixColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color:
                  highlight ? PhoenixColors.positive : PhoenixColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: PhoenixColors.muted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.attribute});

  final PlayerAttribute attribute;

  @override
  Widget build(BuildContext context) {
    final color = attribute.value >= 80
        ? PhoenixColors.positive
        : attribute.value >= 65
            ? PhoenixColors.warning
            : PhoenixColors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                attribute.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${attribute.value}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (attribute.value / 99).clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: PhoenixColors.cardBorder,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AbilityTrendChart extends StatelessWidget {
  const _AbilityTrendChart({
    required this.current,
    required this.potential,
  });

  final int current;
  final int potential;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _TrendPainter(current: current, potential: potential),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({required this.current, required this.potential});

  final int current;
  final int potential;

  @override
  void paint(Canvas canvas, Size size) {
    final midY = size.height * 0.55;
    final points = <Offset>[
      Offset(0, midY + 8),
      Offset(size.width * 0.25, midY + 2),
      Offset(size.width * 0.5, midY - 4),
      Offset(size.width * 0.75, midY - 2),
      Offset(size.width, midY - ((current / 100) * 18)),
    ];

    final grid = Paint()
      ..color = PhoenixColors.cardBorder
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final line = Paint()
      ..color = PhoenixColors.seed
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, line);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = PhoenixColors.seed.withValues(alpha: 0.12),
    );

    final paY = size.height * (1 - (potential.clamp(40, 99) / 120));
    canvas.drawLine(
      Offset(0, paY),
      Offset(size.width, paY),
      Paint()
        ..color = PhoenixColors.muted.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.current != current || oldDelegate.potential != potential;
}

Future<void> _showRenewDialog(
  BuildContext context,
  GameController controller,
  Player player,
  int defaultYears,
) async {
  final session = controller.session!;
  final config = session.contractConfig;
  var selectedYears = defaultYears;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final offer = session.renewalOfferFor(
            player.id,
            years: selectedYears,
          );
          return AlertDialog(
            title: Text('Renovar ${player.name}'),
            content: offer == null
                ? const Text('Renovação indisponível')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Duração da extensão'),
                      const SizedBox(height: 8),
                      SegmentedButton<int>(
                        segments: [
                          for (var y = config.minExtensionYears;
                              y <= config.maxExtensionYears;
                              y++)
                            ButtonSegment(value: y, label: Text('$y anos')),
                        ],
                        selected: {selectedYears},
                        onSelectionChanged: (value) {
                          setState(() => selectedYears = value.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Novo salário: ${MoneyFormat.perMonth(offer.newSalary)}',
                      ),
                      Text(
                        'Aumento: +${MoneyFormat.compact(offer.salaryIncrease)}/mês',
                      ),
                      Text('Válido até: ${offer.newContractEndYear}'),
                      Text(
                        'Moral +${config.moraleBoostOnRenewal} após assinatura',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: offer == null
                    ? null
                    : () => Navigator.pop(dialogContext, true),
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  final error = await controller.renewContract(
    player.id,
    extensionYears: selectedYears,
  );
  if (!context.mounted) {
    return;
  }

  if (error != null) {
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
    SnackBar(content: Text('Contrato de ${player.name} renovado')),
  );
}
