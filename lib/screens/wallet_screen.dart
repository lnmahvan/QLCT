// lib/screens/wallet_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart' as expense_model;
import '../models/wallet_model.dart';
import 'package:uuid/uuid.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // dùng riêng cho TẠO ví
  final _createNameCtrl = TextEditingController();
  final _createBalanceCtrl = TextEditingController();

  // dùng riêng cho SỬA ví (dialog)
  final _editNameCtrl = TextEditingController();
  final _editBalanceCtrl = TextEditingController();

  @override
  void dispose() {
    _createNameCtrl.dispose();
    _createBalanceCtrl.dispose();
    _editNameCtrl.dispose();
    _editBalanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<expense_model.ExpenseModel>(context);
    final wallets = expense.wallets;

    return Scaffold(
      appBar: AppBar(title: const Text('Ví tiền'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final w in wallets)
            Card(
              child: ListTile(
                leading: Icon(
                  w.type == 'cash'
                      ? Icons.money
                      : w.type == 'debit'
                      ? Icons.account_balance_wallet
                      : Icons.credit_card,
                ),
                title: Text(w.name),
                subtitle: Text('Số dư: ${w.balance.toStringAsFixed(0)} ₫'),
                trailing: PopupMenuButton<String>(
                  onSelected: (choice) async {
                    if (choice == 'edit') {
                      // chỉnh tên hoặc số dư đơn giản
                      await showDialog(
                        context: context,
                        builder: (_) {
                          _editNameCtrl.text = w.name;
                          _editBalanceCtrl.text = w.balance.toString();
                          return AlertDialog(
                            title: const Text('Chỉnh ví'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: _editNameCtrl,
                                  decoration: const InputDecoration(labelText: 'Tên ví'),
                                ),
                                TextField(
                                  controller: _editBalanceCtrl,
                                  decoration: const InputDecoration(labelText: 'Số dư'),
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _editNameCtrl.clear();
                                  _editBalanceCtrl.clear();
                                  Navigator.pop(context);
                                },
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  final oldBalance = w.balance;
                                  final newBalance =
                                      double.tryParse(_editBalanceCtrl.text) ?? w.balance;
                                  final delta = newBalance - oldBalance;

                                  setState(() {
                                    w.name = _editNameCtrl.text.trim();

                                    if (delta != 0) {
                                      expense.addTransaction(
                                        type: delta > 0 ? 'income' : 'expense',
                                        amount: delta.abs(),
                                        category: 'Điều chỉnh số dư',
                                        note: 'Cập nhật số dư ví "${w.name}"',
                                        walletId: w.id,
                                      );
                                    }

                                    // expense.notifyListeners();
                                  });
                                  _editNameCtrl.clear();
                                  _editBalanceCtrl.clear();
                                  Navigator.pop(context);
                                },
                                child: const Text('Lưu'),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (choice == 'delete') {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xác nhận xóa ví?'),
                          content: const Text(
                            'Các giao dịch gán vào ví này sẽ giữ nguyên.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  expense.wallets.removeWhere(
                                    (e) => e.id == w.id,
                                  );
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xóa')),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'Tạo ví mới',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextField(
            controller: _createNameCtrl,
            decoration: const InputDecoration(labelText: 'Tên ví'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: 'cash',
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
              DropdownMenuItem(value: 'debit', child: Text('Thẻ tiền')),
              DropdownMenuItem(value: 'credit', child: Text('Thẻ tín dụng')),
            ],
            onChanged: (v) {},
            decoration: const InputDecoration(labelText: 'Loại ví'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _createBalanceCtrl,
            decoration: const InputDecoration(labelText: 'Số dư ban đầu'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              final id = const Uuid().v4();
              final name = _createNameCtrl.text.trim();
              final type = 'cash';
              final bal = double.tryParse(_createBalanceCtrl.text) ?? 0;
              if (name.isEmpty) return;
              final w = Wallet(id: id, name: name, type: type, balance: bal);
              expense.addWallet(w); // tạo ví mới
              _createNameCtrl.clear();
              _createBalanceCtrl.clear();
            },
            child: const Text('Tạo ví'),
          ),
        ],
      ),
    );
  }
}
