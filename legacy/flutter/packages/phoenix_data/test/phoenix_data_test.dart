import 'package:phoenix_data/phoenix_data.dart';
import 'package:test/test.dart';

void main() {
  group('ConfigLoader', () {
    test('loads YAML config', () {
      const yaml = '''
engineVersion: 0.1.0-alpha
sport: football
defaultSeed: 99
simulation:
  daysPerWeek: 7
  weeksPerSeason: 34
''';
      final config = ConfigLoader().loadFromYaml(yaml);
      expect(config.sport, 'football');
      expect(config.defaultSeed, 99);
      expect(config.simulation.weeksPerSeason, 34);
    });
  });

  group('EconomyConfigLoader', () {
    test('loads economy YAML config', () {
      const yaml = '''
finance:
  dailySponsorIncome: 2000
transfer:
  windowMonths: [1, 7]
youth:
  baseIntakePerClub: 3
injury:
  matchInjuryChance: 0.05
''';
      final config = EconomyConfigLoader().loadFromYaml(yaml);
      expect(config.finance.dailySponsorIncome, 2000);
      expect(config.transfer.windowMonths, [1, 7]);
      expect(config.youth.baseIntakePerClub, 3);
      expect(config.injury.matchInjuryChance, 0.05);
    });
  });

  group('InMemoryDatabase', () {
    test('stores and exports entities', () async {
      final db = InMemoryDatabase();
      await db.open(packId: 'test-pack');
      await db.writeOverride('clubs', 'club-1', {'name': 'Phoenix FC'});

      final entity = await db.readEntity('clubs', 'club-1');
      expect(entity?['name'], 'Phoenix FC');

      final snapshot = await db.exportSnapshot();
      expect(snapshot['packId'], 'test-pack');
    });
  });
}
