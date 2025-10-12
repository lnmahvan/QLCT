import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/recent_transactions_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.home, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            const Text('Tổng quan chi tiêu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            BalanceCard(balance: expense.balance),
            const SizedBox(height: 25),
            SummaryCard(expense: expense),
            const SizedBox(height: 30),
            RecentTransactionsSection(expense: expense),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}