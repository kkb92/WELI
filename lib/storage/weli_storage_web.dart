// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:indexed_db' as idb;

class WeliStorage {
  static const String _dbName = 'weli_rechner_indexeddb';
  static const String _storeName = 'key_value';
  static Future<idb.Database>? _dbFuture;

  static Future<idb.Database> _database() {
    _dbFuture ??= html.window.indexedDB!.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (idb.VersionChangeEvent event) {
        final request = event.target as idb.Request;
        final db = request.result as idb.Database;
        if (!db.objectStoreNames!.contains(_storeName)) {
          db.createObjectStore(_storeName);
        }
      },
    );
    return _dbFuture!;
  }

  static Future<String?> getString(String key) async {
    final db = await _database();
    final transaction = db.transaction(_storeName, 'readonly');
    final store = transaction.objectStore(_storeName);
    final value = await store.getObject(key);
    await transaction.completed;
    return value as String?;
  }

  static Future<void> setString(String key, String value) async {
    final db = await _database();
    final transaction = db.transaction(_storeName, 'readwrite');
    final store = transaction.objectStore(_storeName);
    await store.put(value, key);
    await transaction.completed;
  }

  static Future<void> remove(String key) async {
    final db = await _database();
    final transaction = db.transaction(_storeName, 'readwrite');
    final store = transaction.objectStore(_storeName);
    await store.delete(key);
    await transaction.completed;
  }
}
