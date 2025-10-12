import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class RecentTransactions extends StatelessWidget {
  final ExpenseModel expense;
  const RecentTransactions({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final sorted = expense.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(5).toList();
    final formatCurrency = NumberFormat.currency(
        locale: "vi_VN", symbol: "₫", decimalDigits: 0);

    if (recent.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Chưa có giao dịch nào', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: recent.map((t) {
        final color = t.type == 'income' ? Colors.green : Colors.red;
        final sign = t.type == 'income' ? '+' : '-';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: t.type == 'income'
                ? Colors.green.shade100
                : Colors.red.shade100,
            child: Icon(
              t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text(
            t.note.isNotEmpty ? t.note : t.category,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy').format(t.date),
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            '$sign ${formatCurrency.format(t.amount)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        );
      }).toList(),
    );
  }
}