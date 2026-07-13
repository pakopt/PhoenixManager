import 'package:phoenix_core/src/domain/ids.dart';

enum CoachPersonality {
  pragmatist,
  idealist,
  disciplinarian,
  youthDeveloper,
}

class Coach {
  const Coach({
    required this.id,
    required this.name,
    required this.clubId,
    this.reputation = 50,
    this.personality = CoachPersonality.pragmatist,
    this.licenseLevel = 2,
  });

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      id: CoachId(map['id'] as String),
      name: map['name'] as String,
      clubId: ClubId(map['clubId'] as String),
      reputation: map['reputation'] as int? ?? 50,
      personality: CoachPersonality.values.byName(
        map['personality'] as String? ?? 'pragmatist',
      ),
      licenseLevel: map['licenseLevel'] as int? ?? 2,
    );
  }

  final CoachId id;
  final String name;
  final ClubId clubId;
  final int reputation;
  final CoachPersonality personality;
  final int licenseLevel;

  Map<String, dynamic> toMap() => {
        'id': id.value,
        'name': name,
        'clubId': clubId.value,
        'reputation': reputation,
        'personality': personality.name,
        'licenseLevel': licenseLevel,
      };
}
