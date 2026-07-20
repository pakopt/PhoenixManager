/// UI play mode — Express (rápido) vs Diretor (completo).
enum PlayMode {
  express,
  director,
}

extension PlayModeLabel on PlayMode {
  String get label => switch (this) {
        PlayMode.express => 'Express',
        PlayMode.director => 'Diretor',
      };

  String get description => switch (this) {
        PlayMode.express =>
          'Avanço rápido — highlights essenciais, gestão automática.',
        PlayMode.director =>
          'Controlo total — todos os ecrãs e detalhes disponíveis.',
      };
}

/// Max highlights shown in Express mode (GDD: 5–8).
const expressHighlightLimit = 6;
