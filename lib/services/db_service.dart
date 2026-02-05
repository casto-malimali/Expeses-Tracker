import 'package:hive/hive.dart';

class DBService {
  final Box _box = Hive.box('transactions');

  Future<void> add(Map<String, dynamic> data) async {
    await _box.add(data);
  }

  List<Map> getAll() {
    return _box.values.cast<Map>().toList();
  }

  Map? getByKey(int key) {
    return _box.get(key);
  }

  Future<void> update(int key, Map<String, dynamic> data) async {
    await _box.put(key, data);
  }

  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  // Add this method to your DBService class
  Future<void> clear() async {
    // Implement the logic to clear all records from your database
    // For example, if using sqflite:
    // final db = await database;
    // await db.delete('your_table_name');
  }

  List<int> get keys => _box.keys.cast<int>().toList();
}
