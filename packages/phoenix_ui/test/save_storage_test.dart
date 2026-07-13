import 'package:flutter_test/flutter_test.dart';
import 'package:phoenix_ui/src/game/save_slot.dart';
import 'package:phoenix_ui/src/game/save_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SaveStorage', () {
    late SaveStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = SaveStorage(preferences: await SharedPreferences.getInstance());
    });

    test('listSlots returns 3 empty slots initially', () async {
      final slots = await storage.listSlots();
      expect(slots.length, SaveStorage.maxSlots);
      expect(slots.every((s) => s.isEmpty), isTrue);
    });

    test('summarySubtitle includes season position and trophies', () {
      const meta = SaveSlotMeta(
        index: 0,
        clubName: 'Phoenix FC',
        dateLabel: '2026-11-15',
        seasonYear: 2026,
        leaguePosition: 2,
        leagueTitles: 1,
        cupTitles: 0,
      );

      expect(
        meta.summarySubtitle,
        'Época 2026 · 2º · 2026-11-15 · 1 troféus',
      );
    });

    test('writeSlot and readSlot round-trip', () async {
      const json = '{"world":{},"registry":{}}';
      final meta = SaveSlotMeta(
        index: 1,
        clubName: 'Phoenix FC',
        dateLabel: '2026-08-01',
        tick: 42,
        savedAt: DateTime(2026, 8, 1),
        playMode: 'director',
      );

      await storage.writeSlot(slot: 1, json: json, meta: meta);

      expect(await storage.readSlot(1), json);
      final slots = await storage.listSlots();
      expect(slots[1].clubName, 'Phoenix FC');
      expect(slots[1].tick, 42);
      expect(slots[0].isEmpty, isTrue);
    });

    test('clearSlot removes data and meta', () async {
      await storage.writeSlot(
        slot: 0,
        json: '{}',
        meta: SaveSlotMeta(
          index: 0,
          clubName: 'Test',
          dateLabel: '2026-01-01',
          tick: 1,
          savedAt: DateTime.now(),
        ),
      );
      await storage.clearSlot(0);

      expect(await storage.hasSave(0), isFalse);
      final slots = await storage.listSlots();
      expect(slots[0].isEmpty, isTrue);
    });

    test('hasAnySave detects any filled slot', () async {
      expect(await storage.hasAnySave(), isFalse);
      await storage.writeSlot(
        slot: 2,
        json: '{}',
        meta: SaveSlotMeta(index: 2, clubName: 'X'),
      );
      expect(await storage.hasAnySave(), isTrue);
    });

    test('migrates legacy single-slot save key', () async {
      const legacyKey = 'phoenix_manager_career_v1';
      SharedPreferences.setMockInitialValues({
        legacyKey: '{"world":{},"registry":{}}',
      });
      storage = SaveStorage(
        preferences: await SharedPreferences.getInstance(),
      );

      final slots = await storage.listSlots();
      expect(await storage.readSlot(0), isNotNull);
      expect(slots[0].clubName, 'Carreira migrada');
      expect(
        (await SharedPreferences.getInstance()).containsKey(legacyKey),
        isFalse,
      );
    });
  });
}
