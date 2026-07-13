import 'package:phoenix_core/phoenix_core.dart';
import 'package:yaml/yaml.dart';

/// Loads [MatchEngineConfig] from YAML.
class MatchConfigLoader {
  MatchEngineConfig loadFromYaml(String yamlText) {
    final doc = loadYaml(yamlText);
    if (doc is! YamlMap) {
      throw FormatException('Match config root must be a map');
    }
    return MatchEngineConfig.fromMap(Map<String, dynamic>.from(doc));
  }

  MatchEngineConfig defaults() => const MatchEngineConfig();
}
