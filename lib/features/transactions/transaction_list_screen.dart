import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/expense_model.dart';
import '../../features/transactions/widgets/transaction_search.dart';
import '../../features/transactions/widgets/transaction_summary.dart';
import '../../features/transactions/widgets/transaction_list_view.dart';

class TransactionListScreen extends StatefulWidget {
  final String? selectedWalletId;

  const TransactionListScreen({super.key, this.selectedWalletId});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _filter = 'all'; 
  String _searchText = '';
  final _searchController = TextEditingController();
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final expense = Provider.of<ExpenseModel>(context);
    // final transactions = widget.selectedWalletId == null
    //     ? expense.transactions
    //     : expense.transactions
    //           .where((t) => t.walletId == widget.selectedWalletId)
    //           .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 20),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
          ),
          title: const Text(
            'Danh sách giao dịch',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Tooltip(
              message: 'Lọc giao dịch',
              child: PopupMenuButton<String>(
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
                icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'all', child: Text('Tất cả')),
                  PopupMenuItem(value: 'today', child: Text('Hôm nay')),
                  PopupMenuItem(value: 'month', child: Text('Tháng này')),
                  PopupMenuItem(value: 'custom', child: Text('Chọn khoảng...')),
                ],
              ),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
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
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: Text(
                    'Khoảng: ${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year} - ${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}',
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            TransactionSummary(
              expense: expense,
              filter: _filter,
              customRange: _customRange,
              searchText: _searchText,
              selectedWalletId: widget.selectedWalletId, 
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TransactionListView(
                    expense: expense,
                    filter: _filter,
                    customRange: _customRange,
                    searchText: _searchText,
                    selectedWalletId: widget.selectedWalletId, 
                    // scrollPhysics: const BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
