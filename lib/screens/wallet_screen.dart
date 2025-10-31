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
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: w.type == 'cash'
                      ? [Colors.greenAccent, Colors.green]
                      : w.type == 'debit'
                          ? [Colors.blueAccent, Colors.lightBlue]
                          : [Colors.deepPurpleAccent, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          w.type == 'cash'
                              ? Icons.account_balance_wallet
                              : w.type == 'debit'
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              w.type == 'cash'
                                  ? 'Tiền mặt'
                                  : w.type == 'debit'
                                      ? 'Thẻ tiền'
                                      : 'Thẻ tín dụng',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${w.balance.toStringAsFixed(0)} ₫',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      color: Colors.white,
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (choice) async {
                        if (choice == 'edit') {
                          await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            isScrollControlled: true,
                            builder: (context) {
                              _editNameCtrl.text = w.name;
                              _editBalanceCtrl.text = w.balance.toString();
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 60,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '✏️ Chỉnh sửa ví',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _editNameCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Tên ví',
                                        prefixIcon: Icon(Icons.wallet),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _editBalanceCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Số dư',
                                        prefixIcon: Icon(Icons.attach_money),
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
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
                                          });

                                          _editNameCtrl.clear();
                                          _editBalanceCtrl.clear();
                                          Navigator.pop(context);
                                        },
                                        icon: const Icon(Icons.save, color: Colors.white),
                                        label: const Text(
                                          'Lưu thay đổi',
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🆕 Tạo ví mới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _createNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên ví',
                    prefixIcon: Icon(Icons.wallet),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: 'cash',
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('Tiền mặt')),
                    DropdownMenuItem(value: 'debit', child: Text('Thẻ tiền')),
                    DropdownMenuItem(value: 'credit', child: Text('Thẻ tín dụng')),
                  ],
                  onChanged: (v) {},
                  decoration: const InputDecoration(
                    labelText: 'Loại ví',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _createBalanceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Số dư ban đầu',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final id = const Uuid().v4();
                      final name = _createNameCtrl.text.trim();
                      final type = 'cash';
                      final bal = double.tryParse(_createBalanceCtrl.text) ?? 0;
                      if (name.isEmpty) return;
                      final w = Wallet(id: id, name: name, type: type, balance: bal);
                      expense.addWallet(w);
                      _createNameCtrl.clear();
                      _createBalanceCtrl.clear();
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Tạo ví',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
