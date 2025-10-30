import 'package:flutter/material.dart';
import '../widgets/theme_section.dart';
import '../widgets/language_section.dart';
import '../widgets/system_section.dart';
import '../widgets/notification_section.dart';
import '../widgets/security_section.dart';
import '../widgets/about_section.dart';

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

  void _resetData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ThemeSection(
            isDarkMode: isDarkMode,
            selectedColor: selectedColor,
            onChanged: (dark, color) {
              _toggleTheme(dark);
              _changeColor(color);
            },
          ),
          const SizedBox(height: 16),
          NotificationSection(
            initialValue: notificationsEnabled,
            onChanged: _toggleNotifications,
          ),
          const SizedBox(height: 16),
          SecuritySection(
            initialValue: pinEnabled,
            onChanged: _togglePin,
          ),
          const SizedBox(height: 16),
          const LanguageSection(
            selectedLanguage: 'vi',
            onLanguageChanged: print,
          ),
          const SizedBox(height: 16),
          SystemSection(onResetData: _resetData),
          const SizedBox(height: 16),
          const AboutSection(),
        ],
      ),
    );
  }
}