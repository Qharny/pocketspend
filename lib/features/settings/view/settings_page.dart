import 'package:flutter/material.dart';
import '../../home/data/mock_data.dart';

/// Settings Page
/// Light, simple settings - no bloat, offline-first
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // General Section
          _buildSectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: const Text('GHS - Ghanaian Cedi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showCurrencyPicker(context);
            },
          ),
          const Divider(),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Download all transactions as CSV'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _exportData(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Clear All Data',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            subtitle: const Text('Delete all transactions permanently'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _clearAllData(context);
            },
          ),
          const Divider(),

          // About Section
          _buildSectionHeader(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Pocket Spend'),
            subtitle: Text('Offline-first expense tracker'),
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy'),
            subtitle: Text('No login. No cloud. No tracking.'),
          ),
          const SizedBox(height: 24),

          // Footer
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Made with ❤️ for simple money tracking',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _currencyOption(context, 'GHS', 'Ghanaian Cedi'),
            _currencyOption(context, 'USD', 'US Dollar'),
            _currencyOption(context, 'EUR', 'Euro'),
            _currencyOption(context, 'GBP', 'British Pound'),
          ],
        ),
      ),
    );
  }

  Widget _currencyOption(BuildContext context, String code, String name) {
    return ListTile(
      title: Text(code),
      subtitle: Text(name),
      selected: code == 'GHS',
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Currency changed to $code')));
      },
    );
  }

  void _exportData(BuildContext context) {
    // Generate CSV
    final csv = _generateCSV(MockData.transactions);

    // Show share/download dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${MockData.transactions.length} transactions ready to export',
            ),
            const SizedBox(height: 16),
            Text('CSV Preview:', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                csv.split('\n').take(4).join('\n') + '\n...',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual file download/share
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon! CSV generated.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  String _generateCSV(List<MockTransaction> transactions) {
    final buffer = StringBuffer();
    buffer.writeln('Date,Type,Category,Amount,Note');

    for (var t in transactions) {
      final date =
          '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      final type = t.isIncome ? 'Income' : 'Expense';
      final note = t.note?.replaceAll(',', ';') ?? '';
      buffer.writeln('$date,$type,${t.category},${t.amount},$note');
    }

    return buffer.toString();
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete ALL transactions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              MockData.transactions.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}
