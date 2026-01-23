import 'package:flutter/material.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/theme/app_colors.dart';

/// Transaction Date Section Widget
/// Header for a group of transactions on the same date
class TransactionDateSection extends StatelessWidget {
  final String dateLabel;
  final List<TransactionModel> transactions;
  final bool showTotal;

  const TransactionDateSection({
    super.key,
    required this.dateLabel,
    required this.transactions,
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    final total = showTotal
        ? TransactionDatabase.getGroupTotal(transactions)
        : null;
    final totalColor = total != null && total >= 0
        ? AppColors.getIncomeColor(context)
        : AppColors.getExpenseColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (showTotal && total != null)
            Text(
              '${total >= 0 ? '+' : ''}GHS ${total.abs().toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: totalColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
