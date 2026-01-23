import 'package:flutter/material.dart';
import '../../features/home/view/home_page.dart';
import '../../features/transactions/view/transactions_page.dart';

/// Bottom Navigation Scaffold
/// Main app structure with 4 persistent tabs
class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _currentIndex = 0;

  // Pages for each tab
  final List<Widget> _pages = [
    const HomePage(),
    const TransactionsPage(),
    const _SummaryPagePlaceholder(), // Will implement next
    const _SettingsPagePlaceholder(), // Will implement next
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Temporary placeholders
class _SummaryPagePlaceholder extends StatelessWidget {
  const _SummaryPagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: const Center(child: Text('Summary Screen Coming Soon')),
    );
  }
}

class _SettingsPagePlaceholder extends StatelessWidget {
  const _SettingsPagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings Screen Coming Soon')),
    );
  }
}
