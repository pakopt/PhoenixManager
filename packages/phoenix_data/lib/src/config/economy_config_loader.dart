import 'package:phoenix_core/phoenix_core.dart';
import 'package:yaml/yaml.dart';

/// Loads [EconomyConfig] from YAML.
class EconomyConfigLoader {
  EconomyConfig loadFromYaml(String yamlText) {
    final doc = loadYaml(yamlText);
    if (doc is! YamlMap) {
      throw FormatException('Economy config root must be a map');
    }
    return EconomyConfig.fromMap(Map<String, dynamic>.from(doc));
  }

  EconomyConfig defaults() => const EconomyConfig();
}
