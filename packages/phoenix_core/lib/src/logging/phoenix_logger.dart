enum LogLevel {
  debug,
  info,
  warn,
  error,
}

typedef LogSink = void Function(LogLevel level, String message);

/// Structured logger used across PSE packages.
class PhoenixLogger {
  PhoenixLogger({
    this.minLevel = LogLevel.info,
    LogSink? sink,
  }) : _sink = sink ?? _defaultSink;

  final LogLevel minLevel;
  final LogSink _sink;

  final List<LogEntry> _entries = [];

  List<LogEntry> get entries => List.unmodifiable(_entries);

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warn(String message) => _log(LogLevel.warn, message);
  void error(String message) => _log(LogLevel.error, message);

  void _log(LogLevel level, String message) {
    if (level.index < minLevel.index) {
      return;
    }
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now().toUtc(),
    );
    _entries.add(entry);
    _sink(level, message);
  }

  static void _defaultSink(LogLevel level, String message) {
    // ignore: avoid_print
    print('[${level.name.toUpperCase()}] $message');
  }
}

class LogEntry {
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
  });

  final LogLevel level;
  final String message;
  final DateTime timestamp;
}
