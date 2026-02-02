import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _service = BudgetService();

  Map<String, double> _budgets = {};

  Map<String, double> get budgets => _budgets;

  void loadForMonth(DateTime date) {
    final month = DateFormat('yyyy-MM').format(date);

    final data = _service.getByMonth(month);

    _budgets = {for (var e in data) e['category']: e['limit']};

    notifyListeners();
  }

  Future<void> setBudget(DateTime date, String category, double limit) async {
    final month = DateFormat('yyyy-MM').format(date);

    final data = {'category': category, 'limit': limit, 'month': month};

    await _service.save(data);

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
