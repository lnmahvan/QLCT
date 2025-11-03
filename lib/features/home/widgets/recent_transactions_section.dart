import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/expense_model.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Text(
            '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: recent.isEmpty
              ? Card(
                  elevation: 0,
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, color: Colors.grey, size: 38),
                        SizedBox(height: 10),
                        Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: List.generate(recent.length, (i) {
                    final t = recent[i];
                    final color = t.type == 'income'
                        ? Colors.green
                        : Colors.red;
                    final sign = t.type == 'income' ? '+' : '-';
                    // Alternate background color or gradient
                    final bool isEven = i % 2 == 0;
                    final cardDecoration = BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: isEven
                          ? LinearGradient(
                              colors: [
                                Colors.blue.withOpacity(0.07),
                                Colors.white,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.purple.withOpacity(0.05),
                                Colors.white,
                              ],
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    );
                    return Column(
                      children: [
                        Container(
                          decoration: cardDecoration,
                          child: Card(
                            elevation: 0,
                            color: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              onLongPress: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa giao dịch'),
                                    content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  expense.deleteTransaction(t);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Đã xóa giao dịch')),
                                  );
                                }
                              },
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (t.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        t.note,
                                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                                      ),
                                    ),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(t.date),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '$sign ${formatCurrency.format(t.amount)}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (i < recent.length - 1) const SizedBox(height: 8),
                      ],
                    );
                  }),
                ),
        ),
      ],
    );
  }
}