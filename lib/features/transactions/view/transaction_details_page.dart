import 'package:flutter/material.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Transaction Details Page
/// Shows detailed information about a single transaction
class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: TransactionDatabase.box.listenable(
        keys: [transaction.id],
      ),
      builder: (context, box, _) {
        final currentTransaction = box.get(transaction.id) ?? transaction;
        final amountColor = currentTransaction.isIncome
            ? AppColors.getIncomeColor(context)
            : AppColors.getExpenseColor(context);
        final currencySymbol = SettingsDatabase.getCurrencySymbol();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    _deleteTransaction(context, currentTransaction),
                tooltip: 'Delete',
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: amountColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentTransaction.isIncome ? 'Income' : 'Expense',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentTransaction.isIncome ? '+' : '-'}$currencySymbol ${currentTransaction.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      _DetailItem(
                        icon: Icons.category_outlined,
                        label: 'Category',
                        value: currentTransaction.category,
                        emoji: TransactionDatabase.getCategoryIcon(
                          currentTransaction.category,
                        ),
                      ),

                      const Divider(height: 32),

                      // Date
                      _DetailItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Date',
                        value: DateFormat(
                          'EEEE, MMM dd, yyyy',
                        ).format(currentTransaction.date),
                      ),

                      const Divider(height: 32),

                      // Time
                      _DetailItem(
                        icon: Icons.access_time_outlined,
                        label: 'Time',
                        value: DateFormat(
                          'h:mm a',
                        ).format(currentTransaction.date),
                      ),

                      if (currentTransaction.note != null) ...[
                        const Divider(height: 32),

                        // Note
                        _DetailItem(
                          icon: Icons.note_outlined,
                          label: 'Note',
                          value: currentTransaction.note!,
                          maxLines: null,
                        ),
                      ],

                      const Divider(height: 32),

                      // Transaction ID
                      _DetailItem(
                        icon: Icons.tag_outlined,
                        label: 'Transaction ID',
                        value: currentTransaction.id,
                        valueStyle: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          AppRoutes.push(
                            context,
                            AppRoutes.addTransaction,
                            arguments: currentTransaction,
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Transaction'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _deleteTransaction(context, currentTransaction),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text(
                          'Delete Transaction',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteTransaction(
    BuildContext context,
    TransactionModel currentTransaction,
  ) {
    final currencySymbol = SettingsDatabase.getCurrencySymbol();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this ${currentTransaction.isIncome ? 'income' : 'expense'} of $currencySymbol ${currentTransaction.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final deleted = await TransactionDatabase.deleteTransaction(
                currentTransaction.id,
              );
              if (deleted) {
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close details page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${currentTransaction.isIncome ? 'Income' : 'Expense'} deleted',
                      ),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await TransactionDatabase.addTransaction(
                            currentTransaction,
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Detail Item Widget
class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? emoji;
  final TextStyle? valueStyle;
  final int? maxLines;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.emoji,
    this.valueStyle,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (emoji != null) ...[
                    Text(emoji!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      value,
                      style:
                          valueStyle ??
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: maxLines,
                      overflow: maxLines == null
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
