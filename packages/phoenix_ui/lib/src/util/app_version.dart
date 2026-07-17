/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
/// Validar: `./scripts/check_app_version_sync.sh`
abstract final class AppVersion {
  static const label = '0.8.38';
  static const buildNumber = 39;
  static const engineLabel = 'PSE v0.8.38';

  /// Pontos curtos para o diálogo «Novidades» após actualizar.
  static const whatsNew = <String>[
    'Táctica: arrasta jogadores livremente no campo.',
    'Posições guardadas com a táctica; botão «Repor» volta à formação.',
    'Toca no marcador para abrir a ficha do jogador.',
    'Campo estável em telemóvel (scroll bloqueado ao arrastar).',
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
