import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:phoenix_ui/src/game/simulation_lab_presets.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';
import 'package:phoenix_ui/src/game/simulation_lab_service.dart';

/// Orchestrates headless lab runs without touching the player's career save.
class SimulationLabController extends ChangeNotifier {
  static const maxHistory = 8;

  SimulationLabReport? report;
  final List<SimulationLabRunSummary> history = [];
  bool running = false;
  String? error;

  SimulationLabMode mode = SimulationLabMode.untilSeasonEnd;
  int amount = 1;
  int seed = 42;
  SimulationLabMatchPreset matchPreset = SimulationLabMatchPreset.defaultPreset;
  SimulationLabEconomyPreset economyPreset =
      SimulationLabEconomyPreset.defaultPreset;

  void setMode(SimulationLabMode value) {
    if (mode == value) {
      return;
    }
    mode = value;
    notifyListeners();
  }

  void setAmount(int value) {
    final clamped = value.clamp(1, 100);
    if (amount == clamped) {
      return;
    }
    amount = clamped;
    notifyListeners();
  }

  void setSeed(int value) {
    if (seed == value) {
      return;
    }
    seed = value;
    notifyListeners();
  }

  void setMatchPreset(SimulationLabMatchPreset value) {
    if (matchPreset == value) {
      return;
    }
    matchPreset = value;
    notifyListeners();
  }

  void setEconomyPreset(SimulationLabEconomyPreset value) {
    if (economyPreset == value) {
      return;
    }
    economyPreset = value;
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }

  Future<void> run() async {
    if (running) {
      return;
    }

    await _runBatch([_currentParams()]);
  }

  /// Runs alto vs baixo xG with the same seed and economy preset.
  Future<void> compareXgPresets() async {
    await _runBatch([
      _paramsWith(matchPreset: SimulationLabMatchPreset.highScoring),
      _paramsWith(matchPreset: SimulationLabMatchPreset.lowScoring),
    ]);
  }

  /// Runs generosa vs apertada economy with the same seed and xG preset.
  Future<void> compareEconomyPresets() async {
    await _runBatch([
      _paramsWith(economyPreset: SimulationLabEconomyPreset.generous),
      _paramsWith(economyPreset: SimulationLabEconomyPreset.tight),
    ]);
  }

  Future<void> _runBatch(List<SimulationLabParams> batch) async {
    if (running) {
      return;
    }

    running = true;
    error = null;
    notifyListeners();

    try {
      for (final params in batch) {
        final result = await _execute(params);
        if (result != null) {
          _recordRun(result);
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      running = false;
      notifyListeners();
    }
  }

  SimulationLabParams _currentParams() => _paramsWith();

  SimulationLabParams _paramsWith({
    SimulationLabMatchPreset? matchPreset,
    SimulationLabEconomyPreset? economyPreset,
  }) {
    return SimulationLabParams(
      worldId: 'lab-${DateTime.now().millisecondsSinceEpoch}',
      mode: mode,
      amount: amount,
      seed: seed,
      matchPreset: matchPreset ?? this.matchPreset,
      economyPreset: economyPreset ?? this.economyPreset,
    );
  }

  Future<SimulationLabReport?> _execute(SimulationLabParams params) async {
    final useIsolate = _shouldRunInIsolate(params);
    return useIsolate
        ? await Isolate.run(() => executeSimulationLab(params))
        : await executeSimulationLab(params);
  }

  void _recordRun(SimulationLabReport result) {
    report = result;
    history.insert(0, SimulationLabRunSummary.fromReport(result));
    if (history.length > maxHistory) {
      history.removeLast();
    }
  }

  bool _shouldRunInIsolate(SimulationLabParams params) {
    return switch (params.mode) {
      SimulationLabMode.untilSeasonEnd => false,
      SimulationLabMode.seasons => params.amount >= 5,
      SimulationLabMode.days => params.amount >= 100,
    };
  }
}
