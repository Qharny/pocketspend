import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';
import 'core/navigation/bottom_nav_scaffold.dart';

void main() {
  runApp(const PocketSpendApp());
}

class PocketSpendApp extends StatelessWidget {
  const PocketSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App Configuration
      title: 'Pocket Spend',
      debugShowCheckedModeBanner: false,

      // Theme Configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system theme
      // Navigation Configuration
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,

      // Home - Bottom navigation with all tabs
      home: const BottomNavScaffold(),
    );
  }
}
