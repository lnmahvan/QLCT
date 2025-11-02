import 'package:flutter/material.dart';

class SystemSection extends StatelessWidget {
  final VoidCallback onResetData;

  const SystemSection({super.key, required this.onResetData});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Xóa toàn bộ dữ liệu'),
        subtitle: const Text('Không thể hoàn tác thao tác này'),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn xóa toàn bộ dữ liệu không?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onResetData();
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}