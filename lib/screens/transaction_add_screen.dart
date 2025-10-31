import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import '../models/wallet_model.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({super.key});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  List<String> customExpenseCategories = [];
  List<String> customIncomeCategories = [];
  String selectedWalletId =
      'wallet_cash'; // default; sau khi load wallets sẽ điều chỉnh

  bool isExpense = true;
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController =
      TextEditingController(); // 🆕 thêm dòng này

  final expenseCategories = [
    'Ăn uống',
    'Đi lại',
    'Quần áo',
    'Giải trí',
    'Khác',
  ];
  final incomeCategories = ['Lương', 'Thưởng', 'Đầu tư', 'Khác'];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories(); // Gọi để load danh mục người dùng đã lưu

    // nếu bạn load wallets trong ExpenseModel async, có thể lấy từ provider sau frame:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expense = Provider.of<ExpenseModel>(context, listen: false);
      if (expense.wallets.isNotEmpty) {
        setState(() {
          selectedWalletId = expense.wallets.first.id;
        });
      }
    });
  }

  Future<void> _loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customExpenseCategories =
          prefs.getStringList('customExpenseCategories') ?? [];
      customIncomeCategories =
          prefs.getStringList('customIncomeCategories') ?? [];
    });
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'customExpenseCategories',
      customExpenseCategories,
    );
    await prefs.setStringList('customIncomeCategories', customIncomeCategories);
  }

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

  void _addCustomCategory(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Thêm danh mục mới'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Nhập tên danh mục'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategory = _controller.text.trim();
                if (newCategory.isNotEmpty) {
                  setState(() {
                    if (isExpense) {
                      customExpenseCategories.add(newCategory);
                    } else {
                      customIncomeCategories.add(newCategory);
                    }
                  });
                  await _saveCustomCategories();
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _removeCustomCategory(BuildContext context) {
    final categories = isExpense ? customExpenseCategories : customIncomeCategories;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có danh mục tùy chỉnh nào để xóa.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa danh mục'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ListTile(
                  title: Text(cat),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      setState(() {
                        categories.removeAt(index);
                      });
                      await _saveCustomCategories();
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // 🆕 hàm lưu giao dịch
  void _saveTransaction() {
    if (_amountController.text.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
      );
      return;
    }

    final expense = Provider.of<ExpenseModel>(context, listen: false);
    final double amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text.trim(); // 🆕 lấy ghi chú

    expense.addTransaction(
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
      note: note,
      walletId: selectedWalletId, // 🆕 thêm ví được chọn
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu giao dịch!')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      ...(isExpense ? expenseCategories : incomeCategories),
      ...(isExpense ? customExpenseCategories : customIncomeCategories),
    ];
    final typeColor = isExpense ? Colors.redAccent : Colors.green;

    final expenseModel = Provider.of<ExpenseModel>(context);
    final wallets = expenseModel.wallets;

    return Scaffold(
      appBar: AppBar(title: const Text('Thêm giao dịch'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
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
            SizedBox(
              height: 200,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount:
                    categories.length + 1, // +1 để thêm nút "Thêm danh mục"
                itemBuilder: (context, index) {
                  if (index == categories.length) {
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _addCustomCategory(context),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Icon(Icons.add, color: Colors.blue),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _removeCustomCategory(context),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(Icons.remove, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                    );
                  }

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

            // 🔹 Bọc phần nhập tiền, chọn ví, ghi chú, chọn ngày, bàn phím số
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Chọn ngày
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
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
                  ),
                  const SizedBox(height: 4),

                  // 🆕 Dropdown chọn ví
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
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
                        if (val != null) setState(() => selectedWalletId = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 🆕 Ô nhập ghi chú
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        border: OutlineInputBorder(),
                        hintText: 'Nhập ghi chú (tùy chọn)',
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Ô hiển thị số tiền
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: TextField(
                      controller: _amountController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nhập số tiền',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Bàn phím số
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    childAspectRatio: 2.8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ...['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'].map(
                        (num) => ElevatedButton(
                          onPressed: () => _onNumberPressed(num),
                          child: Text(num, style: const TextStyle(fontSize: 18)),
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
      ),
    );
  }
}
