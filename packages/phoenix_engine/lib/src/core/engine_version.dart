/// PSE semantic version for save metadata and migrations.
class EngineVersion {
  const EngineVersion({
    required this.major,
    required this.minor,
    required this.patch,
    this.preRelease,
  });

  static const current = EngineVersion(
    major: 0,
    minor: 8,
    patch: 0,
    preRelease: 'alpha',
  );

  final int major;
  final int minor;
  final int patch;
  final String? preRelease;

  String get semantic =>
      preRelease == null ? '$major.$minor.$patch' : '$major.$minor.$patch-$preRelease';

  Map<String, dynamic> toMap() {
    return {
      'major': major,
      'minor': minor,
      'patch': patch,
      if (preRelease != null) 'preRelease': preRelease,
    };
  }

  factory EngineVersion.fromMap(Map<String, dynamic> map) {
    return EngineVersion(
      major: map['major'] as int? ?? 0,
      minor: map['minor'] as int? ?? 1,
      patch: map['patch'] as int? ?? 0,
      preRelease: map['preRelease'] as String?,
    );
  }
}
