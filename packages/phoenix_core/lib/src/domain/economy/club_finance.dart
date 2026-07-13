import 'package:phoenix_core/src/domain/club.dart';
import 'package:phoenix_core/src/domain/ids.dart';

/// Financial state per club — separate from [Club] entity (SSOT budget field syncs).
class ClubFinance {
  const ClubFinance({
    required this.clubId,
    required this.balance,
    this.monthlyWages = 0,
    this.seasonRevenue = 0,
    this.seasonExpenses = 0,
    this.academyLevel = 2,
    this.transfersCompletedThisWindow = 0,
  });

  factory ClubFinance.fromClub(Club club, {required int monthlyWages}) {
    return ClubFinance(
      clubId: club.id,
      balance: club.budget,
      monthlyWages: monthlyWages,
      academyLevel: _academyFromReputation(club.reputation),
    );
  }

  factory ClubFinance.fromMap(Map<String, dynamic> map) {
    return ClubFinance(
      clubId: ClubId(map['clubId'] as String),
      balance: map['balance'] as int,
      monthlyWages: map['monthlyWages'] as int? ?? 0,
      seasonRevenue: map['seasonRevenue'] as int? ?? 0,
      seasonExpenses: map['seasonExpenses'] as int? ?? 0,
      academyLevel: map['academyLevel'] as int? ?? 2,
      transfersCompletedThisWindow:
          map['transfersCompletedThisWindow'] as int? ?? 0,
    );
  }

  final ClubId clubId;
  final int balance;
  final int monthlyWages;
  final int seasonRevenue;
  final int seasonExpenses;
  final int academyLevel;
  final int transfersCompletedThisWindow;

  double get wageToRevenueRatio {
    if (seasonRevenue <= 0) {
      return monthlyWages > 0 ? 1.0 : 0.0;
    }
    return (monthlyWages * 12) / seasonRevenue;
  }

  ClubFinance copyWith({
    int? balance,
    int? monthlyWages,
    int? seasonRevenue,
    int? seasonExpenses,
    int? academyLevel,
    int? transfersCompletedThisWindow,
  }) {
    return ClubFinance(
      clubId: clubId,
      balance: balance ?? this.balance,
      monthlyWages: monthlyWages ?? this.monthlyWages,
      seasonRevenue: seasonRevenue ?? this.seasonRevenue,
      seasonExpenses: seasonExpenses ?? this.seasonExpenses,
      academyLevel: academyLevel ?? this.academyLevel,
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
        'academyLevel': academyLevel,
        'transfersCompletedThisWindow': transfersCompletedThisWindow,
      };

  static int _academyFromReputation(int reputation) {
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
}

// Forward reference avoided — Club imported at use site via phoenix_core barrel.
