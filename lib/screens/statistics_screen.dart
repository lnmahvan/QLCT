import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 100, color: Colors.orange),
            const SizedBox(height: 20),
            const Text(
              'Báo cáo chi tiêu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Thu',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        '${expense.income.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Chi',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 10),
                      Text(
                        '${expense.expense.toStringAsFixed(0)} đ',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}