import 'package:phoenix_data/src/database/database_adapter.dart';

/// In-memory database for Alpha v0.1 (SQLite arrives in Fase A.2).
class InMemoryDatabase implements DatabaseAdapter {
  final Map<String, Map<String, Map<String, dynamic>>> _tables = {};
  String? _packId;

  @override
  Future<void> open({required String packId}) async {
    _packId = packId;
  }

  @override
  Future<Map<String, dynamic>?> readEntity(String table, String id) async {
    return _tables[table]?[id];
  }

  @override
  Future<void> writeOverride(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final tableMap = _tables.putIfAbsent(table, () => {});
    tableMap[id] = Map<String, dynamic>.from(data);
  }

  @override
  Future<Map<String, dynamic>> exportSnapshot() async {
    return {
      'packId': _packId,
      'tables': _tables.map(
        (table, rows) => MapEntry(table, Map<String, dynamic>.from(rows)),
      ),
    };
  }

  @override
  Future<void> importSnapshot(Map<String, dynamic> snapshot) async {
    _packId = snapshot['packId'] as String?;
    _tables.clear();
    final tables = snapshot['tables'] as Map<dynamic, dynamic>? ?? {};
    for (final entry in tables.entries) {
      final tableName = entry.key as String;
      final rows = Map<String, dynamic>.from(entry.value as Map);
      _tables[tableName] = rows.map(
        (id, data) => MapEntry(
          id,
          Map<String, dynamic>.from(data as Map),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    _tables.clear();
    _packId = null;
  }
}
