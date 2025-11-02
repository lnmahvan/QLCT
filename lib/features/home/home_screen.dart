import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../transactions/transaction_add_screen.dart';
import '../transactions/transaction_list_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/recent_transactions_section.dart';

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
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff3a7bd5), Color(0xff00d2ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Quản lý chi tiêu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER ICON + TITLE
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff6dd5fa), Color(0xff2980b9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.pie_chart_rounded, size: 75, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Tổng quan chi tiêu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            BalanceCard(
              balance: selectedWallet.balance,
              walletName: selectedWallet.name,
            ),

            const SizedBox(height: 20),
            SummaryCard(expense: expense),

            const SizedBox(height: 30),

            // WALLET DROPDOWN
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chọn ví',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedWalletId,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: wallets.map((w) {
                return DropdownMenuItem(
                  value: w.id,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        w.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                  setState(() => selectedWalletId = val);
                }
              },
            ),

            const SizedBox(height: 25),
            // RECENT TRANSACTIONS HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
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
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                  label: const Text(
                    'Xem tất cả',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
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

      // FAB ADD TRANSACTION
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionAddScreen()),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm giao dịch',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
