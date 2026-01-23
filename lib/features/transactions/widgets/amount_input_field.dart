import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Large Amount Input Field Widget
/// Auto-focused, numeric keyboard, optimized for quick entry
class AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isIncome;

  const AmountInputField({
    super.key,
    required this.controller,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor = isIncome
        ? AppColors.getIncomeColor(context)
        : AppColors.getExpenseColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Currency Label
          Text(
            'GHS',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Amount Input
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: amountColor,
                letterSpacing: -1,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                // Trigger rebuild to update IntrinsicWidth
              },
            ),
          ),

          // Underline
          Container(
            height: 3,
            width: 100,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: amountColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
