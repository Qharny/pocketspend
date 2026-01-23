import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/period_toggle.dart';
import '../widgets/expense_breakdown_chart.dart';
import '../widgets/recent_transactions_list.dart';
import '../../../core/navigation/app_routes.dart';
import '../../transactions/view/transactions_page.dart';

/// Home Page / Dashboard
/// The main screen of Pocket Spend showing balance, period toggle, chart, and transactions
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Period _selectedPeriod = Period.thisMonth;

  // Get transactions based on selected period
  List<TransactionModel> _getFilteredTransactions() {
    switch (_selectedPeriod) {
      case Period.today:
        return TransactionDatabase.getToday();
      case Period.thisWeek:
        return TransactionDatabase.getThisWeek();
      case Period.thisMonth:
        return TransactionDatabase.getThisMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<TransactionModel>>(
      valueListenable: TransactionDatabase.box.listenable(),
      builder: (context, box, child) {
        final transactions = _getFilteredTransactions();
        final balance = TransactionDatabase.getBalance(transactions);
        final income = TransactionDatabase.getTotalIncome(transactions);
        final expenses = TransactionDatabase.getTotalExpenses(transactions);
        final expensesByCategory = TransactionDatabase.getExpensesByCategory(
          transactions,
        );
        final recentTransactions = TransactionDatabase.getRecentTransactions(
          limit: 8,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pocket Spend'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
              ValueListenableBuilder<ThemeMode>(
                valueListenable: SettingsDatabase.themeNotifier,
                builder: (context, mode, child) {
                  final isDark =
                      mode == ThemeMode.dark ||
                      (mode == ThemeMode.system &&
                          MediaQuery.of(context).platformBrightness ==
                              Brightness.dark);

                  return IconButton(
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: () {
                      final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
                      SettingsDatabase.setThemeMode(newMode);
                    },
                    tooltip: 'Toggle Theme',
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Balance Summary Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BalanceSummaryCard(
                      balance: balance,
                      income: income,
                      expenses: expenses,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Period Toggle
                  PeriodToggle(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() {
                        _selectedPeriod = period;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expense Breakdown Chart
                  ExpenseBreakdownChart(expensesByCategory: expensesByCategory),
                  const SizedBox(height: 24),

                  // Recent Transactions List
                  RecentTransactionsList(
                    transactions: recentTransactions,
                    onSeeAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionsPage(),
                        ),
                      ).then((_) {
                        // Refresh when returning from transactions page
                        setState(() {});
                      });
                    },
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await AppRoutes.push(
                context,
                AppRoutes.addTransaction,
              );
              // Refresh the homepage if a transaction was added
              if (result == true && mounted) {
                setState(() {});
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
            tooltip: 'Add new transaction',
          ),
        );
      },
    );
  }
}
