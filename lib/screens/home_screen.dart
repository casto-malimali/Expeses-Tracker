import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  double _totalIncome(List items) {
    return items
        .where((e) => e['isIncome'] == true)
        .fold(0.0, (sum, e) => sum + e['amount']);
  }

  double _totalExpense(List items) {
    return items
        .where((e) => e['isIncome'] == false)
        .fold(0.0, (sum, e) => sum + e['amount']);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final items = provider.items;

        final income = _totalIncome(items);
        final expense = _totalExpense(items);
        final balance = income - expense;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Income & Expense Tracker'),
            centerTitle: true,
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
                // Summary Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _summaryCard('Income', income, Colors.green),
                    _summaryCard('Expense', expense, Colors.red),
                    _summaryCard('Balance', balance, Colors.blue),
                  ],
                ),

                const SizedBox(height: 20),

                // Transaction List
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  item['isIncome']
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: item['isIncome']
                                      ? Colors.green
                                      : Colors.red,
                                ),

                                title: Text(item['category']),
                                subtitle: Text(item['note']),

                                trailing: Text(
                                  item['amount'].toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(String title, double amount, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                amount.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
