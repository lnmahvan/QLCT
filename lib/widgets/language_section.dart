import 'package:flutter/material.dart';

class LanguageSection extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;

  const LanguageSection({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Ngôn ngữ'),
          ),
          RadioListTile<String>(
            title: const Text('Tiếng Việt'),
            value: 'vi',
            groupValue: selectedLanguage,
            onChanged: onLanguageChanged,
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: selectedLanguage,
            onChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }
}