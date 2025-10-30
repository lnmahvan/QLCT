import 'package:flutter/material.dart';

class ThemeSection extends StatelessWidget {
  final bool isDarkMode;
  final Color selectedColor;
  final Function(bool, Color) onChanged;

  const ThemeSection({
    super.key,
    required this.isDarkMode,
    required this.selectedColor,
    required this.onChanged,
  });

  void _pickColor(BuildContext context) async {
    final colors = [
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
    ];
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Chọn màu chủ đề'),
        content: Wrap(
          spacing: 8,
          children: colors.map((c) {
            return GestureDetector(
              onTap: () {
                onChanged(isDarkMode, c);
                Navigator.pop(context);
              },
              child: CircleAvatar(backgroundColor: c, radius: 18),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối'),
            subtitle: const Text('Bật hoặc tắt giao diện tối'),
            value: isDarkMode,
            onChanged: (value) => onChanged(value, selectedColor),
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Màu chủ đề'),
            trailing: CircleAvatar(backgroundColor: selectedColor),
            onTap: () => _pickColor(context),
          ),
        ],
      ),
    );
  }
}