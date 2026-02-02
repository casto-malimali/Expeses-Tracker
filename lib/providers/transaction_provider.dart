import 'package:flutter/material.dart';
import '../services/db_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DBService _db = DBService();

  List<Map> _items = [];

  // 1. Add this getter to allow the UI to access the data
  List<Map> get items => _items;

  void load() {
    _items = _db.getAll();
    notifyListeners();
  }

  Future<void> add(Map<String, dynamic> data) async {
    await _db.add(data);
    load();
  }

  Future<void> delete(int key) async {
    await _db.delete(key);
    load();
  }

  Future<void> clearAll() async {
    final allItems = _db.getAll();
    for (final item in allItems) {
      // Ensuring we grab the correct key for deletion
      final dynamic k = item['key'] ?? item['id'];
      if (k is int) {
        await _db.delete(k);
      }
    }
    load();
  }
}
