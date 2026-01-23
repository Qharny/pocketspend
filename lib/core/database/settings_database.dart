import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Settings Database Service
/// Manages app-wide settings like currency and theme
class SettingsDatabase {
  static const String _boxName = 'settings';
  static Box? _box;

  // Setting Keys
  static const String keyCurrency = 'currency';
  static const String keyThemeMode = 'themeMode';

  /// Notifier for theme changes
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  /// Initialize Settings Hive database
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    // Initialize theme notifier with stored value
    themeNotifier.value = getThemeMode();
  }

  /// Get the box instance
  static Box get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('SettingsDatabase not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get current theme mode
  static ThemeMode getThemeMode() {
    final modeString = box.get(keyThemeMode, defaultValue: 'system');
    switch (modeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Set theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await box.put(keyThemeMode, modeString);
    themeNotifier.value = mode;
  }

  /// Get currency code (e.g., GHS, USD)
  static String getCurrency() {
    return box.get(keyCurrency, defaultValue: 'GHS');
  }

  /// Set currency code
  static Future<void> setCurrency(String code) async {
    await box.put(keyCurrency, code);
  }

  /// Get currency symbol
  static String getCurrencySymbol() {
    final code = getCurrency();
    switch (code) {
      case 'GHS':
        return 'GHS';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return 'GHS';
    }
  }

  /// Get currency name
  static String getCurrencyName() {
    final code = getCurrency();
    switch (code) {
      case 'GHS':
        return 'Ghanaian Cedi';
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      case 'GBP':
        return 'British Pound';
      default:
        return 'Ghanaian Cedi';
    }
  }
}

// Extension to help with ThemeMode names
extension ThemeModeExtension on ThemeMode {
  String get name {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
