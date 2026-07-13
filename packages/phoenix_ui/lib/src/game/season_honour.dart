/// Troféus ganhos numa época — lê `registry.seasonHonours`.
class SeasonHonourEntry {
  const SeasonHonourEntry({
    required this.seasonYear,
    required this.honours,
  });

  final int seasonYear;
  final List<String> honours;

  bool get isDouble => honours.contains('liga') && honours.contains('taca');

  List<String> get labels =>
      honours.map(SeasonHonourLabels.label).toList()..sort();
}

abstract final class SeasonHonourLabels {
  static String label(String honourKey) {
    return switch (honourKey) {
      'liga' => 'Liga Phoenix',
      'taca' => 'Taça Phoenix',
      _ => honourKey,
    };
  }
}
