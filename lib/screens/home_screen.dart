import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/recent_transactions_section.dart';
import 'transaction_add_screen.dart';
import 'transaction_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedWalletId = '';

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);
    final wallets = expense.wallets;
    if (wallets.isNotEmpty && selectedWalletId.isEmpty) {
      selectedWalletId = wallets.first.id;
    }

    final selectedWallet = expense.getWalletById(selectedWalletId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.home, size: 80, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Tổng quan chi tiêu',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            BalanceCard(
              balance: selectedWallet.balance,
              walletName: selectedWallet.name,
            ),
            const SizedBox(height: 25),
            SummaryCard(expense: expense),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionListScreen(
                          selectedWalletId: selectedWalletId,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: selectedWalletId,
                decoration: const InputDecoration(
                  labelText: 'Chọn ví',
                  border: OutlineInputBorder(),
                ),
                items: wallets.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w.name),
                        Text(
                          '${w.balance.toStringAsFixed(0)} ₫',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedWalletId = val;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            RecentTransactionsSection(
              expense: expense,
              selectedWalletId: selectedWalletId,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionAddScreen()),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
