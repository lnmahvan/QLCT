import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class StatisticsSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final Function(String) onSelectType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsSummary({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.onSelectType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    double totalIncome = 0;
    double totalExpense = 0;

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

    for (var t in filtered) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: () => onSelectType('income'),
            child: Column(
              children: [
                const Text('Tổng thu',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  formatCurrency.format(totalIncome),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        selectedChartType == 'income' ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onSelectType('expense'),
            child: Column(
              children: [
                const Text('Tổng chi',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                Text(
                  formatCurrency.format(totalExpense),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        selectedChartType == 'expense' ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}