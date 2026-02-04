import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

import 'analytics_screen.dart';
import '../services/export_service.dart';

import '../providers/budget_provider.dart';
import 'budget_screen.dart';

import 'security_settings_screen.dart';

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
        // final items = provider.items;
        final items = provider.monthlyItems;
        final selectedMonth = provider.selectedMonth;

        final income = _totalIncome(items);
        final expense = _totalExpense(items);
        final balance = income - expense;

        return Scaffold(
          // appBar: AppBar(
          //   title: const Text('Income & Expense Tracker'),
          //   centerTitle: true,
          // ),
          appBar: AppBar(
            title: const Text('Income & Expense Tracker'),
            centerTitle: true,

            actions: [
              // IconButton(
              //   icon: const Icon(Icons.bar_chart),
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
              //     );
              //   },
              // ),
              // Analytics
              PopupMenuButton<String>(
                onSelected: (v) async {
                  final provider = context.read<TransactionProvider>();

                  if (v == 'backup') {
                    await provider.backupToCloud();
                  }

                  if (v == 'restore') {
                    await provider.restoreFromCloud();
                  }
                },

                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'backup',
                    child: Text('Backup to Cloud'),
                  ),

                  const PopupMenuItem(
                    value: 'restore',
                    child: Text('Restore from Cloud'),
                  ),
                ],
              ),

              // Export
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final provider = context.read<TransactionProvider>();

                  final items = provider.monthlyItems;

                  final month = DateFormat(
                    'yyyy_MM',
                  ).format(provider.selectedMonth);

                  if (items.isEmpty) return;

                  if (value == 'pdf') {
                    await ExportService.exportToPDF(items, month);
                  }

                  if (value == 'excel') {
                    await ExportService.exportToExcel(items, month);
                  }
                },

                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'pdf', child: Text('Export PDF')),

                  const PopupMenuItem(
                    value: 'excel',
                    child: Text('Export Excel'),
                  ),
                ],
              ),
            ],
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
                // Month Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final prev = DateTime(
                          selectedMonth.year,
                          selectedMonth.month - 1,
                        );

                        context.read<TransactionProvider>().changeMonth(prev);
                        context.read<BudgetProvider>().loadForMonth(
                          selectedMonth,
                        );
                      },
                    ),

                    GestureDetector(
                      onTap: () => _pickMonth(context, selectedMonth),
                      child: Text(
                        DateFormat('MMMM yyyy').format(selectedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final next = DateTime(
                          selectedMonth.year,
                          selectedMonth.month + 1,
                        );

                        context.read<TransactionProvider>().changeMonth(next);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
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

                Consumer2<TransactionProvider, BudgetProvider>(
                  builder: (context, tx, budget, _) {
                    final items = tx.monthlyItems;

                    final spent = <String, double>{};

                    for (var e in items) {
                      if (!e['isIncome']) {
                        spent[e['category']] =
                            (spent[e['category']] ?? 0) + e['amount'];
                      }
                    }

                    if (budget.budgets.isEmpty) return const SizedBox();

                    return Column(
                      children: budget.budgets.entries.map((e) {
                        final used = spent[e.key] ?? 0;
                        final limit = e.value;

                        final percent = ((used / limit).clamp(0, 1)).toDouble();

                        final over = used > limit;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${e.key}: ${used.toStringAsFixed(0)} / ${limit.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: over ? Colors.red : null,
                                fontWeight: over ? FontWeight.bold : null,
                              ),
                            ),

                            LinearProgressIndicator(
                              value: percent,
                              color: over ? Colors.red : Colors.green,
                              backgroundColor: Colors.grey[300],
                            ),

                            const SizedBox(height: 8),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),

                // Transaction List
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No transactions yet'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return Dismissible(
                              key: ValueKey(item['_key']),

                              direction: DismissDirection.endToStart,

                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),

                              confirmDismiss: (_) async {
                                return await _confirmDelete(context);
                              },

                              onDismissed: (_) {
                                context.read<TransactionProvider>().delete(
                                  item['_key'],
                                );
                              },

                              child: Card(
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

                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                          transaction: item,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );

                            // return Card(
                            //   child: ListTile(
                            //     leading: Icon(
                            //       item['isIncome']
                            //           ? Icons.arrow_downward
                            //           : Icons.arrow_upward,
                            //       color: item['isIncome']
                            //           ? Colors.green
                            //           : Colors.red,
                            //     ),

                            //     title: Text(item['category']),
                            //     subtitle: Text(item['note']),

                            //     trailing: Text(
                            //       item['amount'].toStringAsFixed(2),
                            //       style: const TextStyle(
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // );
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

Future<void> _pickMonth(BuildContext context, DateTime current) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    initialDatePickerMode: DatePickerMode.year,
  );

  if (picked != null) {
    final selected = DateTime(picked.year, picked.month);

    context.read<TransactionProvider>().changeMonth(selected);
  }
}

Future<bool> _confirmDelete(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text('Are you sure you want to delete this record?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                final provider = context.read<TransactionProvider>();

                if (v == 'backup') {
                  await provider.backupToCloud();
                }

                if (v == 'restore') {
                  await provider.restoreFromCloud();
                }
              },

              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'backup',
                  child: Text('Backup to Cloud'),
                ),

                const PopupMenuItem(
                  value: 'restore',
                  child: Text('Restore from Cloud'),
                ),
              ],
            ),
          ],
        ),
      ) ??
      false;
}
