import 'package:flutter/material.dart';

class NotificationSection extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const NotificationSection({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  late bool notificationsEnabled;

  @override
  void initState() {
    super.initState();
    notificationsEnabled = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: SwitchListTile(
        title: const Text('Thông báo'),
        subtitle: const Text('Nhận thông báo nhắc chi tiêu hàng ngày'),
        value: notificationsEnabled,
        onChanged: (value) {
          setState(() => notificationsEnabled = value);
          widget.onChanged(value);
        },
        secondary: const Icon(Icons.notifications_active),
      ),
    );
  }
}