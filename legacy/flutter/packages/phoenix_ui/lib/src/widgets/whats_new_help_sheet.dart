import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/util/app_version.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// «O que há de novo» — uma vez por versão após actualizar a app.
abstract final class WhatsNewHelp {
  static const prefsKey = 'phoenix_last_seen_version';

  /// Marca a versão actual como vista (sem diálogo).
  static Future<void> markCurrent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, AppVersion.label);
  }

  /// Mostra se a versão instalada é diferente da última vista.
  /// Devolve `true` se mostrou o diálogo.
  static Future<bool> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(prefsKey);
    if (lastSeen == AppVersion.label) {
      return false;
    }
    if (!context.mounted) {
      return false;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Novidades · ${AppVersion.label}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in AppVersion.whatsNew)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(line)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    await prefs.setString(prefsKey, AppVersion.label);
    return true;
  }
}
