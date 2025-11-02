import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/widgets/theme_section.dart';
import '../settings/widgets/language_section.dart';
import '../settings/widgets/system_section.dart';
import '../settings/widgets/notification_section.dart';
import '../settings/widgets/security_section.dart';
import '../settings/widgets/about_section.dart';

class SettingsScreen extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final void Function(Color) onColorChanged;
  final bool isDarkMode;
  final Color primaryColor;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.onColorChanged,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isDarkMode;
  late Color selectedColor;
  bool notificationsEnabled = true;
  bool pinEnabled = false;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
    selectedColor = widget.primaryColor;
  }

  void _toggleTheme(bool value) {
    setState(() => isDarkMode = value);
    widget.onThemeChanged(value);
  }

  void _changeColor(Color color) {
    setState(() => selectedColor = color);
    widget.onColorChanged(color);
  }

  void _toggleNotifications(bool value) {
    setState(() => notificationsEnabled = value);
  }

  void _togglePin(bool value) {
    setState(() => pinEnabled = value);
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade200,
        content: const Text('Dữ liệu đã được xóa!'),
        action: SnackBarAction(
          label: 'Hoàn tác',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Hoàn tác chưa được thực hiện.')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black12,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A4A4A),
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Giao diện'),
          _buildSectionCard(
            child: ThemeSection(
              isDarkMode: isDarkMode,
              selectedColor: selectedColor,
              onChanged: (dark, color) {
                _toggleTheme(dark);
                _changeColor(color);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            child: NotificationSection(
              initialValue: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Bảo mật'),
          _buildSectionCard(
            child: SecuritySection(
              initialValue: pinEnabled,
              onChanged: _togglePin,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Ngôn ngữ'),
          _buildSectionCard(
            child: const LanguageSection(
              selectedLanguage: 'vi',
              onLanguageChanged: print,
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Hệ thống'),
          _buildSectionCard(
            child: SystemSection(onResetData: _resetData),
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            child: const AboutSection(),
          ),
        ],
      ),
    );
  }
}