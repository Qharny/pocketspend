import 'package:flutter/material.dart';

/// Period selection options
enum Period { today, thisWeek, thisMonth }

/// Period Toggle Widget
/// Allows users to quickly switch between Today, This Week, and This Month views
class PeriodToggle extends StatelessWidget {
  final Period selectedPeriod;
  final ValueChanged<Period> onPeriodChanged;

  const PeriodToggle({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _PeriodButton(
              label: 'Today',
              isSelected: selectedPeriod == Period.today,
              onTap: () => onPeriodChanged(Period.today),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PeriodButton(
              label: 'This Week',
              isSelected: selectedPeriod == Period.thisWeek,
              onTap: () => onPeriodChanged(Period.thisWeek),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PeriodButton(
              label: 'This Month',
              isSelected: selectedPeriod == Period.thisMonth,
              onTap: () => onPeriodChanged(Period.thisMonth),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual period button
class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
