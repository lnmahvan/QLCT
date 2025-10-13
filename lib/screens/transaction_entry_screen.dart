import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class TransactionEntryScreen extends StatefulWidget {
  final String type; // 'income' hoặc 'expense'
  final String category;

  const TransactionEntryScreen({super.key, required this.type, required this.category});

  @override
  State<TransactionEntryScreen> createState() => _TransactionEntryScreenState();
}

class _TransactionEntryScreenState extends State<TransactionEntryScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    Provider.of<ExpenseModel>(context, listen: false).addTransaction(
      type: widget.type,
      category: widget.category,
      amount: amount,
      note: _noteController.text,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    return Scaffold(
      appBar: AppBar(
        title: Text('${isIncome ? 'Thu nhập' : 'Chi tiêu'} - ${widget.category}'),
        backgroundColor: isIncome ? Colors.green : Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? Colors.green : Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Lưu giao dịch', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}