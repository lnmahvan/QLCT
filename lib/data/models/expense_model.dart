// Move expense_model.dart here
import 'package:flutter/foundation.dart';
import 'wallet_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TransactionItem {
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final String note;
  final String category;
  final DateTime date;
  final String walletId; // 🆕 thêm walletId

  TransactionItem({
    required this.type,
    required this.amount,
    required this.note,
    required this.category,
    required this.date,
    required this.walletId, // 🆕
  });
}

class ExpenseModel extends ChangeNotifier {
  double _income = 0;
  double _expense = 0;
  final List<TransactionItem> _transactions = [];

  // 🔹 Danh sách ví
  final List<Wallet> _wallets = [
    Wallet(id: 'wallet_cash', name: 'Tiền mặt', type: 'cash', balance: 0),
    Wallet(id: 'wallet_debit', name: 'Thẻ tiền', type: 'debit', balance: 0),
    Wallet(id: 'wallet_credit', name: 'Thẻ tín dụng', type: 'credit', balance: 0),
  ];

  ExpenseModel() {
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final walletData = _wallets
        .map((w) => {
              'id': w.id,
              'name': w.name,
              'type': w.type,
              'balance': w.balance,
            })
        .toList();
    final transactionData = _transactions
        .map((t) => {
              'type': t.type,
              'amount': t.amount,
              'note': t.note,
              'category': t.category,
              'date': t.date.toIso8601String(),
              'walletId': t.walletId,
            })
        .toList();

    await prefs.setString('wallets', jsonEncode(walletData));
    await prefs.setString('transactions', jsonEncode(transactionData));
    await prefs.setDouble('income', _income);
    await prefs.setDouble('expense', _expense);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final walletsJson = prefs.getString('wallets');
    final transactionsJson = prefs.getString('transactions');
    _income = prefs.getDouble('income') ?? 0;
    _expense = prefs.getDouble('expense') ?? 0;

    if (walletsJson != null) {
      final List<dynamic> walletList = jsonDecode(walletsJson);
      _wallets
        ..clear()
        ..addAll(walletList.map((w) => Wallet(
              id: w['id'],
              name: w['name'],
              type: w['type'],
              balance: (w['balance'] as num).toDouble(),
            )));
    }

    if (transactionsJson != null) {
      final List<dynamic> transactionList = jsonDecode(transactionsJson);
      _transactions
        ..clear()
        ..addAll(transactionList.map((t) => TransactionItem(
              type: t['type'],
              amount: (t['amount'] as num).toDouble(),
              note: t['note'],
              category: t['category'],
              date: DateTime.parse(t['date']),
              walletId: t['walletId'],
            )));
    }

    notifyListeners();
  }

  List<Wallet> get wallets => _wallets;

  void addWallet(Wallet wallet) {
    _wallets.add(wallet);
    notifyListeners();
    saveData();
  }

  void updateWalletBalance(String walletId, double delta) {
    final wallet = _wallets.firstWhere((w) => w.id == walletId);
    wallet.balance += delta;
    notifyListeners();
    saveData();
  }

  Wallet getWalletById(String id) {
    return _wallets.firstWhere((w) => w.id == id);
  }

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
    required String walletId, // 🆕 thêm walletId
  }) {
    final item = TransactionItem(
      type: type,
      amount: amount,
      note: note,
      category: category,
      date: date ?? DateTime.now(),
      walletId: walletId, // 🆕
    );

    _transactions.add(item);

    if (type == 'income') {
      _income += amount;
      updateWalletBalance(walletId, amount);
    } else {
      _expense += amount;
      updateWalletBalance(walletId, -amount);
    }

    notifyListeners();
    saveData();
  }

  // 🔹 Thêm danh mục mới
  void addIncomeCategory(String name) {
    if (!incomeCategories.contains(name)) {
      incomeCategories.add(name);
      notifyListeners();
      saveData();
    }
  }

  void addExpenseCategory(String name) {
    if (!expenseCategories.contains(name)) {
      expenseCategories.add(name);
      notifyListeners();
      saveData();
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