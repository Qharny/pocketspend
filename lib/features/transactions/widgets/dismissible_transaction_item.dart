import 'package:flutter/material.dart';
import '../../../core/database/models/transaction_model.dart';
import '../../home/widgets/transaction_list_item.dart';

/// Dismissible Transaction Item Widget
/// Wraps TransactionListItem with swipe-to-delete functionality
class DismissibleTransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final Function(TransactionModel)? onDelete;

  const DismissibleTransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.horizontal,
      background: _buildDeleteBackground(context, Alignment.centerLeft),
      secondaryBackground: _buildDeleteBackground(
        context,
        Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!(transaction);
        }
      },
      child: TransactionListItem(transaction: transaction, onTap: onTap),
    );
  }

  Widget _buildDeleteBackground(BuildContext context, Alignment alignment) {
    return Container(
      color: Theme.of(context).colorScheme.error,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.onError,
        size: 32,
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete this ${transaction.isIncome ? 'income' : 'expense'} of GHS ${transaction.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
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
