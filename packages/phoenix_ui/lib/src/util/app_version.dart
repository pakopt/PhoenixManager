/// Versão visível ao jogador — manter alinhada com `apps/phoenix_manager/pubspec.yaml`.
/// Validar: `./scripts/check_app_version_sync.sh`
abstract final class AppVersion {
  static const label = '0.8.41';
  static const buildNumber = 42;
  static const engineLabel = 'PSE v0.8.41';

  /// Pontos curtos para o diálogo «Novidades» após actualizar.
  static const whatsNew = <String>[
    'Transferências FootSim: Mercado, Livres e Histórico.',
    'Fazer oferta / assinar a custo zero (janela aberta).',
    'Resumo de orçamento, salários, saldo e plantel.',
    'Pesquisa e fichas de jogadores no mercado.',
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
