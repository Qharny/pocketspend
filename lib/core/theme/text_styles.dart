import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTextStyles defines all text styles used throughout the Pocket Spend app.
/// The typography system follows Material Design 3 guidelines with customizations
/// for financial data display (currency amounts, categories, dates).
class AppTextStyles {
  AppTextStyles._(); // Private constructor to prevent instantiation

  // ========== Base Font Family ==========
  static const String fontFamily = 'Roboto';
  static const String numberFontFamily = 'RobotoMono'; // Monospaced for numbers

  // ========== Display Styles ==========
  // Large, prominent text for major headings and large amounts
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // ========== Headline Styles ==========
  // Section headers and page titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // ========== Title Styles ==========
  // Card titles, dialog headers
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // ========== Body Styles ==========
  // Main content text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // ========== Label Styles ==========
  // Buttons, chips, small labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ========== Custom Styles for Finance App ==========

  /// Large currency amount display (e.g., summary totals)
  static const TextStyle currencyLarge = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Medium currency amount (e.g., transaction list items)
  static const TextStyle currencyMedium = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.3,
  );

  /// Small currency amount (e.g., category totals)
  static const TextStyle currencySmall = TextStyle(
    fontFamily: numberFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Category label style
  static const TextStyle category = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    height: 1.4,
  );

  /// Date display style
  static const TextStyle date = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.4,
  );

  /// Transaction note style
  static const TextStyle note = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Input field hint style
  static const TextStyle hint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  // ========== Helper Methods ==========

  /// Returns currency style with income color
  static TextStyle currencyIncome(BuildContext context, {bool large = false}) {
    final baseStyle = large ? currencyLarge : currencyMedium;
    return baseStyle.copyWith(color: AppColors.getIncomeColor(context));
  }

  /// Returns currency style with expense color
  static TextStyle currencyExpense(BuildContext context, {bool large = false}) {
    final baseStyle = large ? currencyLarge : currencyMedium;
    return baseStyle.copyWith(color: AppColors.getExpenseColor(context));
  }

  /// Returns text style with custom color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Returns text style with opacity
  static TextStyle withOpacity(TextStyle style, double opacity) {
    return style.copyWith(
      color:
          style.color?.withOpacity(opacity) ??
          Colors.black.withOpacity(opacity),
    );
  }

  /// Returns bold version of a style
  static TextStyle bold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w700);
  }

  /// Returns semibold version of a style
  static TextStyle semiBold(TextStyle style) {
    return style.copyWith(fontWeight: FontWeight.w600);
  }
}
