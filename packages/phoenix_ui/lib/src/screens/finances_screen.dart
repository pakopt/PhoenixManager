import 'package:flutter/material.dart';
import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/game/game_session.dart';
import 'package:phoenix_ui/src/theme/phoenix_theme.dart';
import 'package:phoenix_ui/src/util/money_format.dart';
import 'package:phoenix_ui/src/util/player_display_profile.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:phoenix_ui/src/widgets/empty_state.dart';
import 'package:phoenix_ui/src/widgets/section_card.dart';
import 'package:phoenix_ui/src/widgets/staff_labels.dart';

/// Finanças estilo FootSim × Phoenix — Visão geral + Massa salarial.
class FinancesScreen extends StatefulWidget {
  const FinancesScreen({required this.controller, super.key});

  final GameController controller;

  @override
  State<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends State<FinancesScreen> {
  var _tabIndex = 0;

  GameController get controller => widget.controller;
  GameSession get session => controller.session!;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onController);
  }

  @override
  void dispose() {
    controller.removeListener(_onController);
    super.dispose();
  }

  void _onController() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = session.userFinance;
    final breakdown = session.salaryBreakdown;
    final snapshot = _FinanceSnapshot.fromSession(session);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenPageHeader(
            title: 'Finanças',
            subtitle: finance == null
                ? 'Sem dados financeiros'
                : 'Saldo, orçamentos e infraestruturas',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Visão geral')),
                ButtonSegment(value: 1, label: Text('Massa salarial')),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (selection) {
                setState(() => _tabIndex = selection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: finance == null
                ? const EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    message: 'Sem dados financeiros nesta carreira.',
                  )
                : _tabIndex == 0
                    ? _OverviewTab(
                        controller: controller,
                        session: session,
                        finance: finance,
                        snapshot: snapshot,
                      )
                    : _WageBillTab(
                        session: session,
                        finance: finance,
                        breakdown: breakdown,
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Dados derivados (época actual) ─────────────────────────────────────────

class _FinanceSnapshot {
  const _FinanceSnapshot({
    required this.matchDay,
    required this.sponsors,
    required this.tvMoney,
    required this.merchandise,
    required this.prizeMoney,
    required this.transfersIn,
    required this.wages,
    required this.managerSalary,
    required this.stadiumUpkeep,
    required this.academyCost,
    required this.trainingCost,
    required this.facilityUpgrades,
    required this.transfersOut,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.monthlyPnL,
    required this.transferBudget,
    required this.sponsorAnnual,
    required this.trainingLevel,
    required this.academyLevel,
    required this.stadiumSeats,
  });

  factory _FinanceSnapshot.fromSession(GameSession session) {
    final finance = session.userFinance;
    final config = session.context.economyConfig.finance;
    final club = session.userClub;
    final breakdown = session.salaryBreakdown;
    final balance = finance?.balance ?? 0;
    final monthlyWages = finance?.monthlyWages ?? 0;
    final seasonRevenue = finance?.seasonRevenue ?? 0;
    final seasonExpenses = finance?.seasonExpenses ?? 0;
    final academyLevel = finance?.academyLevel ?? 2;
    final trainingLevel = (finance?.trainingLevel ?? 2).clamp(1, 5);

    var matchDay = finance?.seasonTicketRevenue ?? 0;
    var wagesPaid = finance?.seasonWageExpenses ?? 0;
    var facilityUpgrades = finance?.seasonFacilityUpgradeExpenses ?? 0;
    // Saves legados / sessão actual: event bus preenche se os totais persistidos forem 0.
    if (matchDay == 0 || wagesPaid == 0 || facilityUpgrades == 0) {
      var busTickets = 0;
      var busWages = 0;
      var busUpgrades = 0;
      for (final event in session.context.eventBus.history) {
        if (event is TicketRevenueEvent &&
            event.clubId == GameSession.userClubId) {
          busTickets += event.amount;
        } else if (event is SalariesPaidEvent &&
            event.clubId == GameSession.userClubId) {
          busWages += event.amount;
        } else if (event is FacilityUpgradedEvent &&
            event.clubId == GameSession.userClubId) {
          busUpgrades += event.cost;
        }
      }
      if (matchDay == 0) {
        matchDay = busTickets;
      }
      if (wagesPaid == 0) {
        wagesPaid = busWages;
      }
      if (facilityUpgrades == 0) {
        facilityUpgrades = busUpgrades;
      }
    }

    // Vendedor (from) recebe fee → receita; comprador (to) paga → despesa.
    // Só a época actual — histórico multi-época distorce patrocínios residuais.
    var transfersIn = 0;
    var transfersOut = 0;
    for (final t in session.clubTransfersThisSeason) {
      if (t.fee <= 0) {
        continue;
      }
      if (t.fromClubId == GameSession.userClubId) {
        transfersIn += t.fee;
      }
      if (t.toClubId == GameSession.userClubId) {
        transfersOut += t.fee;
      }
    }

    // Motor: receitas = bilhetes + patrocínio diário + transferências in.
    final sponsorsRaw = seasonRevenue - matchDay - transfersIn;
    final sponsors = sponsorsRaw > 0 ? sponsorsRaw : 0;
    // Categorias ainda sem motor próprio — mantêm linha FootSim a €0.
    const tvMoney = 0;
    const merchandise = 0;
    const prizeMoney = 0;

    // Despesas: salários pagos + transferências out + upgrades (+ residual).
    final salaryPool = wagesPaid > 0
        ? wagesPaid
        : (seasonExpenses - transfersOut - facilityUpgrades)
            .clamp(0, seasonExpenses);
    final totalBreakdown = breakdown.total <= 0 ? 1 : breakdown.total;
    final wages = ((salaryPool * breakdown.players) / totalBreakdown).round();
    final managerSalary =
        ((salaryPool * breakdown.coach) / totalBreakdown).round();
    final staffShare =
        ((salaryPool * breakdown.staff) / totalBreakdown).round();
    final residualOps = (seasonExpenses -
            transfersOut -
            facilityUpgrades -
            wages -
            managerSalary -
            staffShare)
        .clamp(0, seasonExpenses);
    // Staff + residual → linhas de infra (FootSim), sem inventar dinheiro extra.
    final opsPool = staffShare + residualOps;
    final stadiumUpkeep = (opsPool * 0.55).round();
    final academyCost = (opsPool * 0.225).round();
    final trainingCost = opsPool - stadiumUpkeep - academyCost;

    final monthsIntoSeason = _monthsIntoSeason(session.currentDate);
    final net = seasonRevenue - seasonExpenses;
    final monthlyPnL = (net / monthsIntoSeason).round();

    // Orçamento de transferências: saldo menos 1 mês de salários reservado.
    final transferBudget = (balance - monthlyWages).clamp(0, balance);

    final sponsorAnnual = config.dailySponsorIncome * 365;

    return _FinanceSnapshot(
      matchDay: matchDay,
      sponsors: sponsors,
      tvMoney: tvMoney,
      merchandise: merchandise,
      prizeMoney: prizeMoney,
      transfersIn: transfersIn,
      wages: wages,
      managerSalary: managerSalary,
      stadiumUpkeep: stadiumUpkeep,
      academyCost: academyCost,
      trainingCost: trainingCost,
      facilityUpgrades: facilityUpgrades,
      transfersOut: transfersOut,
      totalRevenue: seasonRevenue,
      totalExpenses: seasonExpenses,
      monthlyPnL: monthlyPnL,
      transferBudget: transferBudget,
      sponsorAnnual: sponsorAnnual,
      trainingLevel: trainingLevel,
      academyLevel: academyLevel.clamp(1, 5),
      stadiumSeats: club.stadiumCapacity,
    );
  }

  final int matchDay;
  final int sponsors;
  final int tvMoney;
  final int merchandise;
  final int prizeMoney;
  final int transfersIn;
  final int wages;
  final int managerSalary;
  final int stadiumUpkeep;
  final int academyCost;
  final int trainingCost;
  final int facilityUpgrades;
  final int transfersOut;
  final int totalRevenue;
  final int totalExpenses;
  final int monthlyPnL;
  final int transferBudget;
  final int sponsorAnnual;
  final int trainingLevel;
  final int academyLevel;
  final int stadiumSeats;

  static int _monthsIntoSeason(GameDate date) {
    // Época começa ~Agosto (mês 8): Ago=1 … Dez=5, Jan=6 … Jul=12.
    final month = date.month;
    if (month >= 8) {
      return (month - 8) + 1;
    }
    return (month + 5).clamp(1, 12);
  }
}

// ─── Visão geral ────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.controller,
    required this.session,
    required this.finance,
    required this.snapshot,
  });

  final GameController controller;
  final GameSession session;
  final ClubFinance finance;
  final _FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _KpiRow(
          balance: finance.balance,
          transferBudget: snapshot.transferBudget,
          wageBudget: finance.monthlyWages,
          monthlyPnL: snapshot.monthlyPnL,
        ),
        const SizedBox(height: 16),
        _RevenueExpensesRow(snapshot: snapshot),
        const SizedBox(height: 20),
        Text(
          'Instalações',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        _FacilitiesRow(
          snapshot: snapshot,
          onUpgrade: (kind) => _requestUpgrade(context, kind),
        ),
        const SizedBox(height: 20),
        Text(
          'Patrocínio',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        _SponsorCard(
          name: 'Phoenix Partners',
          annual: snapshot.sponsorAnnual,
          active: snapshot.sponsors > 0 ||
              session.context.economyConfig.finance.dailySponsorIncome > 0,
        ),
        const SizedBox(height: 20),
        _FfpBanner(finance: finance, session: session),
      ],
    );
  }

  void _requestUpgrade(BuildContext context, FacilityKind kind) {
    UiFeedback.action();
    final error = controller.tryUpgradeFacility(kind);
    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error),
        ),
      );
      return;
    }
    final label = switch (kind) {
      FacilityKind.training => 'Centro de treinos',
      FacilityKind.academy => 'Academia de jovens',
    };
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('$label melhorado.'),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.balance,
    required this.transferBudget,
    required this.wageBudget,
    required this.monthlyPnL,
  });

  final int balance;
  final int transferBudget;
  final int wageBudget;
  final int monthlyPnL;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _KpiCard(
        label: 'SALDO',
        value: MoneyFormat.compact(balance),
        valueColor: PhoenixColors.positive,
      ),
      _KpiCard(
        label: 'ORÇAMENTO TRANSF.',
        value: MoneyFormat.compact(transferBudget),
      ),
      _KpiCard(
        label: 'ORÇAMENTO SALARIAL',
        value: '${MoneyFormat.compact(wageBudget)}/mês',
      ),
      _KpiCard(
        label: 'P&L MENSAL',
        value: _signedMoney(monthlyPnL),
        valueColor: monthlyPnL >= 0
            ? PhoenixColors.positive
            : PhoenixColors.negative,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 10),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 10),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
              letterSpacing: 0.4,
              fontWeight: FontWeight.w700,
              color: PhoenixColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: valueColor ?? PhoenixColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueExpensesRow extends StatelessWidget {
  const _RevenueExpensesRow({required this.snapshot});

  final _FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final revenue = [
      ('Bilheteira', snapshot.matchDay),
      ('Patrocínios', snapshot.sponsors),
      ('TV', snapshot.tvMoney),
      ('Merchandising', snapshot.merchandise),
      ('Prémios', snapshot.prizeMoney),
      ('Transferências (in)', snapshot.transfersIn),
    ];
    final expenses = [
      ('Salários', snapshot.wages),
      ('Treinador', snapshot.managerSalary),
      ('Estádio', snapshot.stadiumUpkeep),
      ('Academia', snapshot.academyCost),
      ('Treinos', snapshot.trainingCost),
      ('Upgrades', snapshot.facilityUpgrades),
      ('Transferências (out)', snapshot.transfersOut),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final revenueCard = _LedgerCard(
          title: 'Receitas',
          rows: revenue,
          totalLabel: 'Total receitas',
          totalValue: snapshot.totalRevenue,
          totalColor: PhoenixColors.positive,
        );
        final expenseCard = _LedgerCard(
          title: 'Despesas',
          rows: expenses,
          totalLabel: 'Total despesas',
          totalValue: snapshot.totalExpenses,
          totalColor: PhoenixColors.negative,
        );
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: revenueCard),
              const SizedBox(width: 12),
              Expanded(child: expenseCard),
            ],
          );
        }
        return Column(
          children: [
            revenueCard,
            const SizedBox(height: 12),
            expenseCard,
          ],
        );
      },
    );
  }
}

