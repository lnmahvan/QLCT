import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/expense_model.dart';

class SummaryCard extends StatelessWidget {
  final ExpenseModel expense;
  const SummaryCard({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    final now = DateTime.now();

    double todayIncome = 0;
    double todayExpense = 0;
    double monthIncome = 0;
    double monthExpense = 0;

    for (var t in expense.transactions) {
      if (t.date.day == now.day &&
          t.date.month == now.month &&
          t.date.year == now.year) {
        if (t.type == 'income')
          todayIncome += t.amount;
        else
          todayExpense += t.amount;
      }
      if (t.date.month == now.month && t.date.year == now.year) {
        if (t.type == 'income')
          monthIncome += t.amount;
        else
          monthExpense += t.amount;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF64B5F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tóm tắt',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.today_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Hôm nay',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '+ ${formatCurrency.format(todayIncome)}',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Text(
                              '- ${formatCurrency.format(todayExpense)}',
                              style: const TextStyle(
                                color: Color(0xFFC62828),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.calendar_month_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Tháng này',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              '+ ${formatCurrency.format(monthIncome)}',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Text(
                              '- ${formatCurrency.format(monthExpense)}',
                              style: const TextStyle(
                                color: Color(0xFFC62828),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
