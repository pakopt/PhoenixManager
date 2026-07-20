/// Abstraction over official DB packs and save overrides.
abstract class DatabaseAdapter {
  Future<void> open({required String packId});

  Future<Map<String, dynamic>?> readEntity(String table, String id);

  Future<void> writeOverride(String table, String id, Map<String, dynamic> data);

  Future<Map<String, dynamic>> exportSnapshot();

  Future<void> importSnapshot(Map<String, dynamic> snapshot);

  Future<void> close();
}
