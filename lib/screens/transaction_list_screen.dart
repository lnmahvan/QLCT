import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../widgets/transaction_search.dart';
import '../widgets/transaction_summary.dart';
import '../widgets/transaction_list_view.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'all'; // all, today, month, custom
  String _searchText = '';
  final _searchController = TextEditingController();
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
        backgroundColor: Colors.teal,
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
          TransactionSearch(
            controller: _searchController,
            searchText: _searchText,
            onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
            onClear: () => setState(() => _searchText = ''),
          ),
          if (_filter == 'custom' && _customRange != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Khoảng: ${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year} - ${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          TransactionSummary(
            expense: expense,
            filter: _filter,
            customRange: _customRange,
            searchText: _searchText,
          ),
          Expanded(
            child: TransactionListView(
              expense: expense,
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