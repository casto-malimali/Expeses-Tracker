import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _ctrl = TextEditingController();

  String _category = 'Food';

  final _categories = [
    'General',
    'Food',
    'Transport',
    'Rent',
    'Salary',
    'Shopping',
  ];

  @override
  void initState() {
    super.initState();

    final month = context.read<TransactionProvider>().selectedMonth;

    context.read<BudgetProvider>().loadForMonth(month);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<TransactionProvider>().selectedMonth;

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Budgets')),

      body: Consumer<BudgetProvider>(
        builder: (context, provider, _) {
          return Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _category,
                  items: _categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Budget Limit'),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    final limit = double.tryParse(_ctrl.text);

                    if (limit == null) return;

                    await context.read<BudgetProvider>().setBudget(
                      selectedMonth,
                      _category,
                      limit,
                    );

                    _ctrl.clear();
                  },
                  child: const Text('Save Budget'),
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView(
                    children: provider.budgets.entries.map((e) {
                      return ListTile(
                        title: Text(e.key),
                        trailing: Text(e.value.toStringAsFixed(2)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
