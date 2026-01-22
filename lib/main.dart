import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_routes.dart';

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

      // Home page (temporary until real pages are connected)
      home: const HomePage(),
    );
  }
}

/// Temporary home page to demonstrate the theme
/// This will be replaced with the actual TransactionsPage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Spend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.summarize_outlined),
            onPressed: () {
              AppRoutes.push(context, AppRoutes.summary);
            },
            tooltip: 'Summary',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              AppRoutes.push(context, AppRoutes.settings);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Icon
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),

              // Welcome Text
              Text(
                'Welcome to Pocket Spend',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Your offline-first personal expense tracker',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Demo Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme Demo',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      const Text('The app now features:'),
                      const SizedBox(height: 8),
                      const Text('✓ Professional color scheme'),
                      const Text('✓ Light and dark mode support'),
                      const Text('✓ Custom page transitions'),
                      const Text('✓ Finance-focused typography'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              FilledButton.icon(
                onPressed: () {
                  AppRoutes.push(context, AppRoutes.addTransaction);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Transaction'),
              ),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  AppRoutes.push(context, AppRoutes.summary);
                },
                icon: const Icon(Icons.bar_chart),
                label: const Text('View Summary'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppRoutes.pushModal(
            context,
            const Placeholder(), // Will be AddTransactionPage
          );
        },
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
