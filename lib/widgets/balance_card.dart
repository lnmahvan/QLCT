import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  const BalanceCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'Số dư hiện tại',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency.format(balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}