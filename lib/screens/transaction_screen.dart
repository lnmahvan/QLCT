import 'package:flutter/material.dart';
import 'transaction/add_income_screen.dart';
import 'transaction/add_expense_screen.dart';
import 'transaction_list_screen.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'Thêm thu/chi mới',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddExpenseScreen()),
                );
              },
              icon: const Icon(Icons.remove),
              label: const Text('Thêm khoản chi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddIncomeScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm khoản thu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 40),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TransactionListScreen()),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Xem danh sách giao dịch'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                side: const BorderSide(color: Colors.teal, width: 2),
                foregroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}