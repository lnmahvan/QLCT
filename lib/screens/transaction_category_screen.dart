import 'package:flutter/material.dart';
import 'transaction_entry_screen.dart';

class TransactionCategoryScreen extends StatefulWidget {
  final String type; // 'income' hoặc 'expense'

  const TransactionCategoryScreen({super.key, required this.type});

  @override
  State<TransactionCategoryScreen> createState() => _TransactionCategoryScreenState();
}

class _TransactionCategoryScreenState extends State<TransactionCategoryScreen> {
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    categories = widget.type == 'income'
        ? ['Lương', 'Thưởng', 'Quà tặng', 'Khác']
        : ['Ăn uống', 'Đi lại', 'Mua sắm', 'Hóa đơn', 'Khác'];
  }

  void _addCategory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => categories.add(text));
              }
              Navigator.pop(context);
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    return Scaffold(
      appBar: AppBar(
        title: Text(isIncome ? 'Danh mục Thu nhập' : 'Danh mục Chi tiêu'),
        backgroundColor: isIncome ? Colors.green : Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, index) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        color: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    title: Text(
                      categories[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TransactionEntryScreen(
                            type: widget.type,
                            category: categories[index],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add),
              label: const Text('Thêm danh mục mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isIncome ? Colors.green : Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}