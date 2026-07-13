/// Temporal modes supported by PSE (same engine, different advance steps).
enum TimeScale {
  /// 1 second real = 1 second in match live mode.
  realTime,

  /// 1 click = 1 in-game day.
  management,

  /// 1 click = 1 week / month / season (configured per action).
  simulation,
}

enum SimulationStep {
  day,
  week,
  month,
  season,
}
