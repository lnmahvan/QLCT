// Move profile_screen.dart here
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/expense_model.dart';
import '../auth/login_screen.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final void Function(bool)? onThemeChanged;
  final void Function(Color)? onColorChanged;
  final bool? isDarkMode;
  final Color? primaryColor;

  const ProfileScreen({
    super.key,
    this.onThemeChanged,
    this.onColorChanged,
    this.isDarkMode,
    this.primaryColor,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final username =
                    snapshot.data!.getString('username') ?? 'Người dùng';
                return Text(
                  username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Tổng thu'),
              trailing: Text(
                '${expense.income.toStringAsFixed(0)} đ',
                style: const TextStyle(color: Colors.green),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Tổng chi'),
              trailing: Text(
                '${expense.expense.toStringAsFixed(0)} đ',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            const Divider(),

            // 🧩 Thêm phần CÀI ĐẶT
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.blueAccent),
              title: const Text('Cài đặt'),
              subtitle: const Text('Tùy chỉnh giao diện, ngôn ngữ, hệ thống'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(
                      onThemeChanged: onThemeChanged ?? (_) {},
                      onColorChanged: onColorChanged ?? (_) {},
                      isDarkMode: isDarkMode ?? false,
                      primaryColor: primaryColor ?? Colors.blue,
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            // 🔴 Đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}