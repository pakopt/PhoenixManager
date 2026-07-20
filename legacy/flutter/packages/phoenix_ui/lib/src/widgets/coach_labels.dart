import 'package:phoenix_core/phoenix_core.dart';

extension CoachPersonalityLabel on CoachPersonality {
  String get labelPt => switch (this) {
        CoachPersonality.pragmatist => 'Pragmático',
        CoachPersonality.idealist => 'Idealista',
        CoachPersonality.disciplinarian => 'Disciplinador',
        CoachPersonality.youthDeveloper => 'Formador de jovens',
      };
}

extension CoachLicenseLabel on Coach {
  String get licenseLabel => switch (licenseLevel) {
        1 => 'Licença C',
        2 => 'Licença B',
        3 => 'Licença A',
        4 => 'Licença Pro',
        _ => 'Licença Elite',
      };
}
