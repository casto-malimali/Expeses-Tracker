import 'package:hive/hive.dart';

class BudgetService {
  final Box _box = Hive.box('budgets');

  Future<void> save(Map<String, dynamic> data) async {
    final key = '${data['month']}_${data['category']}';

    await _box.put(key, data);
  }

  Map? get(String month, String category) {
    final key = '${month}_$category';

    return _box.get(key);
  }

  List<Map> getByMonth(String month) {
    return _box.values.cast<Map>().where((e) {
      return e['month'] == month;
    }).toList();
  }

  void clear() {
    _box.clear();
  }
}
