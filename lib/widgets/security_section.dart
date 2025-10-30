import 'package:flutter/material.dart';

class SecuritySection extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const SecuritySection({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<SecuritySection> createState() => _SecuritySectionState();
}

class _SecuritySectionState extends State<SecuritySection> {
  late bool pinEnabled;

  @override
  void initState() {
    super.initState();
    pinEnabled = widget.initialValue;
  }

  void _showPinDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đặt mã PIN'),
        content: TextField(
          controller: controller,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Nhập mã PIN mới'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu mã PIN mới!')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Khóa bằng mã PIN'),
        subtitle: const Text('Bảo vệ ứng dụng bằng mã PIN'),
        value: pinEnabled,
        onChanged: (value) {
          setState(() => pinEnabled = value);
          widget.onChanged(value);
          if (value) _showPinDialog();
        },
        secondary: const Icon(Icons.lock),
      ),
    );
  }
}