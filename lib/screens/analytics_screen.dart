import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final items = provider.monthlyItems;

        final expenses = items.where((e) => e['isIncome'] == false);

        final Map<String, double> categoryTotals = {};

        for (var e in expenses) {
          final cat = e['category'];
          final amount = e['amount'];

          categoryTotals[cat] = (categoryTotals[cat] ?? 0) + amount;
        }

        final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);

        return Scaffold(
          appBar: AppBar(title: const Text('Analytics')),

          body: items.isEmpty
              ? const Center(child: Text('No data for this month'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Expense by Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: PieChart(
                        PieChartData(
                          sections: _buildSections(
                            categoryTotals,
                            totalExpense,
                          ),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'Monthly Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 250,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,

                          barTouchData: BarTouchData(enabled: true),

                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  if (value == 0) {
                                    return const Text('Income');
                                  } else {
                                    return const Text('Expense');
                                  }
                                },
                              ),
                            ),
                          ),

                          borderData: FlBorderData(show: false),

                          barGroups: _buildBars(items),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // Pie chart sections
  List<PieChartSectionData> _buildSections(
    Map<String, double> data,
    double total,
  ) {
    int i = 0;

    return data.entries.map((e) {
      final percent = (e.value / total) * 100;

      final colors = [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
      ];

      final color = colors[i++ % colors.length];

      return PieChartSectionData(
        value: e.value,
        title: '${percent.toStringAsFixed(1)}%',
        color: color,
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  // Bar chart
  List<BarChartGroupData> _buildBars(List items) {
    double income = 0;
    double expense = 0;

    for (var e in items) {
      if (e['isIncome']) {
        income += e['amount'];
      } else {
        expense += e['amount'];
      }
    }

    return [
      BarChartGroupData(
        x: 0,
        barRods: [BarChartRodData(toY: income, width: 25)],
      ),

      BarChartGroupData(
        x: 1,
        barRods: [BarChartRodData(toY: expense, width: 25)],
      ),
    ];
  }
}
