import 'package:phoenix_core/phoenix_core.dart';

/// Formatação de datas para a UI.
abstract final class DateFormatUtil {
  static String relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) {
      return 'agora';
    }
    if (diff.inHours < 1) {
      return 'há ${diff.inMinutes} min';
    }
    if (diff.inDays < 1) {
      return 'há ${diff.inHours} h';
    }
    if (diff.inDays < 7) {
      return 'há ${diff.inDays} dias';
    }
    return gameDate(dt);
  }

  /// Data de jogo legível (ex.: 15 Ago 2026).
  static String gameDate(dynamic value) {
    if (value is GameDate) {
      return _formatParts(value.day, value.month, value.year);
    }
    if (value is DateTime) {
      return _formatDateTime(value);
    }
    final text = value.toString();
    final parsed = DateTime.tryParse(text);
    if (parsed != null) {
      return _formatDateTime(parsed);
    }
    return text;
  }

  static String _formatParts(int day, int month, int year) {
    const months = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '$day ${months[month - 1]} $year';
  }

  static String _formatDateTime(DateTime dt) =>
      _formatParts(dt.day, dt.month, dt.year);
}
