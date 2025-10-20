import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense_model.dart';

class StatisticsChart extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsChart({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filtered = expense.transactions.where((t) {
      bool matchFilter = false;

      if (filter == 'all') {
        matchFilter = true;
      } else if (filter == 'today') {
        matchFilter = t.date.day == now.day &&
            t.date.month == now.month &&
            t.date.year == now.year;
      } else if (filter == 'month') {
        matchFilter = t.date.month == now.month && t.date.year == now.year;
      } else if (filter == 'custom' && customRange != null) {
        matchFilter = t.date.isAfter(customRange!.start.subtract(const Duration(days: 1))) &&
                      t.date.isBefore(customRange!.end.add(const Duration(days: 1)));
      }

      final matchSearch = t.note.toLowerCase().contains(searchText) ||
          t.category.toLowerCase().contains(searchText);

      return matchFilter && matchSearch;
    }).toList();

    final Map<String, double> categoryIncome = {};
    final Map<String, double> categoryExpense = {};
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in filtered) {
      if (t.type == 'income') {
        totalIncome += t.amount;
        categoryIncome[t.category] = (categoryIncome[t.category] ?? 0) + t.amount;
      } else {
        totalExpense += t.amount;
        categoryExpense[t.category] = (categoryExpense[t.category] ?? 0) + t.amount;
      }
    }

    final currentCategory =
        selectedChartType == 'income' ? categoryIncome : categoryExpense;
    final currentTotal =
        selectedChartType == 'income' ? totalIncome : totalExpense;

    final pieSections = <PieChartSectionData>[];
    currentCategory.forEach((category, amount) {
      final percent = (amount / (currentTotal == 0 ? 1 : currentTotal)) * 100;
      pieSections.add(
        PieChartSectionData(
          value: amount,
          title: '${percent.toStringAsFixed(1)}%',
          color: Colors.primaries[pieSections.length % Colors.primaries.length],
          radius: 80,
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
    });

    return currentCategory.isNotEmpty
        ? SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              selectedChartType == 'income'
                  ? 'Không có dữ liệu thu nhập'
                  : 'Không có dữ liệu chi tiêu',
              style: const TextStyle(color: Colors.grey),
            ),
          );
  }
}