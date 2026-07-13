/// Immutable engine configuration loaded from YAML.
class PhoenixConfig {
  const PhoenixConfig({
    required this.engineVersion,
    required this.sport,
    required this.defaultSeed,
    required this.simulation,
  });

  factory PhoenixConfig.defaults() {
    return const PhoenixConfig(
      engineVersion: '0.1.0-alpha',
      sport: 'football',
      defaultSeed: 42,
      simulation: SimulationConfig(
        daysPerWeek: 7,
        weeksPerSeason: 38,
      ),
    );
  }

  factory PhoenixConfig.fromMap(Map<String, dynamic> map) {
    final simulationMap = map['simulation'] as Map<dynamic, dynamic>? ?? {};
    return PhoenixConfig(
      engineVersion: map['engineVersion'] as String? ?? '0.1.0-alpha',
      sport: map['sport'] as String? ?? 'football',
      defaultSeed: map['defaultSeed'] as int? ?? 42,
      simulation: SimulationConfig.fromMap(
        Map<String, dynamic>.from(simulationMap),
      ),
    );
  }

  final String engineVersion;
  final String sport;
  final int defaultSeed;
  final SimulationConfig simulation;

  Map<String, dynamic> toMap() {
    return {
      'engineVersion': engineVersion,
      'sport': sport,
      'defaultSeed': defaultSeed,
      'simulation': simulation.toMap(),
    };
  }
}

class SimulationConfig {
  const SimulationConfig({
    required this.daysPerWeek,
    required this.weeksPerSeason,
  });

  factory SimulationConfig.fromMap(Map<String, dynamic> map) {
    return SimulationConfig(
      daysPerWeek: map['daysPerWeek'] as int? ?? 7,
      weeksPerSeason: map['weeksPerSeason'] as int? ?? 38,
    );
  }

  final int daysPerWeek;
  final int weeksPerSeason;

  Map<String, dynamic> toMap() {
    return {
      'daysPerWeek': daysPerWeek,
      'weeksPerSeason': weeksPerSeason,
    };
  }
}
