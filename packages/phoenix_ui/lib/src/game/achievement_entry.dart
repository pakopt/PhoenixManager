import 'package:phoenix_core/phoenix_core.dart';

class AchievementEntry {
  const AchievementEntry({
    required this.definition,
    this.unlocked,
  });

  final AchievementDefinition definition;
  final UnlockedAchievement? unlocked;

  bool get isUnlocked => unlocked != null;
}
