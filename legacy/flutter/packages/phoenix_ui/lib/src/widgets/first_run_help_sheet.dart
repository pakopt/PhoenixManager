import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/play_mode.dart';
import 'package:phoenix_ui/src/widgets/whats_new_help_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Diálogos de ajuda partilhados: modos de jogo (menu) e first-run (shell).
abstract final class PlayModeHelp {
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modos de jogo'),
        content: const _PlayModeHelpBody(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Sheet de primeiros passos — uma vez por instalação, só com carreira a 0 jogos.
abstract final class FirstRunHelp {
  static const prefsKey = 'phoenix_first_run_help_shown';

  /// Devolve `true` se mostrou o diálogo.
  static Future<bool> showIfNeeded(
    BuildContext context, {
    required int matchesPlayed,
  }) async {
    if (matchesPlayed > 0) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(prefsKey) ?? false) {
      return false;
    }
    if (!context.mounted) {
      return false;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Primeiros passos'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlayModeHelpBody(),
              SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.save_outlined),
                title: Text('Guarda a carreira'),
                subtitle: Text(
                  'Menu (⋯) → «Guardar carreira». Em PC: Ctrl/⌘+S no slot activo.',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.feedback_outlined),
                title: Text('Reportar um bug'),
                subtitle: Text(
                  'No mesmo menu: «Feedback / reportar bug» copia um modelo '
                  'para enviares por email.',
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
    await prefs.setBool(prefsKey, true);
    await WhatsNewHelp.markCurrent();
    return true;
  }
}

class _PlayModeHelpBody extends StatelessWidget {
  const _PlayModeHelpBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.flash_on),
          title: const Text('Express'),
          subtitle: Text(PlayMode.express.description),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.manage_accounts),
          title: const Text('Diretor'),
          subtitle: Text(PlayMode.director.description),
        ),
      ],
    );
  }
}
