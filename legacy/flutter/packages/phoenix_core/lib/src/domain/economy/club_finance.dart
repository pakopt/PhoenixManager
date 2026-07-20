import 'package:phoenix_core/src/domain/club.dart';
import 'package:phoenix_core/src/domain/ids.dart';

/// Tipo de instalação que o clube pode melhorar.
enum FacilityKind {
  training,
  academy,
}

/// Financial state per club — separate from [Club] entity (SSOT budget field syncs).
class ClubFinance {
  const ClubFinance({
    required this.clubId,
    required this.balance,
    this.monthlyWages = 0,
    this.seasonRevenue = 0,
    this.seasonExpenses = 0,
    this.seasonTicketRevenue = 0,
    this.seasonWageExpenses = 0,
    this.seasonFacilityUpgradeExpenses = 0,
    this.academyLevel = 2,
    this.trainingLevel = 2,
    this.transfersCompletedThisWindow = 0,
  });

  factory ClubFinance.fromClub(Club club, {required int monthlyWages}) {
    final level = facilityLevelFromReputation(club.reputation);
    return ClubFinance(
      clubId: club.id,
      balance: club.budget,
      monthlyWages: monthlyWages,
      academyLevel: level,
      trainingLevel: level,
    );
  }

  factory ClubFinance.fromMap(Map<String, dynamic> map) {
    return ClubFinance(
      clubId: ClubId(map['clubId'] as String),
      balance: map['balance'] as int,
      monthlyWages: map['monthlyWages'] as int? ?? 0,
      seasonRevenue: map['seasonRevenue'] as int? ?? 0,
      seasonExpenses: map['seasonExpenses'] as int? ?? 0,
      seasonTicketRevenue: map['seasonTicketRevenue'] as int? ?? 0,
      seasonWageExpenses: map['seasonWageExpenses'] as int? ?? 0,
      seasonFacilityUpgradeExpenses:
          map['seasonFacilityUpgradeExpenses'] as int? ?? 0,
      academyLevel: map['academyLevel'] as int? ?? 2,
      trainingLevel: map['trainingLevel'] as int? ?? 2,
      transfersCompletedThisWindow:
          map['transfersCompletedThisWindow'] as int? ?? 0,
    );
  }

  static const maxFacilityLevel = 5;

  final ClubId clubId;
  final int balance;
  final int monthlyWages;
  final int seasonRevenue;
  final int seasonExpenses;
  /// Bilheteira acumulada na época (persiste no save; não depende do event bus).
  final int seasonTicketRevenue;
  /// Salários pagos na época (persiste no save).
  final int seasonWageExpenses;
  /// Custos de upgrade de instalações na época (persiste no save).
  final int seasonFacilityUpgradeExpenses;
  final int academyLevel;
  final int trainingLevel;
  final int transfersCompletedThisWindow;

  double get wageToRevenueRatio {
    if (seasonRevenue <= 0) {
      return monthlyWages > 0 ? 1.0 : 0.0;
    }
    return (monthlyWages * 12) / seasonRevenue;
  }

  int levelFor(FacilityKind kind) => switch (kind) {
        FacilityKind.training => trainingLevel,
        FacilityKind.academy => academyLevel,
      };

  /// Custo para subir do [currentLevel] para o seguinte (nível 1–4 → próximo).
  static int upgradeCost(int currentLevel) {
    return switch (currentLevel) {
      1 => 400000,
      2 => 800000,
      3 => 1500000,
      _ => 2500000,
    };
  }

  static int facilityLevelFromReputation(int reputation) {
    if (reputation >= 75) {
      return 4;
    }
    if (reputation >= 65) {
      return 3;
    }
    if (reputation >= 55) {
      return 2;
    }
    return 1;
  }

  ClubFinance copyWith({
    int? balance,
    int? monthlyWages,
    int? seasonRevenue,
    int? seasonExpenses,
    int? seasonTicketRevenue,
    int? seasonWageExpenses,
    int? seasonFacilityUpgradeExpenses,
    int? academyLevel,
    int? trainingLevel,
    int? transfersCompletedThisWindow,
  }) {
    return ClubFinance(
      clubId: clubId,
      balance: balance ?? this.balance,
      monthlyWages: monthlyWages ?? this.monthlyWages,
      seasonRevenue: seasonRevenue ?? this.seasonRevenue,
      seasonExpenses: seasonExpenses ?? this.seasonExpenses,
      seasonTicketRevenue: seasonTicketRevenue ?? this.seasonTicketRevenue,
      seasonWageExpenses: seasonWageExpenses ?? this.seasonWageExpenses,
      seasonFacilityUpgradeExpenses:
          seasonFacilityUpgradeExpenses ?? this.seasonFacilityUpgradeExpenses,
      academyLevel: academyLevel ?? this.academyLevel,
      trainingLevel: trainingLevel ?? this.trainingLevel,
      transfersCompletedThisWindow:
          transfersCompletedThisWindow ?? this.transfersCompletedThisWindow,
    );
  }

  Map<String, dynamic> toMap() => {
        'clubId': clubId.value,
        'balance': balance,
        'monthlyWages': monthlyWages,
        'seasonRevenue': seasonRevenue,
        'seasonExpenses': seasonExpenses,
        'seasonTicketRevenue': seasonTicketRevenue,
        'seasonWageExpenses': seasonWageExpenses,
        'seasonFacilityUpgradeExpenses': seasonFacilityUpgradeExpenses,
        'academyLevel': academyLevel,
        'trainingLevel': trainingLevel,
        'transfersCompletedThisWindow': transfersCompletedThisWindow,
      };
}
