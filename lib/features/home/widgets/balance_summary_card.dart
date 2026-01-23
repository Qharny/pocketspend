import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';

/// Balance Summary Card
/// Displays total balance, income, and expenses in a prominent card
class BalanceSummaryCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expenses;

  const BalanceSummaryCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: isDark ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Text(
              'Total Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),

            // Balance Amount
            Text(
              'GHS ${balance.toStringAsFixed(2)}',
              style: AppTextStyles.displaySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Income and Expenses Row
            Row(
              children: [
                // Income
                Expanded(
                  child: _BalanceItem(
                    label: 'Income',
                    amount: income,
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 16),

                // Expenses
                Expanded(
                  child: _BalanceItem(
                    label: 'Expenses',
                    amount: expenses,
                    isIncome: false,
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

/// Individual balance item (income or expense)
class _BalanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;

  const _BalanceItem({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final color = isIncome
        ? AppColors.getIncomeColor(context)
        : AppColors.getExpenseColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              isIncome ? '+ ' : '- ',
              style: AppTextStyles.titleLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Flexible(
              child: Text(
                'GHS ${amount.toStringAsFixed(2)}',
                style: AppTextStyles.titleLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
