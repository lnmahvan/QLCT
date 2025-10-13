import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class SummaryCard extends StatelessWidget {
  final ExpenseModel expense;
  const SummaryCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    double todayIncome = 0;
    double todayExpense = 0;
    double monthIncome = 0;
    double monthExpense = 0;

    for (var t in expense.transactions) {
      if (t.date.day == now.day &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        if (t.type == 'income') todayIncome += t.amount;
        else todayExpense += t.amount;
      }
      if (t.date.month == now.month && t.date.year == now.year) {
        if (t.type == 'income') monthIncome += t.amount;
        else monthExpense += t.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tóm tắt',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Hôm nay', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(
                      '+ ${formatCurrency.format(todayIncome)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '- ${formatCurrency.format(todayExpense)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tháng này', style: TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Text(
                      '+ ${formatCurrency.format(monthIncome)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      '- ${formatCurrency.format(monthExpense)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}