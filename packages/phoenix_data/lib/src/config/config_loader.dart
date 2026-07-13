import 'package:phoenix_core/phoenix_core.dart';
import 'package:yaml/yaml.dart';

/// Loads [PhoenixConfig] from YAML text or file path.
class ConfigLoader {
  PhoenixConfig loadFromYaml(String yamlText) {
    final doc = loadYaml(yamlText);
    if (doc is! YamlMap) {
      throw FormatException('Config root must be a map');
    }
    return PhoenixConfig.fromMap(Map<String, dynamic>.from(doc));
  }
}
