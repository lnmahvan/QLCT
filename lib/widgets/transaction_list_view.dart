import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';

class TransactionListView extends StatelessWidget {
  final ExpenseModel expense;
  final String filter;
  final DateTimeRange? customRange;
  final String searchText;
  final String? selectedWalletId;

  const TransactionListView({
    super.key,
    required this.expense,
    required this.filter,
    this.customRange,
    required this.searchText,
    this.selectedWalletId,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    final filtered = expense.transactions.where((t) {
      bool matchFilter = false;

      if (filter == 'all') {
        matchFilter = true;
      } else if (filter == 'today') {
        matchFilter =
            t.date.day == now.day &&
            t.date.month == now.month &&
            t.date.year == now.year;
      } else if (filter == 'month') {
        matchFilter = t.date.month == now.month && t.date.year == now.year;
      } else if (filter == 'custom' && customRange != null) {
        matchFilter =
            t.date.isAfter(
              customRange!.start.subtract(const Duration(days: 1)),
            ) &&
            t.date.isBefore(customRange!.end.add(const Duration(days: 1)));
      }

      final matchSearch =
          t.note.toLowerCase().contains(searchText) ||
          t.category.toLowerCase().contains(searchText);

      final matchWallet = selectedWalletId == null || t.walletId == selectedWalletId;

      return matchFilter && matchSearch && matchWallet;
    }).toList()..sort((a, b) => b.date.compareTo(a.date));

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Không có giao dịch nào trong thời gian này',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final t = filtered[index];
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(t.date);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            leading: Icon(
              t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
              color: t.type == 'income' ? Colors.green : Colors.redAccent,
              size: 28,
            ),
            title: Text(
              t.note.isNotEmpty ? t.note : '(Không có ghi chú)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Danh mục: ${t.category}'), Text(formattedDate)],
            ),
            trailing: Text(
              (t.type == 'income' ? '+' : '-') +
                  formatCurrency.format(t.amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: t.type == 'income' ? Colors.green : Colors.redAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
