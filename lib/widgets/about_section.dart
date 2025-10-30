import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Quản lý chi tiêu',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 40),
      applicationLegalese: '© 2025 Nhóm FlutterTech',
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Ứng dụng giúp bạn theo dõi thu chi, quản lý tài chính cá nhân dễ dàng và hiệu quả.',
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: const Text('Giới thiệu ứng dụng'),
        subtitle: const Text('Thông tin phiên bản và nhóm phát triển'),
        onTap: () => _showAbout(context),
      ),
    );
  }
}