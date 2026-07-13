/// Formatação consistente de valores monetários em toda a UI.
abstract final class MoneyFormat {
  static String compact(int value, {bool euro = true}) {
    final prefix = euro ? '€' : '';
    if (value.abs() >= 1000000) {
      return '$prefix${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) {
      return '$prefix${(value / 1000).toStringAsFixed(0)}K';
    }
    return '$prefix$value';
  }

  static String perMonth(int salary) => '${compact(salary)}/mês';
}
