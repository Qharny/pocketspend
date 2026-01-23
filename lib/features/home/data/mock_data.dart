/// Mock data for demonstrating the Pocket Spend home dashboard
/// This will be replaced with actual Hive database integration later

class MockTransaction {
  final String id;
  final double amount;
  final String category;
  final String? note;
  final DateTime date;
  final bool isIncome;

  MockTransaction({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.isIncome,
  });
}

class MockData {
  // Sample transactions
  static final List<MockTransaction> transactions = [
    // Recent income
    MockTransaction(
      id: '1',
      amount: 2000.00,
      category: 'Salary',
      note: 'Monthly salary',
      date: DateTime.now().subtract(const Duration(days: 1)),
      isIncome: true,
    ),

    // Recent expenses
    MockTransaction(
      id: '2',
      amount: 45.50,
      category: 'Food',
      note: 'Lunch at restaurant',
      date: DateTime.now().subtract(const Duration(hours: 3)),
      isIncome: false,
    ),
    MockTransaction(
      id: '3',
      amount: 20.00,
      category: 'Transport',
      note: 'Uber to work',
      date: DateTime.now().subtract(const Duration(hours: 8)),
      isIncome: false,
    ),
    MockTransaction(
      id: '4',
      amount: 150.00,
      category: 'Data',
      note: 'Monthly internet bundle',
      date: DateTime.now().subtract(const Duration(days: 2)),
      isIncome: false,
    ),
    MockTransaction(
      id: '5',
      amount: 80.00,
      category: 'Food',
      note: 'Grocery shopping',
      date: DateTime.now().subtract(const Duration(days: 3)),
      isIncome: false,
    ),
    MockTransaction(
      id: '6',
      amount: 35.00,
      category: 'Transport',
      note: 'Fuel',
      date: DateTime.now().subtract(const Duration(days: 4)),
      isIncome: false,
    ),
    MockTransaction(
      id: '7',
      amount: 200.00,
      category: 'Utilities',
      note: 'Electricity bill',
      date: DateTime.now().subtract(const Duration(days: 5)),
      isIncome: false,
    ),
    MockTransaction(
      id: '8',
      amount: 60.00,
      category: 'Food',
      note: 'Dinner with friends',
      date: DateTime.now().subtract(const Duration(days: 6)),
      isIncome: false,
    ),
    MockTransaction(
      id: '9',
      amount: 500.00,
      category: 'Freelance',
      note: 'Design project payment',
      date: DateTime.now().subtract(const Duration(days: 7)),
      isIncome: true,
    ),
    MockTransaction(
      id: '10',
      amount: 25.00,
      category: 'Transport',
      note: 'Taxi fare',
      date: DateTime.now().subtract(const Duration(days: 8)),
      isIncome: false,
    ),
  ];

  /// Get transactions for today
  static List<MockTransaction> getToday() {
    final today = DateTime.now();
    return transactions.where((t) {
      return t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day;
    }).toList();
  }

  /// Get transactions for this week
  static List<MockTransaction> getThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return transactions.where((t) {
      return t.date.isAfter(weekStart.subtract(const Duration(days: 1)));
    }).toList();
  }

  /// Get transactions for this month
  static List<MockTransaction> getThisMonth() {
    final now = DateTime.now();
    return transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();
  }

  /// Calculate total income for a list of transactions
  static double getTotalIncome(List<MockTransaction> transactions) {
    return transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses for a list of transactions
  static double getTotalExpenses(List<MockTransaction> transactions) {
    return transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate balance (income - expenses)
  static double getBalance(List<MockTransaction> transactions) {
    return getTotalIncome(transactions) - getTotalExpenses(transactions);
  }

  /// Get expense breakdown by category
  static Map<String, double> getExpensesByCategory(
    List<MockTransaction> transactions,
  ) {
    final expenses = transactions.where((t) => !t.isIncome);
    final Map<String, double> breakdown = {};

    for (var transaction in expenses) {
      breakdown[transaction.category] =
          (breakdown[transaction.category] ?? 0) + transaction.amount;
    }

    // Sort by amount (highest first)
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  /// Get recent transactions (sorted by date, most recent first)
  static List<MockTransaction> getRecentTransactions({int limit = 10}) {
    final sorted = List<MockTransaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Get category icon based on category name
  static String getCategoryIcon(String category) {
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
      case 'entertainment':
        return '🎬';
      case 'shopping':
        return '🛍️';
      case 'health':
        return '🏥';
      case 'investment':
        return '📈';
      case 'gift':
        return '🎁';
      default:
        return '📝';
    }
  }

  /// Predefined expense categories
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Data',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Health',
    'Other',
  ];

  /// Predefined income categories
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  /// Add a new transaction to the list
  static void addTransaction(MockTransaction transaction) {
    transactions.insert(0, transaction); // Add to beginning for most recent
  }

  /// Generate a unique ID for new transactions
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Delete a transaction by ID
  static bool deleteTransaction(String id) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      transactions.removeAt(index);
      return true;
    }
    return false;
  }

  /// Group transactions by date
  static Map<String, List<MockTransaction>> groupTransactionsByDate(
    List<MockTransaction> transactionList,
  ) {
    final groups = <String, List<MockTransaction>>{};
    final now = DateTime.now();

    // Sort by date descending first
    final sorted = List<MockTransaction>.from(transactionList)
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

  /// Filter transactions by parameters
  static List<MockTransaction> filterTransactions({
    List<MockTransaction>? source,
    String? category,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool? isIncome,
  }) {
    var filtered = source ?? List<MockTransaction>.from(transactions);

    // Filter by category
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((t) => t.category == category).toList();
    }

    // Filter by date range
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

    // Filter by type
    if (isIncome != null) {
      filtered = filtered.where((t) => t.isIncome == isIncome).toList();
    }

    return filtered;
  }

  /// Calculate total for a date group
  static double getGroupTotal(List<MockTransaction> transactions) {
    return transactions.fold(0.0, (sum, t) {
      return sum + (t.isIncome ? t.amount : -t.amount);
    });
  }
}
