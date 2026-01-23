import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../home/widgets/period_toggle.dart';
import '../../../core/theme/app_colors.dart';

/// Summary Page
/// Shows daily/weekly insights with charts - turns data into behavior change
class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  Period _selectedPeriod = Period.thisMonth;

  List<TransactionModel> get _filteredTransactions {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: ValueListenableBuilder<Box<TransactionModel>>(
        valueListenable: TransactionDatabase.box.listenable(),
        builder: (context, box, child) {
          final transactions = _filteredTransactions;
          final totalIncome = TransactionDatabase.getTotalIncome(transactions);
          final totalExpense = TransactionDatabase.getTotalExpenses(
            transactions,
          );
          final netBalance = totalIncome - totalExpense;
          final expensesByCategory = TransactionDatabase.getExpensesByCategory(
            transactions,
          );
          final currencySymbol = SettingsDatabase.getCurrencySymbol();

          if (transactions.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Toggle
                PeriodToggle(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (period) {
                    setState(() {
                      _selectedPeriod = period;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Summary Stats
                _SummaryStatsCard(
                  income: totalIncome,
                  expense: totalExpense,
                  balance: netBalance,
                  currencySymbol: currencySymbol,
                ),
                const SizedBox(height: 24),

                // Category Breakdown
                if (expensesByCategory.isNotEmpty) ...[
                  Text(
                    'Expense Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CategoryBreakdownChart(
                    expensesByCategory: expensesByCategory,
                    totalExpense: totalExpense,
                    currencySymbol: currencySymbol,
                  ),
                ],
              ],
            ),
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
              Icons.bar_chart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some transactions to see insights',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary Stats Card showing Income, Expense, and Balance
class _SummaryStatsCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;
  final String currencySymbol;

  const _SummaryStatsCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = balance >= 0
        ? AppColors.getIncomeColor(context)
        : AppColors.getExpenseColor(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Net Balance
            Text(
              'Net Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${balance >= 0 ? '+' : ''}$currencySymbol ${balance.abs().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: balanceColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Income and Expense Row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Income',
                    amount: income,
                    color: AppColors.getIncomeColor(context),
                    icon: Icons.arrow_downward,
                    currencySymbol: currencySymbol,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _StatItem(
                    label: 'Expense',
                    amount: expense,
                    color: AppColors.getExpenseColor(context),
                    icon: Icons.arrow_upward,
                    currencySymbol: currencySymbol,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final String currencySymbol;

  const _StatItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$currencySymbol ${amount.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Category Breakdown Chart showing expense distribution
class _CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> expensesByCategory;
  final double totalExpense;
  final String currencySymbol;

  const _CategoryBreakdownChart({
    required this.expensesByCategory,
    required this.totalExpense,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final topCategories = expensesByCategory.entries.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: topCategories.map((entry) {
            final percentage = (entry.value / totalExpense * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _CategoryBar(
                category: entry.key,
                amount: entry.value,
                percentage: percentage,
                maxAmount: topCategories.first.value,
                currencySymbol: currencySymbol,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final double maxAmount;
  final String currencySymbol;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.maxAmount,
    required this.currencySymbol,
  });

  Color _getCategoryColor(BuildContext context, int index) {
    final colors = [
      AppColors.expenseLight,
      AppColors.secondaryLight,
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
    ];
    return Theme.of(context).brightness == Brightness.light
        ? colors[index % colors.length]
        : colors[index % colors.length].withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    final barColor = _getCategoryColor(context, category.hashCode % 5);
    final widthFactor = amount / maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  TransactionDatabase.getCategoryIcon(category),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  category,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            Text(
              '${percentage.toStringAsFixed(1)}% • $currencySymbol ${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
