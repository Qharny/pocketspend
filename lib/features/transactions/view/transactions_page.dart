import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../widgets/dismissible_transaction_item.dart';
import '../widgets/transaction_date_section.dart';
import 'transaction_details_page.dart';

/// Transactions Page
/// Shows complete history of all transactions grouped by date
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? _selectedCategory;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool? _typeFilter; // null = all, true = income, false = expense

  List<TransactionModel> get _filteredTransactions {
    return TransactionDatabase.filterTransactions(
      category: _selectedCategory,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
      isIncome: _typeFilter,
    );
  }

  Map<String, List<TransactionModel>> get _groupedTransactions {
    return TransactionDatabase.groupTransactionsByDate(_filteredTransactions);
  }

  bool get _hasActiveFilters {
    return _selectedCategory != null ||
        _dateFrom != null ||
        _dateTo != null ||
        _typeFilter != null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_dateFrom != null || _dateTo != null) count++;
    if (_typeFilter != null) count++;
    return count;
  }

  void _deleteTransaction(TransactionModel transaction) async {
    final deleted = await TransactionDatabase.deleteTransaction(transaction.id);
    if (deleted) {
      if (mounted) {
        setState(() {});
        final currencySymbol = SettingsDatabase.getCurrencySymbol();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${transaction.isIncome ? 'Income' : 'Expense'} deleted: $currencySymbol ${transaction.amount.toStringAsFixed(2)}',
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await TransactionDatabase.addTransaction(transaction);
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _dateFrom = null;
      _dateTo = null;
      _typeFilter = null;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(),
    );
  }

  Widget _buildFilterSheet() {
    String? tempCategory = _selectedCategory;
    DateTime? tempDateFrom = _dateFrom;
    DateTime? tempDateTo = _dateTo;
    bool? tempTypeFilter = _typeFilter;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Transactions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        tempCategory = null;
                        tempDateFrom = null;
                        tempDateTo = null;
                        tempTypeFilter = null;
                        setModalState(() {});
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Type Filter
                Text('Type', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilterChip(
                        label: const Text('All'),
                        selected: tempTypeFilter == null,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTypeFilter = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Income'),
                        selected: tempTypeFilter == true,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTypeFilter = selected ? true : null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilterChip(
                        label: const Text('Expense'),
                        selected: tempTypeFilter == false,
                        onSelected: (selected) {
                          setModalState(() {
                            tempTypeFilter = selected ? false : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Category Filter
                Text('Category', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: tempCategory,
                  decoration: const InputDecoration(
                    hintText: 'All Categories',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...TransactionDatabase.expenseCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          '${TransactionDatabase.getCategoryIcon(cat)} $cat',
                        ),
                      );
                    }),
                    ...TransactionDatabase.incomeCategories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(
                          '${TransactionDatabase.getCategoryIcon(cat)} $cat',
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setModalState(() {
                      tempCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 32),

                // Apply Button
                FilledButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = tempCategory;
                      _dateFrom = tempDateFrom;
                      _dateTo = tempDateTo;
                      _typeFilter = tempTypeFilter;
                    });
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
                tooltip: 'Filter',
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_activeFilterCount',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<TransactionModel>>(
        valueListenable: TransactionDatabase.box.listenable(),
        builder: (context, box, child) {
          final groupedTransactions = _groupedTransactions;

          return Column(
            children: [
              // Active filter chips
              if (_hasActiveFilters)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_typeFilter != null)
                              Chip(
                                label: Text(
                                  _typeFilter! ? 'Income' : 'Expense',
                                ),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _typeFilter = null;
                                  });
                                },
                              ),
                            if (_selectedCategory != null)
                              Chip(
                                label: Text(_selectedCategory!),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setState(() {
                                    _selectedCategory = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // Transaction List
              Expanded(
                child: groupedTransactions.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView.builder(
                          itemCount: groupedTransactions.length,
                          itemBuilder: (context, index) {
                            final dateKey = groupedTransactions.keys.elementAt(
                              index,
                            );
                            final transactions = groupedTransactions[dateKey]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TransactionDateSection(
                                  dateLabel: dateKey,
                                  transactions: transactions,
                                ),
                                ...transactions.map((transaction) {
                                  return DismissibleTransactionItem(
                                    transaction: transaction,
                                    onDelete: _deleteTransaction,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransactionDetailsPage(
                                                transaction: transaction,
                                              ),
                                        ),
                                      ).then((_) {
                                        // Refresh list when returning
                                        setState(() {});
                                      });
                                    },
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _hasActiveFilters
                  ? 'No matching transactions'
                  : 'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _hasActiveFilters
                  ? 'Try adjusting your filters'
                  : 'Start tracking your expenses',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
