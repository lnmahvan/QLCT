import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import 'widgets/statistics_chart.dart';
import 'widgets/statistics_summary.dart';
import 'widgets/statistics_category_list.dart';
import 'widgets/statistics_search.dart';

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
      body: Column(
        children: [
          StatisticsSearch(
            controller: _searchController,
            searchText: _searchText,
            onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
            onClear: () => setState(() => _searchText = ''),
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

          StatisticsChart(
            expense: expense,
            selectedChartType: _selectedChartType,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),

          Expanded(
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
    );
  }
}