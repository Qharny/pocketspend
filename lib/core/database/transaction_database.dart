import 'package:hive_flutter/hive_flutter.dart';
import 'models/transaction_model.dart';

/// Transaction Database Service
/// Manages all transaction data with Hive persistent storage
class TransactionDatabase {
  static const String _boxName = 'transactions';
  static Box<TransactionModel>? _box;

  // Predefined categories (keep as constants)
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Utilities',
    'Data',
    'Health',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  /// Initialize Hive database
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionModelAdapter());
    _box = await Hive.openBox<TransactionModel>(_boxName);
  }

  /// Get the box instance
  static Box<TransactionModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception(
        'TransactionDatabase not initialized. Call init() first.',
      );
    }
    return _box!;
  }

  /// Add a new transaction
  static Future<void> addTransaction(TransactionModel transaction) async {
    await box.put(transaction.id, transaction);
  }

  /// Get transaction by ID
  static TransactionModel? getTransaction(String id) {
    return box.get(id);
  }

  /// Get all transactions
  static List<TransactionModel> getAllTransactions() {
    return box.values.toList();
  }

  /// Update a transaction
  static Future<void> updateTransaction(TransactionModel transaction) async {
    await box.put(transaction.id, transaction);
  }

  /// Delete a transaction
  static Future<bool> deleteTransaction(String id) async {
    if (box.containsKey(id)) {
      await box.delete(id);
      return true;
    }
    return false;
  }

  /// Delete all transactions
  static Future<void> clearAll() async {
    await box.clear();
  }

  /// Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get category icon emoji
  static String getCategoryIcon(String category) {
    const icons = {
      'Food': '🍔',
      'Transport': '🚗',
      'Shopping': '🛍️',
      'Entertainment': '🎬',
      'Utilities': '💡',
      'Data': '📱',
      'Health': '💊',
      'Salary': '💰',
      'Freelance': '💼',
      'Investment': '📈',
      'Gift': '🎁',
      'Other': '📝',
    };
    return icons[category] ?? '📝';
  }

  /// Filter transactions
  static List<TransactionModel> filterTransactions({
    List<TransactionModel>? source,
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isIncome,
  }) {
    var filtered = source ?? getAllTransactions();

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((t) => t.category == category).toList();
    }

    if (dateFrom != null) {
      filtered = filtered.where((t) {
        return t.date.isAfter(dateFrom.subtract(const Duration(days: 1)));
      }).toList();
    }

    if (dateTo != null) {
      filtered = filtered.where((t) {
        return t.date.isBefore(dateTo.add(const Duration(days: 1)));
      }).toList();
    }

    if (isIncome != null) {
      filtered = filtered.where((t) => t.isIncome == isIncome).toList();
    }

    return filtered;
  }

  /// Group transactions by date
  static Map<String, List<TransactionModel>> groupTransactionsByDate(
    List<TransactionModel> transactionList,
  ) {
    final groups = <String, List<TransactionModel>>{};
    final now = DateTime.now();

    // Sort by date descending first
    final sorted = List<TransactionModel>.from(transactionList)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var transaction in sorted) {
      final dateKey = _formatDateGroupKey(transaction.date, now);
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(transaction);
    }

    return groups;
  }

  /// Format date into group key
  static String _formatDateGroupKey(DateTime date, DateTime now) {
    // Today
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    // Yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    // This week (show day name)
    final weekAgo = now.subtract(const Duration(days: 7));
    if (date.isAfter(weekAgo)) {
      final days = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return days[date.weekday - 1];
    }

    // This year (show month and day)
    if (date.year == now.year) {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }

    // Previous years (show full date)
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Calculate total for a group
  static double getGroupTotal(List<TransactionModel> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.isIncome ? t.amount : -t.amount);
    });
  }

  /// Get net balance from transactions
  static double getBalance(List<TransactionModel> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.isIncome ? t.amount : -t.amount);
    });
  }

  /// Get total income from transactions
  static double getTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total expenses from transactions
  static double getTotalExpenses(List<TransactionModel> transactions) {
    return transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get expenses grouped by category
  static Map<String, double> getExpensesByCategory(
    List<TransactionModel> transactions,
  ) {
    final expenses = transactions.where((t) => !t.isIncome);
    final grouped = <String, double>{};

    for (var transaction in expenses) {
      grouped[transaction.category] =
          (grouped[transaction.category] ?? 0) + transaction.amount;
    }

    // Sort by amount descending
    final sorted = Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sorted;
  }

  /// Get most recent transactions
  static List<TransactionModel> getRecentTransactions({int limit = 8}) {
    final sorted = List<TransactionModel>.from(getAllTransactions())
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(limit).toList();
  }

  /// Get transactions for today
  static List<TransactionModel> getToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return getAllTransactions().where((t) {
      return t.date.isAfter(today.subtract(const Duration(microseconds: 1))) &&
          t.date.isBefore(tomorrow);
    }).toList();
  }

  /// Get transactions for this week
  static List<TransactionModel> getThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    return getAllTransactions().where((t) {
      return t.date.isAfter(
        weekStartDate.subtract(const Duration(microseconds: 1)),
      );
    }).toList();
  }

  /// Get transactions for this month
  static List<TransactionModel> getThisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    return getAllTransactions().where((t) {
      return t.date.isAfter(
        monthStart.subtract(const Duration(microseconds: 1)),
      );
    }).toList();
  }
}
