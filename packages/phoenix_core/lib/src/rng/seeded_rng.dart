/// Deterministic pseudo-random generator for simulation replay.
class SeededRng {
  SeededRng(this._seed);

  int _seed;

  int get seed => _seed;

  /// Returns a value in [0, maxExclusive).
  int nextInt(int maxExclusive) {
    if (maxExclusive <= 0) {
      throw ArgumentError.value(maxExclusive, 'maxExclusive', 'must be > 0');
    }
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % maxExclusive;
  }

  double nextDouble() {
    return nextInt(1 << 30) / (1 << 30);
  }

  SeededRng fork() => SeededRng(_seed);
}
