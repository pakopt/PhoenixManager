import 'package:flutter/material.dart';
import 'package:phoenix_ui/src/game/game_controller.dart';
import 'package:phoenix_ui/src/util/ui_feedback.dart';

/// Confirma saída / menu / carga quando há alterações por guardar.
abstract final class UnsavedLeaveHelp {
  /// `true` = pode continuar (guardou, descartou, ou não havia alterações).
  static Future<bool> confirmLeave(
    BuildContext context,
    GameController controller, {
    String title = 'Sair sem guardar?',
    String body =
        'Há alterações por guardar. Queres guardar a carreira antes de sair?',
    String discardLabel = 'Sair sem guardar',
    String saveLabel = 'Guardar e sair',
  }) async {
    if (!controller.hasUnsavedChanges) {
      return true;
    }

    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.cancel),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.discard),
            child: Text(discardLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, _LeaveChoice.save),
            child: Text(saveLabel),
          ),
        ],
      ),
    );

    switch (choice) {
      case null:
      case _LeaveChoice.cancel:
        return false;
      case _LeaveChoice.discard:
        return true;
      case _LeaveChoice.save:
        await controller.saveGame();
        if (context.mounted) {
          UiFeedback.action();
        }
        return true;
    }
  }
}

enum _LeaveChoice { cancel, discard, save }
