import 'package:flutter/material.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // ❌ bỏ const ở đây
      appBar: AppBar(
        title: const Text('Ví tiền'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Tính năng ví tiền đang được phát triển...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}