
import 'package:flutter/material.dart';

/// AppColors defines all color constants used throughout the Pocket Spend app.
/// The color scheme is designed for a finance application with clear distinction
/// between income (green) and expenses (red/orange).
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ========== Primary Colors ==========
  // Deep teal/blue for trust and stability
  static const Color primaryLight = Color(0xFF00796B); // Teal 700
  static const Color primaryDark = Color(0xFF4DB6AC); // Teal 300

  static const Color primaryVariantLight = Color(0xFF004D40); // Teal 900
  static const Color primaryVariantDark = Color(0xFF80CBC4); // Teal 200

  // ========== Secondary Colors ==========
  // Complementary orange for accents
  static const Color secondaryLight = Color(0xFFFF6F00); // Orange 900
  static const Color secondaryDark = Color(0xFFFFB74D); // Orange 300

  // ========== Income Colors ==========
  // Green shades for positive transactions
  static const Color incomeLight = Color(0xFF388E3C); // Green 700
  static const Color incomeDark = Color(0xFF66BB6A); // Green 400

  static const Color incomeLightVariant = Color(0xFF4CAF50); // Green 500
  static const Color incomeDarkVariant = Color(0xFF81C784); // Green 300

  // ========== Expense Colors ==========
  // Warm red/orange for spending
  static const Color expenseLight = Color(0xFFE64A19); // Deep Orange 700
  static const Color expenseDark = Color(0xFFFF7043); // Deep Orange 400

  static const Color expenseLightVariant = Color(0xFFFF5722); // Deep Orange 500
  static const Color expenseDarkVariant = Color(0xFFFF8A65); // Deep Orange 300

  // ========== Background Colors ==========
  static const Color backgroundLight = Color(0xFFFAFAFA); // Grey 50
  static const Color backgroundDark = Color(0xFF121212); // True dark

  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color surfaceDark = Color(0xFF1E1E1E); // Elevated dark

  static const Color surfaceVariantLight = Color(0xFFF5F5F5); // Grey 100
  static const Color surfaceVariantDark = Color(
    0xFF2C2C2C,
  ); // Elevated dark variant

  // ========== Text Colors ==========
  static const Color textPrimaryLight = Color(0xFF212121); // Grey 900
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Grey 300

  static const Color textSecondaryLight = Color(0xFF757575); // Grey 600
  static const Color textSecondaryDark = Color(0xFF9E9E9E); // Grey 500

  static const Color textDisabledLight = Color(0xFFBDBDBD); // Grey 400
  static const Color textDisabledDark = Color(0xFF616161); // Grey 700

  // ========== Semantic Colors ==========
  // Success
  static const Color successLight = Color(0xFF2E7D32); // Green 800
  static const Color successDark = Color(0xFF66BB6A); // Green 400

  // Error
  static const Color errorLight = Color(0xFFC62828); // Red 800
  static const Color errorDark = Color(0xFFEF5350); // Red 400

  // Warning
  static const Color warningLight = Color(0xFFF57C00); // Orange 700
  static const Color warningDark = Color(0xFFFFB74D); // Orange 300

  // Info
  static const Color infoLight = Color(0xFF1976D2); // Blue 700
  static const Color infoDark = Color(0xFF64B5F6); // Blue 300

  // ========== Border & Divider Colors ==========
  static const Color borderLight = Color(0xFFE0E0E0); // Grey 300
  static const Color borderDark = Color(0xFF424242); // Grey 800

  static const Color dividerLight = Color(0xFFBDBDBD); // Grey 400
  static const Color dividerDark = Color(0xFF616161); // Grey 700

  // ========== Overlay Colors ==========
  static const Color overlayLight = Color(0x33000000); // 20% black
  static const Color overlayDark = Color(0x4DFFFFFF); // 30% white

  static const Color scrimLight = Color(0x99000000); // 60% black
  static const Color scrimDark = Color(0x99000000); // 60% black

  // ========== Shadow Colors ==========
  static const Color shadowLight = Color(0x1F000000); // 12% black
  static const Color shadowDark = Color(0x3D000000); // 24% black

  // ========== Helper Methods ==========

  /// Returns the appropriate income color based on theme brightness
  static Color getIncomeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? incomeLight
        : incomeDark;
  }

  /// Returns the appropriate expense color based on theme brightness
  static Color getExpenseColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? expenseLight
        : expenseDark;
  }

  /// Returns the appropriate text color based on theme brightness
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textPrimaryLight
        : textPrimaryDark;
  }

  /// Returns the appropriate secondary text color based on theme brightness
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? textSecondaryLight
        : textSecondaryDark;
  }

  /// Returns a color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
