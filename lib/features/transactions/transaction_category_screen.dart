import 'package:flutter/material.dart';
import 'transaction_entry_screen.dart';

class TransactionCategoryScreen extends StatefulWidget {
  final String type; // 'income' hoặc 'expense'

  const TransactionCategoryScreen({super.key, required this.type});

  @override
  State<TransactionCategoryScreen> createState() => _TransactionCategoryScreenState();
}

class _TransactionCategoryScreenState extends State<TransactionCategoryScreen> {
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    categories = widget.type == 'income'
        ? ['Lương', 'Thưởng', 'Quà tặng', 'Khác']
        : ['Ăn uống', 'Đi lại', 'Mua sắm', 'Hóa đơn', 'Khác'];
  }

  void _addCategory() {
    final controller = TextEditingController();
    final isIncome = widget.type == 'income';
    // final primaryGradient = isIncome
    //     ? LinearGradient(colors: [Colors.green.shade400.withOpacity(0.7), Colors.green.shade700.withOpacity(0.7)])
    //     : LinearGradient(colors: [Colors.pink.shade300.withOpacity(0.7), Colors.red.shade400.withOpacity(0.7)]);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
        title: const Text('Thêm danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Tên danh mục', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: isIncome ? Colors.green : Colors.redAccent,
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => categories.add(text));
              }
              Navigator.pop(context);
            },
            child: const Text('Thêm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';
    final primaryGradient = isIncome
        ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF087F23)])
        : const LinearGradient(colors: [Color(0xFFF06292), Color(0xFFE91E63)]);
    final iconGradient = isIncome
        ? LinearGradient(colors: [Colors.green.shade200.withOpacity(0.3), Colors.green.shade400.withOpacity(0.1)])
        : LinearGradient(colors: [Colors.pink.shade200.withOpacity(0.3), Colors.red.shade400.withOpacity(0.1)]);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: primaryGradient),
          ),
          title: Text(
            isIncome ? 'Danh mục Thu nhập' : 'Danh mục Chi tiêu',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (_, index) => GestureDetector(
                  onTapDown: (_) => setState(() {}),
                  onTapUp: (_) => setState(() {}),
                  onTapCancel: () => setState(() {}),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      splashColor: isIncome ? Colors.green.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionEntryScreen(
                              type: widget.type,
                              category: categories[index],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            gradient: iconGradient,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          categories[index],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF333333),
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _addCategory,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Thêm danh mục mới',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ).copyWith(
                  elevation: MaterialStateProperty.all(0),
                  backgroundColor: MaterialStateProperty.resolveWith((states) => null),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
              ).wrapWithGradient(primaryGradient, 16),
            ),
          ],
        ),
      ),
    );
  }
}

extension GradientButtonExtension on Widget {
  Widget wrapWithGradient(Gradient gradient, double borderRadius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withOpacity(0.4),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: this,
    );
  }
}