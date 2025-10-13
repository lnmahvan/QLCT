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

  // Danh mục thu/chi
  List<String> incomeCategories = ['Lương', 'Thưởng', 'Quà tặng'];
  List<String> expenseCategories = ['Ăn uống', 'Đi lại', 'Mua sắm', 'Hóa đơn'];

  // Getter
  double get income => _income;
  double get expense => _expense;
  double get balance => _income - _expense;
  List<TransactionItem> get transactions => _transactions;

  // Thêm giao dịch
  void addIncome(double amount, String note, String category) {
    _income += amount;
    _transactions.add(TransactionItem(
      type: 'income',
      amount: amount,
      note: note,
      category: category,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  void addExpense(double amount, String note, String category) {
    _expense += amount;
    _transactions.add(TransactionItem(
      type: 'expense',
      amount: amount,
      note: note,
      category: category,
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // Thêm phương thức addTransaction dùng chung
  void addTransaction({
    required String type,
    required double amount,
    required String note,
    required String category,
  }) {
    if (type == 'income') {
      addIncome(amount, note, category);
    } else {
      addExpense(amount, note, category);
    }
  }

  // Thêm danh mục mới
  void addIncomeCategory(String name) {
    incomeCategories.add(name);
    notifyListeners();
  }

  void addExpenseCategory(String name) {
    expenseCategories.add(name);
    notifyListeners();
  }

  // Lấy giao dịch theo loại và category
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

  // Tính tổng theo loại hoặc category
  double totalAmount({String? type, String? category}) {
    final list = getTransactions(type: type, category: category);
    return list.fold(0, (sum, t) => sum + t.amount);
  }
}