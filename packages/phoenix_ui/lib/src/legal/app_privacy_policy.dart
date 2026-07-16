/// Texto da política de privacidade (espelha docs/PRIVACY.md).
abstract final class AppPrivacyPolicy {
  static const version = '0.8.23';
  static const updated = '16 de Julho de 2026';
  static const contactEmail = 'pakopt7@gmail.com';

  static const sections = <({String title, String body})>[
    (
      title: 'Resumo',
      body:
          'O Project Phoenix Manager é um jogo de gestão desportiva offline-first. '
          'Não recolhemos dados pessoais, não usamos analytics de terceiros '
          'e não enviamos informação para servidores externos.',
    ),
    (
      title: 'Dados no dispositivo',
      body:
          'Saves de carreira e preferências da app ficam apenas no teu dispositivo '
          '(SharedPreferences / UserDefaults). Os saves contêm estado do jogo simulado '
          '— clubes, jogadores, calendário, finanças — e não incluem nome, email, '
          'localização nem identificadores reais.',
    ),
    (
      title: 'O que não recolhemos',
      body:
          'Conta ou login · GPS · contactos ou fotos · publicidade · '
          'telemetria para servidores externos.',
    ),
    (
      title: 'Terceiros',
      body:
          'Não vendemos, alugamos nem partilhamos dados. '
          'Não há SDKs de analytics ou publicidade nesta versão.',
    ),
    (
      title: 'Apagar dados',
      body:
          'Android: Definições → Apps → Phoenix Manager → Limpar dados.\n'
          'macOS: apagar preferências da app ou reinstalar.\n'
          'No jogo: menu carreira → apagar slot de save.',
    ),
    (
      title: 'Contacto',
      body: 'Questões sobre privacidade: $contactEmail',
    ),
  ];
}
