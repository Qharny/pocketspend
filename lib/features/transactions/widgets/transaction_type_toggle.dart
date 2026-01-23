import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Type Toggle Widget
/// Large segmented control for Income/Expense selection
class TransactionTypeToggle extends StatelessWidget {
  final bool isIncome;
  final ValueChanged<bool> onChanged;

  const TransactionTypeToggle({
    super.key,
    required this.isIncome,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: _TypeButton(
              label: 'Expense',
              isSelected: !isIncome,
              color: AppColors.getExpenseColor(context),
              onTap: () => onChanged(false),
            ),
          ),

          // Income Button
          Expanded(
            child: _TypeButton(
              label: 'Income',
              isSelected: isIncome,
              color: AppColors.getIncomeColor(context),
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual type button
class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