class _LedgerCard extends StatelessWidget {
  const _LedgerCard({
    required this.title,
    required this.rows,
    required this.totalLabel,
    required this.totalValue,
    required this.totalColor,
  });

  final String title;
  final List<(String, int)> rows;
  final String totalLabel;
  final int totalValue;
  final Color totalColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          for (final row in rows) _LedgerRow(label: row.$1, amount: row.$2),
          const Divider(height: 1, color: PhoenixColors.cardBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  MoneyFormat.compact(totalValue),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: totalColor,
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

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: PhoenixColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            MoneyFormat.compact(amount),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilitiesRow extends StatelessWidget {
  const _FacilitiesRow({
    required this.snapshot,
    required this.onUpgrade,
  });

  final _FinanceSnapshot snapshot;
  final void Function(FacilityKind kind) onUpgrade;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _FacilityCard(
        title: 'Centro de treinos',
        levelLabel: 'Nível ${snapshot.trainingLevel}',
        detail: snapshot.trainingLevel >= ClubFinance.maxFacilityLevel
            ? 'Nível máximo'
            : 'Upgrade p/ nível ${snapshot.trainingLevel + 1}: '
                '${MoneyFormat.compact(ClubFinance.upgradeCost(snapshot.trainingLevel))}',
        showUpgrade: snapshot.trainingLevel < ClubFinance.maxFacilityLevel,
        onUpgrade: () => onUpgrade(FacilityKind.training),
      ),
      _FacilityCard(
        title: 'Academia de jovens',
        levelLabel: 'Nível ${snapshot.academyLevel}',
        detail: snapshot.academyLevel >= ClubFinance.maxFacilityLevel
            ? 'Nível máximo'
            : 'Upgrade p/ nível ${snapshot.academyLevel + 1}: '
                '${MoneyFormat.compact(ClubFinance.upgradeCost(snapshot.academyLevel))}',
        showUpgrade: snapshot.academyLevel < ClubFinance.maxFacilityLevel,
        onUpgrade: () => onUpgrade(FacilityKind.academy),
      ),
      _FacilityCard(
        title: 'Estádio',
        levelLabel: '${_seatsLabel(snapshot.stadiumSeats)} lugares',
        detail: 'Capacidade actual',
        showUpgrade: false,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              cards[i],
            ],
          ],
        );
      },
    );
  }

  static String _seatsLabel(int seats) {
    final formatted = seats.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return formatted;
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({
    required this.title,
    required this.levelLabel,
    required this.detail,
    required this.showUpgrade,
    this.onUpgrade,
  });

  final String title;
  final String levelLabel;
  final String detail;
  final bool showUpgrade;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                levelLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: PhoenixColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detail,
            style: const TextStyle(
              fontSize: 12,
              color: PhoenixColors.muted,
              height: 1.35,
            ),
          ),
          if (showUpgrade) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onUpgrade,
              style: OutlinedButton.styleFrom(
                foregroundColor: PhoenixColors.textPrimary,
                side: const BorderSide(color: PhoenixColors.cardBorder),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Pedir upgrade'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SponsorCard extends StatelessWidget {
  const _SponsorCard({
    required this.name,
    required this.annual,
    required this.active,
  });

  final String name;
  final int annual;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PhoenixColors.headerBar,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: PhoenixColors.cardBorder),
            ),
            child: const Icon(Icons.handshake_outlined, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  active
                      ? 'Contrato activo · rendimento diário'
                      : 'Contrato de patrocínio expirado',
                  style: TextStyle(
                    fontSize: 12,
                    color: active
                        ? PhoenixColors.muted
                        : PhoenixColors.warning,
                    fontWeight: active ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${MoneyFormat.compact(annual)}/ano',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FfpBanner extends StatelessWidget {
  const _FfpBanner({required this.finance, required this.session});

  final ClubFinance finance;
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final limit = session.context.economyConfig.finance.ffpWageRatioLimit;
    final overLimit = finance.wageToRevenueRatio > limit;
    final ratioPct = (finance.wageToRevenueRatio * 100).toStringAsFixed(1);
    final limitPct = (limit * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: overLimit
              ? PhoenixColors.warning.withValues(alpha: 0.5)
              : PhoenixColors.cardBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            overLimit ? Icons.warning_amber : Icons.check_circle_outline,
            color: overLimit ? PhoenixColors.warning : PhoenixColors.positive,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'FFP · rácio salarial $ratioPct% '
              '(limite $limitPct%) · '
              '${overLimit ? 'acima do limite' : 'dentro do limite'}',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Massa salarial ─────────────────────────────────────────────────────────

class _WageBillTab extends StatelessWidget {
  const _WageBillTab({
    required this.session,
    required this.finance,
    required this.breakdown,
  });

  final GameSession session;
  final ClubFinance finance;
  final SalaryBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final players = [...session.squad]
      ..sort((a, b) => b.salary.compareTo(a.salary));
    final staff = [...session.userStaff]
      ..sort((a, b) => b.salary.compareTo(a.salary));
    final coach = session.userCoach;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PhoenixColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PhoenixColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Despesas salariais mensais',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${session.squad.length} jogadores · '
                '${session.userStaff.length} staff · '
                '${coach != null ? '1 treinador' : 'sem treinador'}',
                style: const TextStyle(
                  color: PhoenixColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              _SalaryBar(
                label: 'Jogadores',
                amount: breakdown.players,
                total: breakdown.total,
                color: Theme.of(context).colorScheme.primary,
              ),
              _SalaryBar(
                label: 'Staff',
                amount: breakdown.staff,
                total: breakdown.total,
                color: Theme.of(context).colorScheme.secondary,
              ),
              _SalaryBar(
                label: 'Treinador',
                amount: breakdown.coach,
                total: breakdown.total,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const Divider(height: 24, color: PhoenixColors.cardBorder),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total mensal',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    MoneyFormat.compact(breakdown.total),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Massa registada: ${MoneyFormat.compact(finance.monthlyWages)}/mês',
                style: const TextStyle(
                  fontSize: 11,
                  color: PhoenixColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Plantel',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        ...players.map(
          (p) {
            final profile = PlayerDisplayProfile.from(p);
            return _WageTile(
              title: p.name,
              subtitle: profile.positionLabel,
              amount: p.salary,
            );
          },
        ),
        if (coach != null) ...[
          const SizedBox(height: 16),
          Text(
            'Treinador',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          _WageTile(
            title: coach.name,
            subtitle: 'Treinador principal',
            amount: breakdown.coach,
          ),
        ],
        if (staff.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Staff',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          ...staff.map(
            (s) => _WageTile(
              title: s.name,
              subtitle: s.role.labelPt,
              amount: s.salary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SalaryBar extends StatelessWidget {
  const _SalaryBar({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String label;
  final int amount;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = total <= 0 ? 0.0 : (amount / total * 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13)),
              Text(
                '${MoneyFormat.compact(amount)} (${pct.toStringAsFixed(0)}%)',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total <= 0 ? 0 : (amount / total).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: PhoenixColors.headerBar,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _WageTile extends StatelessWidget {
  const _WageTile({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  final String title;
  final String subtitle;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: PhoenixColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PhoenixColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: PhoenixColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            MoneyFormat.perMonth(amount),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

String _signedMoney(int value) {
  final body = MoneyFormat.compact(value.abs());
  if (value > 0) {
    return '+$body';
  }
  if (value < 0) {
    return '-$body';
  }
  return body;
}
