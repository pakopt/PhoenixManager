import 'dart:convert';

/// Metadata for a career save slot (display only — full data in [SaveStorage]).
class SaveSlotMeta {
  const SaveSlotMeta({
    required this.index,
    this.clubName,
    this.dateLabel,
    this.tick,
    this.savedAt,
    this.playMode,
    this.seasonYear,
    this.leaguePosition,
    this.leagueTitles,
    this.cupTitles,
  });

  factory SaveSlotMeta.empty(int index) => SaveSlotMeta(index: index);

  factory SaveSlotMeta.fromJson(int index, String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return SaveSlotMeta(
      index: index,
      clubName: map['clubName'] as String?,
      dateLabel: map['dateLabel'] as String?,
      tick: map['tick'] as int?,
      savedAt: map['savedAt'] != null
          ? DateTime.tryParse(map['savedAt'] as String)
          : null,
      playMode: map['playMode'] as String?,
      seasonYear: map['seasonYear'] as int?,
      leaguePosition: map['leaguePosition'] as int?,
      leagueTitles: map['leagueTitles'] as int?,
      cupTitles: map['cupTitles'] as int?,
    );
  }

  final int index;
  final String? clubName;
  final String? dateLabel;
  final int? tick;
  final DateTime? savedAt;
  final String? playMode;
  final int? seasonYear;
  final int? leaguePosition;
  final int? leagueTitles;
  final int? cupTitles;

  bool get isEmpty => clubName == null;

  String get label => 'Slot ${index + 1}';

  /// One-line summary for slot cards and picker dialogs.
  String get summarySubtitle {
    final parts = <String>[];
    if (seasonYear != null) {
      parts.add('Época $seasonYear');
    }
    if (leaguePosition != null && leaguePosition! > 0) {
      parts.add('$leaguePositionº');
    }
    if (dateLabel != null) {
      parts.add(dateLabel!);
    }
    final titles = (leagueTitles ?? 0) + (cupTitles ?? 0);
    if (titles > 0) {
      parts.add('$titles troféus');
    }
    if (parts.isEmpty) {
      return '${dateLabel ?? '—'} · tick ${tick ?? 0}';
    }
    return parts.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'clubName': clubName,
        'dateLabel': dateLabel,
        'tick': tick,
        'savedAt': savedAt?.toIso8601String(),
        'playMode': playMode,
        'seasonYear': seasonYear,
        'leaguePosition': leaguePosition,
        'leagueTitles': leagueTitles,
        'cupTitles': cupTitles,
      };

  String encode() => jsonEncode(toJson());
}
