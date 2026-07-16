import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phoenix_ui/src/util/app_version.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Roteiro curto para testadores do teste fechado Play.
abstract final class BetaChecklistHelp {
  static const prefsPrefix = 'phoenix_beta_check_';

  static const items = <({String id, String title, String detail})>[
    (
      id: 'career',
      title: 'Iniciar ou continuar carreira',
      detail: 'Menu → Jogar agora / Continuar save',
    ),
    (
      id: 'play',
      title: 'Simular um jogo ou jornada',
      detail: 'Express: «Simular jornada» · Diretor: avançar dias / próximo jogo',
    ),
    (
      id: 'squad',
      title: 'Abrir Plantel e Classificação',
      detail: 'Confirma lista, pesquisa e tabela da liga',
    ),
    (
      id: 'save',
      title: 'Guardar carreira',
      detail: 'Menu (⋯) → Guardar · em PC: Ctrl/⌘+S',
    ),
    (
      id: 'feedback',
      title: 'Provar Feedback / reportar bug',
      detail: 'Menu → copia o modelo e (se quiseres) envia a pakopt7@gmail.com',
    ),
  ];

  static const contact = 'pakopt7@gmail.com';

  /// Contagem para badges (ex. «2/5»).
  static Future<({int done, int total})> progressCounts() async {
    final prefs = await SharedPreferences.getInstance();
    var done = 0;
    for (final item in items) {
      if (prefs.getBool('$prefsPrefix${item.id}') ?? false) {
        done++;
      }
    }
    return (done: done, total: items.length);
  }

  /// Resumo para emails de feedback (ex. «Roteiro beta: 3/5»).
  static Future<String> progressSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final done = <String>[];
    for (final item in items) {
      if (prefs.getBool('$prefsPrefix${item.id}') ?? false) {
        done.add(item.title);
      }
    }
    final buffer = StringBuffer('Roteiro beta: ${done.length}/${items.length}');
    for (final title in done) {
      buffer.writeln();
      buffer.write('  [x] $title');
    }
    return buffer.toString();
  }

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => const _BetaChecklistDialog(),
    );
  }
}

/// Botão / tile com progresso «N/total» do roteiro beta.
class BetaChecklistProgressLabel extends StatelessWidget {
  const BetaChecklistProgressLabel({
    required this.builder,
    super.key,
  });

  final Widget Function(BuildContext context, int done, int total) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({int done, int total})>(
      future: BetaChecklistHelp.progressCounts(),
      builder: (context, snap) {
        final done = snap.data?.done ?? 0;
        final total = snap.data?.total ?? BetaChecklistHelp.items.length;
        return builder(context, done, total);
      },
    );
  }
}

class _BetaChecklistDialog extends StatefulWidget {
  const _BetaChecklistDialog();

  @override
  State<_BetaChecklistDialog> createState() => _BetaChecklistDialogState();
}

class _BetaChecklistDialogState extends State<_BetaChecklistDialog> {
  final _checked = <String>{};
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final done = <String>{};
    for (final item in BetaChecklistHelp.items) {
      if (prefs.getBool('${BetaChecklistHelp.prefsPrefix}${item.id}') ?? false) {
        done.add(item.id);
      }
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _checked
        ..clear()
        ..addAll(done);
      _loaded = true;
    });
  }

  Future<void> _toggle(String id, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${BetaChecklistHelp.prefsPrefix}$id', value);
    if (!mounted) {
      return;
    }
    setState(() {
      if (value) {
        _checked.add(id);
      } else {
        _checked.remove(id);
      }
    });
  }

  Future<void> _copySummary(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln('Roteiro beta — Project Phoenix Manager ${AppVersion.label}')
      ..writeln();
    for (final item in BetaChecklistHelp.items) {
      final mark = _checked.contains(item.id) ? '[x]' : '[ ]';
      buffer.writeln('$mark ${item.title}');
    }
    buffer
      ..writeln()
      ..writeln('Contacto: ${BetaChecklistHelp.contact}');
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (!context.mounted) {
      return;
    }
    UiFeedback.action();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Roteiro copiado'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final done = _checked.length;
    final total = BetaChecklistHelp.items.length;

    return AlertDialog(
      title: const Text('Roteiro de teste (beta)'),
      content: SizedBox(
        width: 400,
        child: !_loaded
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Checklist rápido para o teste fechado Play ($done/$total).',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    for (final item in BetaChecklistHelp.items)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _checked.contains(item.id),
                        onChanged: (v) => _toggle(item.id, v ?? false),
                        title: Text(item.title),
                        subtitle: Text(item.detail),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => _copySummary(context),
          child: const Text('Copiar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
