/// Minimal service locator for engine bootstrapping.
class ServiceContainer {
  ServiceContainer();

  final Map<Type, Object> _singletons = {};
  final Map<Type, Object Function()> _factories = {};

  void registerSingleton<T extends Object>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T extends Object>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T extends Object>() {
    final singleton = _singletons[T];
    if (singleton != null) {
      return singleton as T;
    }

    final factory = _factories[T];
    if (factory != null) {
      final instance = factory() as T;
      _singletons[T] = instance;
      return instance;
    }

    throw StateError('Service not registered: $T');
  }

  bool isRegistered<T extends Object>() {
    return _singletons.containsKey(T) || _factories.containsKey(T);
  }
}
