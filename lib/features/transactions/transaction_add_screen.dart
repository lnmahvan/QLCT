import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({super.key});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  List<String> customExpenseCategories = [];
  List<String> customIncomeCategories = [];
  String selectedWalletId = 'wallet_cash';

  bool isExpense = true;
  String selectedCategory = '';
  DateTime selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final expenseCategories = ['Ăn uống', 'Đi lại', 'Quần áo', 'Giải trí'];
  final incomeCategories = ['Lương', 'Thưởng', 'Đầu tư'];

  @override
  void initState() {
    super.initState();
    _loadCustomCategories();

    // Nếu load wallets trong ExpenseModel async, có thể lấy từ provider sau frame
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
    final categories = isExpense
        ? customExpenseCategories
        : customIncomeCategories;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có danh mục tùy chỉnh nào để xóa.'),
        ),
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

  //  hàm lưu giao dịch
  void _saveTransaction() {
    if (_amountController.text.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
      );
      return;
    }

    final expense = Provider.of<ExpenseModel>(context, listen: false);
    final double amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text.trim();

    expense.addTransaction(
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      category: selectedCategory,
      date: selectedDate,
      note: note,
      walletId: selectedWalletId,
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
    // final typeColor = isExpense ? Colors.redAccent : Colors.green;
    final expenseModel = Provider.of<ExpenseModel>(context);
    final wallets = expenseModel.wallets;

    // Gradient for AppBar
    final appBarGradient = const LinearGradient(
      colors: [Color(0xFF3a7bd5), Color(0xFF00d2ff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: appBarGradient),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Thêm giao dịch',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toggle type buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isExpense
                                ? Colors.redAccent
                                : Colors.redAccent.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: isExpense ? 3 : 0,
                          ),
                          onPressed: () {
                            setState(() => isExpense = true);
                            selectedCategory = '';
                            _amountController.clear();
                          },
                          label: const Text(
                            'Chi tiêu',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.arrow_downward,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isExpense
                                ? Colors.green
                                : Colors.green.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: !isExpense ? 3 : 0,
                          ),
                          onPressed: () {
                            setState(() => isExpense = false);
                            selectedCategory = '';
                            _amountController.clear();
                          },
                          label: const Text(
                            'Thu nhập',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Category chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...categories.map((cat) {
                        final selected = cat == selectedCategory;
                        final chipColor = isExpense
                            ? Colors.redAccent.withOpacity(
                                selected ? 0.85 : 0.18,
                              )
                            : Colors.green.withOpacity(selected ? 0.85 : 0.18);
                        return ChoiceChip(
                          label: Text(
                            cat,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : (isExpense
                                        ? Colors.redAccent
                                        : Colors.green),
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: selected,
                          backgroundColor: chipColor,
                          selectedColor: isExpense
                              ? Colors.redAccent
                              : Colors.green,
                          onSelected: (_) {
                            setState(() => selectedCategory = cat);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              color: selected
                                  ? (isExpense
                                        ? Colors.redAccent
                                        : Colors.green)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          elevation: selected ? 2 : 0,
                        );
                      }).toList(),
                      // Add/Remove custom category buttons
                      ActionChip(
                        avatar: const Icon(
                          Icons.add,
                          color: Colors.blue,
                          size: 20,
                        ),
                        label: const Text('Thêm'),
                        backgroundColor: Colors.blue.withOpacity(0.12),
                        labelStyle: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () => _addCustomCategory(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(
                          Icons.remove,
                          color: Colors.red,
                          size: 20,
                        ),
                        label: const Text('Xóa'),
                        backgroundColor: Colors.red.withOpacity(0.12),
                        labelStyle: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        onPressed: () => _removeCustomCategory(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ngày
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Colors.blue,
                      ),
                      title: Text(
                        'Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.edit_calendar,
                          color: Colors.blue,
                        ),
                        onPressed: _pickDate,
                        tooltip: "Chọn ngày",
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Chọn ví
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedWalletId,
                      decoration: const InputDecoration(
                        labelText: 'Chọn ví',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.blue,
                        ),
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
                  const SizedBox(height: 16),

                  // Ghi chú
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú',
                        hintText: 'Nhập ghi chú (tùy chọn)',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.edit_note, color: Colors.orange),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Số tiền
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _amountController,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Nhập số tiền',
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bàn phím số (GridView)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      // height: 320,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        children: [
                          ...List.generate(9, (i) {
                            final num = (i + 1).toString();
                            return _buildKeyboardButton(
                              num,
                              onPressed: () => _onNumberPressed(num),
                            );
                          }),
                          _buildKeyboardButton(
                            '0',
                            onPressed: () => _onNumberPressed('0'),
                          ),
                          _buildBackspaceButton(),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper for keyboard buttons
  Widget _buildKeyboardButton(String label, {required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: Colors.black12,
        minimumSize: const Size(30, 30),
        padding: EdgeInsets.zero,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return TextButton(
      onPressed: _onBackspace,
      style: TextButton.styleFrom(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
        shadowColor: Colors.black12,
        minimumSize: const Size(30, 30),
        padding: EdgeInsets.zero,
      ),
      child: const Center(
        child: Icon(Icons.backspace_outlined, color: Colors.blueGrey, size: 28),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
        minimumSize: const Size(30, 30),
        padding: EdgeInsets.zero,
        shadowColor: Colors.black26,
      ),
      child: const Center(
        child: Text(
          'Lưu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
