import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _filter = 'all';
  String _searchText = '';
  String _selectedChartType = 'expense'; // income | expense
  DateTimeRange? _customRange;

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);
    final formatCurrency =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    final now = DateTime.now();

    // Lọc theo thời gian
    final filtered = expense.transactions.where((t) {
      bool matchFilter = false;

      if (_filter == 'all') {
        matchFilter = true;
      } else if (_filter == 'today') {
        matchFilter = t.date.day == now.day &&
            t.date.month == now.month &&
            t.date.year == now.year;
      } else if (_filter == 'month') {
        matchFilter = t.date.month == now.month && t.date.year == now.year;
      } else if (_filter == 'custom' && _customRange != null) {
        matchFilter = t.date.isAfter(_customRange!.start.subtract(const Duration(days: 1))) &&
                      t.date.isBefore(_customRange!.end.add(const Duration(days: 1)));
      }

      final matchSearch = t.note.toLowerCase().contains(_searchText) ||
          t.category.toLowerCase().contains(_searchText);

      return matchFilter && matchSearch;
    }).toList();

    // Gom nhóm
    final Map<String, double> categoryIncome = {};
    final Map<String, double> categoryExpense = {};
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in filtered) {
      if (t.type == 'income') {
        totalIncome += t.amount;
        categoryIncome[t.category] =
            (categoryIncome[t.category] ?? 0) + t.amount;
      } else {
        totalExpense += t.amount;
        categoryExpense[t.category] =
            (categoryExpense[t.category] ?? 0) + t.amount;
      }
    }

    final currentCategory =
        _selectedChartType == 'income' ? categoryIncome : categoryExpense;
    final currentTotal =
        _selectedChartType == 'income' ? totalIncome : totalExpense;

    // Tạo biểu đồ
    final pieSections = <PieChartSectionData>[];
    currentCategory.forEach((category, amount) {
      final percent = (amount / (currentTotal == 0 ? 1 : currentTotal)) * 100;
      pieSections.add(
        PieChartSectionData(
          value: amount,
          title: '${percent.toStringAsFixed(1)}%',
          color: Colors.primaries[pieSections.length % Colors.primaries.length],
          radius: 80,
          titleStyle: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        backgroundColor: Colors.orange,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'custom') {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _customRange,
                );
                if (picked != null) {
                  setState(() {
                    _customRange = picked;
                    _filter = 'custom';
                  });
                }
              } else {
                setState(() {
                  _filter = value;
                  _customRange = null;
                });
              }
            },
            icon: const Icon(Icons.filter_alt),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text('Tất cả')),
              PopupMenuItem(value: 'today', child: Text('Hôm nay')),
              PopupMenuItem(value: 'month', child: Text('Tháng này')),
              PopupMenuItem(value: 'custom', child: Text('Chọn khoảng...')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo ghi chú hoặc danh mục...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchText = value.toLowerCase());
              },
            ),
          ),

          // Hiển thị khoảng thời gian chọn
          if (_filter == 'custom' && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Khoảng: ${DateFormat('dd/MM/yyyy').format(_customRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_customRange!.end)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          // Tổng thu - chi ấn được
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedChartType = 'income'),
                  child: Column(
                    children: [
                      const Text('Tổng thu',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(
                        formatCurrency.format(totalIncome),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedChartType == 'income'
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _selectedChartType = 'expense'),
                  child: Column(
                    children: [
                      const Text('Tổng chi',
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(
                        formatCurrency.format(totalExpense),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedChartType == 'expense'
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Biểu đồ
          if (currentCategory.isNotEmpty)
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _selectedChartType == 'income'
                    ? 'Không có dữ liệu thu nhập'
                    : 'Không có dữ liệu chi tiêu',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

          // Chi tiết danh mục
          Expanded(
            child: ListView(
              children: currentCategory.entries
                  .map(
                    (e) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.primaries[
                            currentCategory.keys.toList().indexOf(e.key) %
                                Colors.primaries.length],
                        child: const Icon(Icons.category, color: Colors.white),
                      ),
                      title: Text(e.key),
                      trailing: Text(
                        '${formatCurrency.format(e.value)}  (${(e.value / (currentTotal == 0 ? 1 : currentTotal) * 100).toStringAsFixed(1)}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}