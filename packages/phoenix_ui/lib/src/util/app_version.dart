/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
/// Validar: `./scripts/check_app_version_sync.sh`
abstract final class AppVersion {
  static const label = '0.8.37';
  static const buildNumber = 38;
  static const engineLabel = 'PSE v0.8.37';

  /// Pontos curtos para o diálogo «Novidades» após actualizar.
  static const whatsNew = <String>[
    'Táctica: campo redesenhado (áreas, penáltis, faixas) alinhado aos slots.',
    'Marcadores com posição + OVR; sem crash em ecrãs pequenos.',
    'XI automático evita lesionados e escolhe melhor por slot.',
    'Posições no plantel batem certo com a formação.',
  ];

  /// Bloco curto para emails de feedback / bugs.
  static String feedbackTemplate({
    String? playMode,
    int? saveSlot,
    String? betaChecklistSummary,
  }) {
    final buffer = StringBuffer()
      ..writeln('Phoenix Manager $label ($buildNumber)')
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
