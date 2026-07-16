/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
/// Validar: `./scripts/check_app_version_sync.sh`
abstract final class AppVersion {
  static const label = '0.8.23';
  static const buildNumber = 24;
  static const engineLabel = 'PSE v0.8.23';

  /// Pontos curtos para o diálogo «Novidades» após actualizar.
  static const whatsNew = <String>[
    'Aviso ao sair com alterações por guardar (guardar / sair / cancelar).',
    'Progresso do roteiro beta visível no menu e no drawer (ex. 2/5).',
    'Botão «Voltar» do sistema também pede confirmação se houver por guardar.',
  ];

  /// Bloco curto para emails de feedback / bugs.
  static String feedbackTemplate({
    String? playMode,
    int? saveSlot,
    String? betaChecklistSummary,
  }) {
    final buffer = StringBuffer()
      ..writeln('Project Phoenix Manager $label ($buildNumber)')
      ..writeln(engineLabel);
    if (playMode != null) {
      buffer.writeln('Modo: $playMode');
    }
    if (saveSlot != null) {
      buffer.writeln('Slot: ${saveSlot + 1}');
    }
    if (betaChecklistSummary != null && betaChecklistSummary.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(betaChecklistSummary);
    }
    buffer
      ..writeln()
      ..writeln('O que aconteceu:')
      ..writeln()
      ..writeln('Passos:')
      ..writeln()
      ..writeln('Modelo do telemóvel:');
    return buffer.toString();
  }
}
