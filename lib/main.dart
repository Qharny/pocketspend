import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/bottom_nav_scaffold.dart';
import 'core/database/transaction_database.dart';
import 'core/database/settings_database.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive databases
  await TransactionDatabase.init();
  await SettingsDatabase.init();

  runApp(const PocketSpendApp());
}

class PocketSpendApp extends StatelessWidget {
  const PocketSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: SettingsDatabase.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          // App Configuration
          title: 'Pocket Spend',
          debugShowCheckedModeBanner: false,

          // Theme Configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,

          // Navigation Configuration
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          onUnknownRoute: AppRoutes.onUnknownRoute,

          // Home - Bottom navigation with all tabs
          home: const BottomNavScaffold(),
        );
      },
    );
  }
}
