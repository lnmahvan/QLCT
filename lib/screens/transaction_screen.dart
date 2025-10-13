import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'transaction_entry_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  // Quản lý section đang mở: 'income' hoặc 'expense'
  String _expandedSection = 'income';

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header toggle
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _expandedSection = 'income');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _expandedSection == 'income'
                              ? Colors.green.shade400
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _expandedSection = 'expense');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _expandedSection == 'expense'
                              ? Colors.red.shade400
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Section danh mục
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _expandedSection == 'income'
                  ? _buildCategorySection(
                      context, expense.incomeCategories, 'income', expense)
                  : _buildCategorySection(
                      context, expense.expenseCategories, 'expense', expense),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, List<String> categories,
      String type, ExpenseModel expense) {
    final isIncome = type == 'income';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (_, index) {
            final cat = categories[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green.shade200 : Colors.red.shade200,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.redAccent,
                  ),
                ),
                title: Text(cat),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionEntryScreen(
                        type: type,
                        category: cat,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            final controller = TextEditingController();
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Thêm danh mục ${isIncome ? 'thu nhập' : 'chi tiêu'}'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Tên danh mục'),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy')),
                  TextButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        if (isIncome) {
                          expense.addIncomeCategory(text);
                        } else {
                          expense.addExpenseCategory(text);
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('Thêm'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Thêm danh mục'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isIncome ? Colors.green : Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}