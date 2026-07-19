import 'package:phoenix_engine/src/event_bus/world_events.dart';

typedef EventHandler<T extends PhoenixEvent> = void Function(T event);

/// Simple synchronous event bus for Alpha v0.1.
class EventBus {
  final Map<Type, List<void Function(PhoenixEvent)>> _handlers = {};
  final List<PhoenixEvent> _history = [];

  List<PhoenixEvent> get history => List.unmodifiable(_history);

  void subscribe<T extends PhoenixEvent>(EventHandler<T> handler) {
    _handlers.putIfAbsent(T, () => []).add((event) {
      handler(event as T);
    });
  }

  void publish(PhoenixEvent event) {
    _history.add(event);
    final handlers = _handlers[event.runtimeType];
    if (handlers == null) {
      return;
    }
    for (final handler in List<void Function(PhoenixEvent)>.from(handlers)) {
      handler(event);
    }
  }

  void clearHistory() => _history.clear();

  /// Restaura histórico sem disparar handlers (ex.: após load de save).
  void restoreHistory(Iterable<PhoenixEvent> events) {
    _history
      ..clear()
      ..addAll(events);
  }
}
