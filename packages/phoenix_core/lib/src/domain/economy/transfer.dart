import 'package:phoenix_core/src/domain/ids.dart';
import 'package:phoenix_core/src/time/game_date.dart';

extension type const TransferId(String value) {}

/// Completed transfer record — append-only history.
class TransferRecord {
  const TransferRecord({
    required this.id,
    required this.playerId,
    required this.fromClubId,
    required this.toClubId,
    required this.fee,
    required this.date,
    this.isFree = false,
  });

  factory TransferRecord.fromMap(Map<String, dynamic> map) {
    return TransferRecord(
      id: TransferId(map['id'] as String),
      playerId: PlayerId(map['playerId'] as String),
      fromClubId: ClubId(map['fromClubId'] as String),
      toClubId: ClubId(map['toClubId'] as String),
      fee: map['fee'] as int,
      date: GameDate.fromMap(Map<String, dynamic>.from(map['date'] as Map)),
      isFree: map['isFree'] as bool? ?? false,
    );
  }

  final TransferId id;
  final PlayerId playerId;
  final ClubId fromClubId;
  final ClubId toClubId;
  final int fee;
  final GameDate date;
  final bool isFree;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'playerId': playerId.value,
        'fromClubId': fromClubId.value,
        'toClubId': toClubId.value,
        'fee': fee,
        'date': date.toMap(),
        'isFree': isFree,
      };
}
