import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/budget_service.dart';
import '../services/firebase_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();
  final FirebaseService _firebase = FirebaseService();

  Map<String, double> _budgets = {};

  Map<String, double> get budgets => _budgets;

  void loadForMonth(DateTime date) {
    final month = DateFormat('yyyy-MM').format(date);

    final data = _service.getByMonth(month);

    _budgets = {for (var e in data) e['category']: e['limit']};

    notifyListeners();
  }

  // Future<void> setBudget(DateTime date, String category, double limit) async {
  //   final month = DateFormat('yyyy-MM').format(date);

  //   final data = {'category': category, 'limit': limit, 'month': month};

  //   await _service.save(data);

  //   loadForMonth(date);
  // }
  Future<void> setBudget(DateTime date, String category, double limit) async {
    final month = DateFormat('yyyy-MM').format(date);

    final data = {'category': category, 'limit': limit, 'month': month};

    await _service.save(data);

    loadForMonth(date);

    // Auto Sync
    await _firebase.syncBudgets(
      _budgets.entries.map((e) {
        return {'category': e.key, 'limit': e.value, 'month': month};
      }).toList(),
    );
  }

  Future<void> autoRestore(DateTime date) async {
    final cloud = await _firebase.fetchBudgets();

    if (cloud.isEmpty) return;

    _service.clear();

    for (var e in cloud) {
      await _service.save(e as Map<String, dynamic>);
    }

    loadForMonth(date);
  }

  double? getBudget(String category) {
    return _budgets[category];
  }

  void clear() {
    _service.clear();
    _budgets.clear();
    notifyListeners();
  }
}
