import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class StatisticsCategoryList extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedChartType;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const StatisticsCategoryList({
    super.key,
    required this.expense,
    required this.selectedChartType,
    required this.filter,
    this.customRange,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

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

    return ListView(
      children: currentCategory.entries
          .map(
            (e) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.primaries[
                    currentCategory.keys.toList().indexOf(e.key) %
                        Colors.primaries.length],
                child: const Icon(Icons.category, color: Colors.white),
              ),
              title: Text(e.key),
              trailing: Text(
                '${formatCurrency.format(e.value)}  (${(e.value / (currentTotal == 0 ? 1 : currentTotal) * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }
}