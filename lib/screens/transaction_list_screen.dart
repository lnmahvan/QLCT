import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'all'; // all, today, month

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    // Lọc giao dịch theo lựa chọn
    final now = DateTime.now();
    final filtered =
        expense.transactions.where((t) {
          if (_filter == 'today') {
            return t.date.day == now.day &&
                t.date.month == now.month &&
                t.date.year == now.year;
          } else if (_filter == 'month') {
            return t.date.month == now.month && t.date.year == now.year;
          }
          return true;
        }).toList()..sort(
          (a, b) => b.date.compareTo(a.date),
        ); // sắp xếp mới nhất lên đầu

    // Tính tổng thu/chi theo bộ lọc
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in filtered) {
      if (t.type == 'income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            icon: const Icon(Icons.filter_alt),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'today', child: Text('Hôm nay')),
              const PopupMenuItem(value: 'month', child: Text('Tháng này')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Thống kê tổng thu/chi
          Container(
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
                    const Text(
                      'Tổng thu',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatCurrency.format(totalIncome),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Tổng chi',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatCurrency.format(totalExpense),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách giao dịch
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'Không có giao dịch nào trong thời gian này',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final t = filtered[index];
                      final formattedDate = DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(t.date);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(
                            t.type == 'income'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: t.type == 'income'
                                ? Colors.green
                                : Colors.redAccent,
                            size: 28,
                          ),
                          title: Text(
                            t.note.isNotEmpty ? t.note : '(Không có ghi chú)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Danh mục: ${t.category}'),
                              Text(
                                formattedDate,
                              ),
                            ],
                          ),
                          trailing: Text(
                            (t.type == 'income' ? '+' : '-') +
                                formatCurrency.format(t.amount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: t.type == 'income'
                                  ? Colors.green
                                  : Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
