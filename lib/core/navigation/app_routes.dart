import 'package:flutter/material.dart';
import 'route_transitions.dart';
import '../../features/transactions/view/add_transaction_page.dart';
import '../../features/transactions/view/transactions_page.dart';
import '../../features/transactions/view/transaction_details_page.dart';
import '../../core/database/models/transaction_model.dart';
import '../../features/summary/view/summary_page.dart';
import '../../features/settings/view/settings_page.dart';
import '../../core/navigation/bottom_nav_scaffold.dart';

/// AppRoutes defines all route names and navigation methods for the app.
/// This centralizes routing logic and provides type-safe navigation.
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // ========== Route Names ==========

  /// Home/Transactions list page (root)
  static const String home = '/';

  /// Transactions list page
  static const String transactions = '/transactions';

  /// Add transaction form page
  static const String addTransaction = '/add-transaction';

  /// Daily and weekly summary page
  static const String summary = '/summary';

  /// Transaction details page
  static const String transactionDetails = '/transaction-details';

  /// Settings page (future)
  static const String settings = '/settings';

  /// Categories management page (future)
  static const String categories = '/categories';

  // ========== Navigation Methods ==========

  /// Navigate to a named route with slide right transition
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Navigate to a widget with slide right transition
  static Future<T?> pushWidget<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.push<T>(
      context,
      RouteTransitions.slideRight(page: page, settings: settings),
    );
  }

  /// Navigate to a widget with slide bottom transition (modal-style)
  static Future<T?> pushModal<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.push<T>(
      context,
      RouteTransitions.slideBottom(page: page, settings: settings),
    );
  }

  /// Navigate to a widget with fade transition
  static Future<T?> pushFade<T>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
  }) {
    return Navigator.push<T>(
      context,
      RouteTransitions.fade(page: page, settings: settings),
    );
  }

  /// Replace current route with a new one
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Replace current route with a widget
  static Future<T?> pushReplacementWidget<T, TO>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      RouteTransitions.slideRight(page: page, settings: settings),
      result: result,
    );
  }

  /// Clear navigation stack and go to a named route
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate ?? (route) => false,
      arguments: arguments,
    );
  }

  /// Go back to previous page
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Pop until a specific route
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop until home (root route)
  static void popToHome(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName(home));
  }

  // ========== Route Generator ==========

  /// Generate routes for MaterialApp onGenerateRoute
  /// This function is called when Navigator.pushNamed is used
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // Extract route name
    final routeName = settings.name;

    // Handle route generation based on route name
    switch (routeName) {
      case home:
        return RouteTransitions.none(
          page: const BottomNavScaffold(),
          settings: settings,
        );

      case addTransaction:
        final transaction = settings.arguments as TransactionModel?;
        return RouteTransitions.slideBottom(
          page: AddTransactionPage(transaction: transaction),
          settings: settings,
        );

      case transactions:
        return RouteTransitions.slideRight(
          page: const TransactionsPage(),
          settings: settings,
        );

      case summary:
        return RouteTransitions.slideRight(
          page: const SummaryPage(),
          settings: settings,
        );

      case transactionDetails:
        final transaction = settings.arguments as TransactionModel;
        return RouteTransitions.slideRight(
          page: TransactionDetailsPage(transaction: transaction),
          settings: settings,
        );

      case AppRoutes.settings:
        return RouteTransitions.slideRight(
          page: const SettingsPage(),
          settings: settings,
        );

      case categories:
        // Categories management page not yet implemented
        return RouteTransitions.slideRight(
          page: const Placeholder(),
          settings: settings,
        );

      default:
        // Return null to use default route handling
        return null;
    }
  }

  /// Generate route for unknown routes (404 handler)
  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return RouteTransitions.fade(
      page: Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'Route "${settings.name}" not found',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }
}
