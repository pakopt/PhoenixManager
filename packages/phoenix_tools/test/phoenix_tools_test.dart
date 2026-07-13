import 'package:phoenix_core/phoenix_core.dart';
import 'package:phoenix_engine/phoenix_engine.dart';
import 'package:phoenix_tools/phoenix_tools.dart';
import 'package:test/test.dart';

void main() {
  group('SimulationLab', () {
    test('runs 100 seasons headless for CI benchmark', () async {
      final context = await AppBootstrap().boot(worldId: 'lab-world');
      final lab = SimulationLab(context: context);

      final result = lab.runSeasons(100);
      expect(result.daysSimulated, 7 * 38 * 100);
      expect(result.endTick, result.startTick + result.daysSimulated);
    }, timeout: Timeout(Duration(minutes: 2)));
  });

  group('PlayerValueService', () {
    test('higher CA yields higher value', () {
      const service = PlayerValueService();
      const club = Club(
        id: ClubId('c1'),
        name: 'Test',
        cityId: CityId('city1'),
        reputation: 70,
      );
      const star = Player(
        id: PlayerId('p1'),
        name: 'Star',
        clubId: ClubId('c1'),
        age: 25,
        currentAbility: 80,
        potentialAbility: 85,
      );
      const average = Player(
        id: PlayerId('p2'),
        name: 'Average',
        clubId: ClubId('c1'),
        age: 25,
        currentAbility: 60,
        potentialAbility: 65,
      );

      expect(
        service.calculate(star, club: club),
        greaterThan(service.calculate(average, club: club)),
      );
    });
  });
}
