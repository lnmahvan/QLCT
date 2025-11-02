import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                onPressed: () async {
                  Navigator.pop(context);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  // Hiển thị SnackBar xác nhận
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Tất cả dữ liệu đã được xóa. Ứng dụng sẽ khởi động lại.'),
                      backgroundColor: Colors.red.shade100,
                    ),
                  );
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