import 'package:flutter/foundation.dart';

class TransactionItem {
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final String note;
  final String category;
  final DateTime date;

  TransactionItem({
    required this.type,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
  });
}

class ExpenseModel extends ChangeNotifier {
  double _income = 0;
  double _expense = 0;
  final List<TransactionItem> _transactions = [];

  // Danh mục thu / chi mặc định
  List<String> incomeCategories = ['Lương', 'Thưởng', 'Quà tặng', 'Đầu tư'];
  List<String> expenseCategories = ['Ăn uống', 'Đi lại', 'Mua sắm', 'Hóa đơn', 'Giải trí'];

  // Getter
  double get income => _income;
  double get expense => _expense;
  double get balance => _income - _expense;
  List<TransactionItem> get transactions => _transactions;

  // 🔹 Thêm giao dịch mới (dùng chung cho cả thu và chi)
  void addTransaction({
    required String type, // 'income' hoặc 'expense'
    required double amount,
    String note = '',
    required String category,
    DateTime? date,
  }) {
    final item = TransactionItem(
      type: type,
      amount: amount,
      note: note,
      category: category,
      date: date ?? DateTime.now(),
    );

    _transactions.add(item);

    if (type == 'income') {
      _income += amount;
    } else {
      _expense += amount;
    }

    notifyListeners();
  }

  // 🔹 Thêm danh mục mới
  void addIncomeCategory(String name) {
    if (!incomeCategories.contains(name)) {
      incomeCategories.add(name);
      notifyListeners();
    }
  }

  void addExpenseCategory(String name) {
    if (!expenseCategories.contains(name)) {
      expenseCategories.add(name);
      notifyListeners();
    }
  }

  // 🔹 Lấy danh sách giao dịch theo điều kiện (loại / danh mục)
  List<TransactionItem> getTransactions({
    String? type, // 'income' / 'expense'
    String? category,
  }) {
    return _transactions.where((t) {
      bool matchType = type == null || t.type == type;
      bool matchCategory = category == null || t.category == category;
      return matchType && matchCategory;
    }).toList();
  }

  // 🔹 Tính tổng tiền theo loại hoặc danh mục
  double totalAmount({String? type, String? category}) {
    final list = getTransactions(type: type, category: category);
    return list.fold(0, (sum, t) => sum + t.amount);
  }
}