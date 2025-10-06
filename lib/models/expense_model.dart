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

  double get income => _income;
  double get expense => _expense;
  double get balance => _income - _expense;
  List<TransactionItem> get transactions => _transactions;

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
}