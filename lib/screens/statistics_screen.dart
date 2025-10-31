import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../widgets/statistics_chart.dart';
import '../widgets/statistics_summary.dart';
import '../widgets/statistics_category_list.dart';
import '../widgets/statistics_search.dart';
import 'transaction_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _filter = 'all';
  String _searchText = '';
  String _selectedChartType = 'expense';
  DateTimeRange? _customRange;
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatisticsSearch(
              controller: _searchController,
              searchText: _searchText,
              onChanged: (val) =>
                  setState(() => _searchText = val.toLowerCase()),
              onClear: () => setState(() => _searchText = ''),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionListScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Xem chi tiết',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            if (_filter == 'custom' && _customRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Khoảng: ${DateFormat('dd/MM/yyyy').format(_customRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_customRange!.end)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

            StatisticsSummary(
              expense: expense,
              selectedChartType: _selectedChartType,
              onSelectType: (type) => setState(() => _selectedChartType = type),
              filter: _filter,
              customRange: _customRange,
              searchText: _searchText,
            ),

            // Line chart for thu/chi theo ngày trong tháng
            buildLineChart(expense),

            StatisticsChart(
              expense: expense,
              selectedChartType: _selectedChartType,
              filter: _filter,
              customRange: _customRange,
              searchText: _searchText,
            ),

            SizedBox(
              height: 400,
              child: StatisticsCategoryList(
                expense: expense,
                selectedChartType: _selectedChartType,
                filter: _filter,
                customRange: _customRange,
                searchText: _searchText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Biểu đồ đường thể hiện thu nhập và chi tiêu theo thời gian
  Widget buildLineChart(ExpenseModel expense) {
    final now = DateTime.now();
    final currentMonth = now.month;

    // Gom dữ liệu theo ngày trong tháng
    final incomeData = <int, double>{};
    final expenseData = <int, double>{};

    for (var t in expense.transactions) {
      if (t.date.month == currentMonth && t.date.year == now.year) {
        final day = t.date.day;
        if (t.type == 'income') {
          incomeData[day] = (incomeData[day] ?? 0) + t.amount;
        } else {
          expenseData[day] = (expenseData[day] ?? 0) + t.amount;
        }
      }
    }

    final allDays = List<int>.generate(31, (i) => i + 1);
    final incomeSpots = allDays
        .map((d) => FlSpot(d.toDouble(), (incomeData[d] ?? 0)))
        .toList();
    final expenseSpots = allDays
        .map((d) => FlSpot(d.toDouble(), (expenseData[d] ?? 0)))
        .toList();

    final maxY = [
      ...incomeData.values,
      ...expenseData.values,
    ].fold<double>(0, (prev, e) => e > prev ? e : prev);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biểu đồ thu/chi theo thời gian',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minX: 1,
                maxX: 31,
                minY: 0,
                maxY: maxY + 50,
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) =>
                          Text(value.toInt().toString()),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Text(value.toInt().toString());
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    spots: incomeSpots,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    spots: expenseSpots,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.circle, size: 10, color: Colors.green),
              SizedBox(width: 4),
              Text('Thu nhập  '),
              Icon(Icons.circle, size: 10, color: Colors.red),
              SizedBox(width: 4),
              Text('Chi tiêu'),
            ],
          ),
        ],
      ),
    );
  }
}
