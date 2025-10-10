import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    // Tính thu / chi hôm nay
    double todayIncome = 0;
    double todayExpense = 0;
    for (var t in expense.transactions) {
      if (t.date.day == now.day &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        if (t.type == 'income') {
          todayIncome += t.amount;
        } else {
          todayExpense += t.amount;
        }
      }
    }

    // Tính thu / chi tháng này
    double monthIncome = 0;
    double monthExpense = 0;
    for (var t in expense.transactions) {
      if (t.date.month == now.month && t.date.year == now.year) {
        if (t.type == 'income') {
          monthIncome += t.amount;
        } else {
          monthExpense += t.amount;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.home, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Tổng quan chi tiêu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    'Số dư hiện tại',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    formatCurrency.format(expense.balance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🔹 Thanh tóm tắt thu chi
            Padding(
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
            ),

            const SizedBox(height: 30),

            // 🔸 Danh sách 5 giao dịch gần nhất
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // 👉 chuyển sang trang danh sách giao dịch chi tiết
                      Navigator.pushNamed(context, '/transactions');
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Consumer<ExpenseModel>(
                builder: (context, expense, _) {
                  final sorted = expense.transactions.toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
                  final recent = sorted.take(5).toList();

                  if (recent.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(color: Colors.grey),
                        ),
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
                          '$sign ${NumberFormat.currency(locale: "vi_VN", symbol: "₫", decimalDigits: 0).format(t.amount)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Bạn có thể thêm phần biểu đồ mini hoặc giao dịch gần đây bên dưới
          ],
        ),
      ),
    );
  }
}
