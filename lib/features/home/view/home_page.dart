import 'package:flutter/material.dart';
import '../data/mock_data.dart';
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
  List<MockTransaction> _getFilteredTransactions() {
    switch (_selectedPeriod) {
      case Period.today:
        return MockData.getToday();
      case Period.thisWeek:
        return MockData.getThisWeek();
      case Period.thisMonth:
        return MockData.getThisMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _getFilteredTransactions();
    final balance = MockData.getBalance(transactions);
    final income = MockData.getTotalIncome(transactions);
    final expenses = MockData.getTotalExpenses(transactions);
    final expensesByCategory = MockData.getExpensesByCategory(transactions);
    final recentTransactions = MockData.getRecentTransactions(limit: 8);

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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              AppRoutes.push(context, AppRoutes.settings);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Refresh data from database
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
  }
}
