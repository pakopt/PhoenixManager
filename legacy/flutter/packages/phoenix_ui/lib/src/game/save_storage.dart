import 'package:phoenix_ui/src/game/save_slot.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists up to [maxSlots] career saves (web + desktop + mobile).
class SaveStorage {
  SaveStorage({SharedPreferences? preferences}) : _preferences = preferences;

  SharedPreferences? _preferences;
  static const maxSlots = 3;

  Future<SharedPreferences> _prefs() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  String _dataKey(int slot) => 'phoenix_save_v1_$slot';
  String _metaKey(int slot) => 'phoenix_save_meta_v1_$slot';

  Future<List<SaveSlotMeta>> listSlots() async {
    await _migrateLegacySave();
    final prefs = await _prefs();
    final slots = <SaveSlotMeta>[];
    for (var i = 0; i < maxSlots; i++) {
      final metaJson = prefs.getString(_metaKey(i));
      if (metaJson == null) {
        slots.add(SaveSlotMeta.empty(i));
      } else {
        slots.add(SaveSlotMeta.fromJson(i, metaJson));
      }
    }
    return slots;
  }

  Future<bool> hasSave([int slot = 0]) async {
    final prefs = await _prefs();
    return prefs.containsKey(_dataKey(slot));
  }

  Future<bool> hasAnySave() async {
    for (var i = 0; i < maxSlots; i++) {
      if (await hasSave(i)) {
        return true;
      }
    }
    return false;
  }

  Future<void> writeSlot({
    required int slot,
    required String json,
    required SaveSlotMeta meta,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_dataKey(slot), json);
    await prefs.setString(_metaKey(slot), meta.encode());
  }

  Future<String?> readSlot(int slot) async {
    final prefs = await _prefs();
    return prefs.getString(_dataKey(slot));
  }

  Future<void> clearSlot(int slot) async {
    final prefs = await _prefs();
    await prefs.remove(_dataKey(slot));
    await prefs.remove(_metaKey(slot));
  }

  // Legacy single-slot API (slot 0)
  Future<void> write(String json) => writeSlot(
        slot: 0,
        json: json,
        meta: SaveSlotMeta.empty(0),
      );

  Future<String?> read() => readSlot(0);

  Future<void> clear() => clearSlot(0);

  /// Migrates single-slot save from v0.7 key to slot 0.
  Future<void> _migrateLegacySave() async {
    const legacyKey = 'phoenix_manager_career_v1';
    final prefs = await _prefs();
    if (!prefs.containsKey(legacyKey) || prefs.containsKey(_dataKey(0))) {
      return;
    }
    final json = prefs.getString(legacyKey);
    if (json == null) {
      await prefs.remove(legacyKey);
      return;
    }
    await writeSlot(
      slot: 0,
      json: json,
      meta: SaveSlotMeta(
        index: 0,
        clubName: 'Carreira migrada',
        savedAt: DateTime.now(),
        playMode: 'director',
      ),
    );
    await prefs.remove(legacyKey);
  }
}
