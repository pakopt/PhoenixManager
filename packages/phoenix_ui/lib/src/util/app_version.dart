/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
abstract final class AppVersion {
  static const label = '0.8.19';
  static const buildNumber = 20;
  static const engineLabel = 'PSE v0.8.19';

  /// Bloco curto para emails de feedback / bugs.
  static String feedbackTemplate({
    String? playMode,
    int? saveSlot,
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
