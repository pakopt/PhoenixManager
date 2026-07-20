import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dica dispensável no dashboard para novos jogadores (rodízio nos primeiros jogos).
class DashboardTipCard extends StatefulWidget {
  const DashboardTipCard({
    required this.playMode,
    required this.matchesPlayed,
    super.key,
  });

  final PlayMode playMode;
  final int matchesPlayed;

  /// Mostra dicas até ao 3.º jogo (inclusive após o 1.º clique Express).
  static const maxMatchesForTips = 3;

  @override
  State<DashboardTipCard> createState() => _DashboardTipCardState();
}

class _DashboardTipCardState extends State<DashboardTipCard> {
  static const _prefsKey = 'phoenix_dashboard_tip_dismissed';
  static const _indexKey = 'phoenix_dashboard_tip_index';

  var _dismissed = true;
  var _loaded = false;
  var _tipIndex = 0;

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
      _tipIndex = prefs.getInt(_indexKey) ?? 0;
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

  Future<void> _nextTip(int tipCount) async {
    final next = (_tipIndex + 1) % tipCount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_indexKey, next);
    if (!mounted) {
      return;
    }
    setState(() => _tipIndex = next);
  }

  List<({String title, String body})> _tips() {
    final isExpress = widget.playMode == PlayMode.express;
    return [
      (
        title: 'Primeiros passos',
        body: isExpress
            ? 'Toca em «Simular jornada» para avançar vários jogos de uma vez. '
                'O teu jogo aparece com animação Express.'
            : 'Usa «Avançar 1 dia» para gerir o clube no dia a dia, ou '
                '«Ir ao próximo jogo» para saltar directamente ao calendário.',
      ),
      (
        title: 'Guarda a carreira',
        body: 'No menu (⋯) → «Guardar carreira». Em PC podes usar Ctrl/⌘+S '
            'para guardar no slot activo.',
      ),
      (
        title: 'Plantel e treino',
        body: 'No Plantel vês lesões e contratos a expirar. Em Treinos, '
            'prioriza jogadores com margem CA → PA.',
      ),
      (
        title: 'Mercado e finanças',
        body: 'A janela de transferências só abre em certos meses. '
            'Em Finanças verifica o rácio FFP (salários / receita).',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded ||
        _dismissed ||
        widget.matchesPlayed >= DashboardTipCard.maxMatchesForTips) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final tips = _tips();
    final tip = tips[_tipIndex % tips.length];

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
                      tip.title,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    '${(_tipIndex % tips.length) + 1}/${tips.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar dica',
                    onPressed: _dismiss,
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
              Text(tip.body, style: theme.textTheme.bodySmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _nextTip(tips.length),
                    child: const Text('Próxima dica'),
                  ),
                  TextButton(
                    onPressed: _dismiss,
                    child: const Text('Entendi'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
