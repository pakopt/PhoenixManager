import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/simulation_lab_controller.dart';
import 'package:phoenix_ui/src/game/simulation_lab_presets.dart';
import 'package:phoenix_ui/src/game/simulation_lab_report.dart';
import 'package:phoenix_ui/src/widgets/simulation_lab_compare_card.dart';
import 'package:phoenix_ui/src/widgets/simulation_lab_result_card.dart';

class SimulationLabScreen extends StatefulWidget {
  const SimulationLabScreen({super.key});

  @override
  State<SimulationLabScreen> createState() => _SimulationLabScreenState();
}

class _SimulationLabScreenState extends State<SimulationLabScreen> {
  final SimulationLabController _controller = SimulationLabController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratório de simulação'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: _controller.running ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Balanceamento headless',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Corre simulações num mundo isolado — não afecta os teus saves.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Preset xG', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<SimulationLabMatchPreset>(
                      value: _controller.matchPreset,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: SimulationLabMatchPreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(preset.label),
                            ),
                          )
                          .toList(),
                      onChanged: _controller.running
                          ? null
                          : (value) {
                              if (value != null) {
                                _controller.setMatchPreset(value);
                              }
                            },
                    ),
                    Text(
                      _controller.matchPreset.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Preset economia', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<SimulationLabEconomyPreset>(
                      value: _controller.economyPreset,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: SimulationLabEconomyPreset.values
                          .map(
                            (preset) => DropdownMenuItem(
                              value: preset,
                              child: Text(preset.label),
                            ),
                          )
                          .toList(),
                      onChanged: _controller.running
                          ? null
                          : (value) {
                              if (value != null) {
                                _controller.setEconomyPreset(value);
                              }
                            },
                    ),
                    Text(
                      _controller.economyPreset.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Modo', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SegmentedButton<SimulationLabMode>(
                      segments: SimulationLabMode.values
                          .map(
                            (mode) => ButtonSegment(
                              value: mode,
                              label: Text(mode.label),
                            ),
                          )
                          .toList(),
                      selected: {_controller.mode},
                      onSelectionChanged: _controller.running
                          ? null
                          : (selection) {
                              _controller.setMode(selection.first);
                            },
                    ),
                    if (_controller.mode != SimulationLabMode.untilSeasonEnd) ...[
                      const SizedBox(height: 16),
                      Text(
                        _controller.mode == SimulationLabMode.seasons
                            ? 'Épocas: ${_controller.amount}'
                            : 'Dias: ${_controller.amount}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Slider(
                        value: _controller.amount.toDouble(),
                        min: 1,
                        max: _controller.mode == SimulationLabMode.seasons
                            ? 100
                            : 300,
                        divisions: _controller.mode == SimulationLabMode.seasons
                            ? 99
                            : 299,
                        label: '${_controller.amount}',
                        onChanged: _controller.running
                            ? null
                            : (value) {
                                _controller.setAmount(value.round());
                              },
                      ),
                      if (_controller.mode == SimulationLabMode.seasons &&
                          _controller.amount >= 5)
                        Text(
                          'Corre em background (≥5 épocas) para não bloquear a UI.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                    ],
                    const SizedBox(height: 8),
                    Text('Seed: ${_controller.seed}',
                        style: theme.textTheme.titleSmall),
                    Slider(
                      value: _controller.seed.toDouble(),
                      min: 1,
                      max: 999,
                      divisions: 998,
                      label: '${_controller.seed}',
                      onChanged: _controller.running
                          ? null
                          : (value) {
                              _controller.setSeed(value.round());
                            },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _controller.running
                              ? null
                              : _controller.compareXgPresets,
                          icon: const Icon(Icons.sports_soccer, size: 18),
                          label: const Text('Comparar xG'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _controller.running
                              ? null
                              : _controller.compareEconomyPresets,
                          icon: const Icon(Icons.euro, size: 18),
                          label: const Text('Comparar economia'),
                        ),
                      ],
                    ),
                    Text(
                      'Corre 2 simulações (mesma seed) e adiciona ao histórico.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _controller.running ? null : _controller.run,
                      icon: _controller.running
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(
                        _controller.running ? 'A simular…' : 'Correr simulação',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_controller.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _controller.error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ),
            ],
            if (_controller.history.length >= 2) ...[
              const SizedBox(height: 16),
              SimulationLabCompareCard(
                runs: _controller.history,
                onClear: _controller.clearHistory,
              ),
            ],
            if (_controller.report != null) ...[
              const SizedBox(height: 16),
              SimulationLabResultCard(report: _controller.report!),
            ],
          ],
        ),
      ),
    );
  }
}
