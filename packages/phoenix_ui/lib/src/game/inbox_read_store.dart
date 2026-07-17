import 'package:shared_preferences/shared_preferences.dart';

/// Persistência local de mensagens lidas na Inbox (por slot de save).
abstract final class InboxReadStore {
  static const _prefix = 'phoenix_inbox_read_';

  static String _key(int slot) => '$_prefix$slot';

  static Future<Set<String>> loadReadIds(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key(slot)) ?? const <String>[];
    return list.toSet();
  }

  static Future<void> markRead(int slot, String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key(slot)) ?? <String>[]).toSet()
      ..add(id);
    await prefs.setStringList(_key(slot), set.toList());
  }

  static Future<void> markAllRead(int slot, Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key(slot)) ?? <String>[]).toSet()
      ..addAll(ids);
    await prefs.setStringList(_key(slot), set.toList());
  }

  static Future<void> clearSlot(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(slot));
  }
}
