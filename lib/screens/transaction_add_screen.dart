import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({super.key});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  bool isExpense = true;
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();

  final expenseCategories = [
    'Ăn uống',
    'Đi lại',
    'Quần áo',
    'Giải trí',
    'Khác',
  ];
  final incomeCategories = ['Lương', 'Thưởng', 'Đầu tư', 'Khác'];

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void _onNumberPressed(String number) {
    setState(() {
      _amountController.text += number;
    });
  }

  void _onBackspace() {
    if (_amountController.text.isNotEmpty) {
      setState(() {
        _amountController.text = _amountController.text.substring(
          0,
          _amountController.text.length - 1,
        );
      });
    }
  }

  void _saveTransaction() {
    if (_amountController.text.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
      );
      return;
    }

    final expense = Provider.of<ExpenseModel>(context, listen: false);
    final double amount = double.tryParse(_amountController.text) ?? 0;

    expense.addTransaction(
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu giao dịch!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = isExpense ? expenseCategories : incomeCategories;
    final typeColor = isExpense ? Colors.redAccent : Colors.green;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch'), centerTitle: true),
      body: Column(
        children: [
          // 🔹 Chọn loại giao dịch
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [isExpense, !isExpense],
              onPressed: (index) {
                setState(() => isExpense = index == 0);
                selectedCategory = '';
                _amountController.clear();
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Chi tiêu'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Thu nhập'),
                ),
              ],
            ),
          ),

          // 🔹 Danh mục
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = cat == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? typeColor.withOpacity(0.15)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? typeColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: selected ? typeColor : Colors.black,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 🔹 Bàn phím nhập tiền + chọn ngày + lưu
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Chọn ngày
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDate,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Ô hiển thị số tiền
                TextField(
                  controller: _amountController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Nhập số tiền',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // Bàn phím số
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  childAspectRatio: 2.2,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'].map(
                      (num) => ElevatedButton(
                        onPressed: () => _onNumberPressed(num),
                        child: Text(num, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _onBackspace,
                      child: const Icon(Icons.backspace),
                    ),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                      ),
                      child: const Text(
                        'Lưu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
