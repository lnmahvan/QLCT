import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class TransactionSummary extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;

  const TransactionSummary({
    super.key,
    required this.expense,
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
        matchFilter =
            t.date.day == now.day && t.date.month == now.month && t.date.year == now.year;
      } else if (filter == 'month') {
        matchFilter = t.date.month == now.month && t.date.year == now.year;
      } else if (filter == 'custom' && customRange != null) {
        matchFilter = t.date.isAfter(customRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(customRange!.end.add(const Duration(days: 1)));
      }

      final matchSearch =
          t.note.toLowerCase().contains(searchText) || t.category.toLowerCase().contains(searchText);

      return matchFilter && matchSearch;
    }).toList();

    double totalIncome = 0;
    double totalExpense = 0;
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
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Tổng thu', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 5),
              Text(formatCurrency.format(totalIncome),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
          Column(
            children: [
              const Text('Tổng chi', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 5),
              Text(formatCurrency.format(totalExpense),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }
}