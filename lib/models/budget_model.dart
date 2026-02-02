class BudgetModel {
  final String category;
  final double limit;
  final String month;

  BudgetModel({
    required this.category,
    required this.limit,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {'category': category, 'limit': limit, 'month': month};
  }

  factory BudgetModel.fromMap(Map map) {
    return BudgetModel(
      category: map['category'],
      limit: map['limit'],
      month: map['month'],
    );
  }
}
