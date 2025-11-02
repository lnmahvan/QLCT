import 'package:flutter/material.dart';

class TransactionSearch extends StatelessWidget {
  final TextEditingController controller;
  final String searchText;
  final Function(String) onChanged;
  final VoidCallback onClear;

  const TransactionSearch({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Tìm theo ghi chú hoặc danh mục...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchText.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}