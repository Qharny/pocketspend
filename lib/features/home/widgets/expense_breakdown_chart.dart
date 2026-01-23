import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Expense Breakdown Chart Widget
/// Shows top expense categories with custom bar chart visualization
class ExpenseBreakdownChart extends StatelessWidget {
  final Map<String, double> expensesByCategory;

  const ExpenseBreakdownChart({super.key, required this.expensesByCategory});

  @override
  Widget build(BuildContext context) {
    if (expensesByCategory.isEmpty) {
      return _EmptyChart();
    }

    // Get top 5 categories
    final topCategories = expensesByCategory.entries.take(5).toList();
    final maxAmount = topCategories.first.value;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Expense Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Chart Bars
            ...topCategories.map((entry) {
              final percentage = (entry.value / maxAmount);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CategoryBar(
                  category: entry.key,
                  amount: entry.value,
                  percentage: percentage,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Individual category bar in the chart
class _CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  // Get color for category
  Color _getCategoryColor(BuildContext context, String category) {
    final colors = [
      AppColors.expenseLight,
      AppColors.secondaryLight,
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
    ];

    final index = category.hashCode % colors.length;
    return Theme.of(context).brightness == Brightness.light
        ? colors[index]
        : colors[index].withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    final barColor = _getCategoryColor(context, category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category name and amount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _getCategoryIcon(category),
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
              'GHS ${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        Stack(
          children: [
            // Background
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Filled portion
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍔';
      case 'transport':
        return '🚗';
      case 'data':
        return '📱';
      case 'utilities':
        return '💡';
      case 'salary':
        return '💰';
      case 'freelance':
        return '💼';
      default:
        return '📝';
    }
  }
}

/// Empty chart state
class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No expenses to show',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
