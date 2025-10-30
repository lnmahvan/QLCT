import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class RecentTransactionsSection extends StatelessWidget {
  final ExpenseModel expense;
  final String selectedWalletId;

  const RecentTransactionsSection({
    super.key,
    required this.expense,
    required this.selectedWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = expense.transactions
        .where((t) => t.walletId == selectedWalletId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final recent = sorted.take(5).toList();
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: recent.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Chưa có giao dịch nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : Column(
                  children: recent.map((t) {
                    final color = t.type == 'income'
                        ? Colors.green
                        : Colors.red;
                    final sign = t.type == 'income' ? '+' : '-';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: t.type == 'income'
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        child: Icon(
                          t.type == 'income'
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: color,
                        ),
                      ),
                      title: Text(
                        t.category,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.note.isNotEmpty)
                            Text(
                              t.note,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          Text(
                            DateFormat('dd/MM/yyyy').format(t.date),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '$sign ${formatCurrency.format(t.amount)}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
