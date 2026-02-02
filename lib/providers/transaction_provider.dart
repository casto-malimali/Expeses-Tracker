import 'package:flutter/material.dart';
import '../services/db_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DBService _db = DBService();

  List<Map> _items = [];
  List<int> _keys = [];

  DateTime _selectedMonth = DateTime.now();

  List<Map> get items => _items;
  List<int> get keys => _keys;

  DateTime get selectedMonth => _selectedMonth;

  void load() {
    _items = _db.getAll();
    _keys = _db.keys;
    notifyListeners();
  }

  void changeMonth(DateTime date) {
    _selectedMonth = date;
    notifyListeners();
  }

  List<Map> get monthlyItems {
    final result = <Map>[];

    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final date = DateTime.parse(item['date']);

      if (date.month == _selectedMonth.month &&
          date.year == _selectedMonth.year) {
        result.add({...item, '_key': _keys[i]});
      }
    }

    return result;
  }

  Future<void> add(Map<String, dynamic> data) async {
    await _db.add(data);
    load();
  }

  Future<void> update(int key, Map<String, dynamic> data) async {
    await _db.update(key, data);
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
