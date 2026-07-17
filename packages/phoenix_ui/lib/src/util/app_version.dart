/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
/// Validar: `./scripts/check_app_version_sync.sh`
abstract final class AppVersion {
  static const label = '0.8.39';
  static const buildNumber = 40;
  static const engineLabel = 'PSE v0.8.39';

  /// Pontos curtos para o diálogo «Novidades» após actualizar.
  static const whatsNew = <String>[
    'GDR «O Sindicato» na Liga Phoenix (Setúbal) — plantel Jun.B completo.',
    'Posições reais nos jogadores; equipamento na ficha do clube.',
    'Classificação com nomes curtos (sem cortar clubes longos).',
    'Geração de plantel com papéis GR/DF/MD/… para o XI.',
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
