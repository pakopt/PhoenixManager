import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dica dispensável no dashboard para novos jogadores.
class DashboardTipCard extends StatefulWidget {
  const DashboardTipCard({
    required this.playMode,
    required this.matchesPlayed,
    super.key,
  });

  final PlayMode playMode;
  final int matchesPlayed;

  @override
  State<DashboardTipCard> createState() => _DashboardTipCardState();
}

class _DashboardTipCardState extends State<DashboardTipCard> {
  static const _prefsKey = 'phoenix_dashboard_tip_dismissed';

  var _dismissed = true;
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _dismissed = prefs.getBool(_prefsKey) ?? false;
      _loaded = true;
    });
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
    if (!mounted) {
      return;
    }
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _dismissed || widget.matchesPlayed > 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isExpress = widget.playMode == PlayMode.express;
    final body = isExpress
        ? 'Toca em «Simular jornada» para avançar vários jogos de uma vez. '
            'O teu jogo aparece com animação Express.'
        : 'Usa «Avançar 1 dia» para gerir o clube no dia a dia, ou '
            '«Ir ao próximo jogo» para saltar directamente ao calendário.';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Primeiros passos',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar dica',
                    onPressed: _dismiss,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              Text(body, style: theme.textTheme.bodySmall),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _dismiss,
                  child: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
