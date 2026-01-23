import 'package:flutter/material.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/models/transaction_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Settings Page
/// Light, simple settings - no bloat, offline-first
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _currentCurrency;
  late ThemeMode _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _currentCurrency = SettingsDatabase.getCurrency();
    _currentThemeMode = SettingsDatabase.getThemeMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // General Section
          _buildSectionHeader(context, 'General'),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: Text(_currentThemeMode.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showThemePicker(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Currency'),
            subtitle: Text(
              '$_currentCurrency - ${SettingsDatabase.getCurrencyName()}',
            ),
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
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {
              _showVersionInfo(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Pocket Spend'),
            subtitle: const Text('Offline-first expense tracker'),
            onTap: () {
              _showAboutProject(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy'),
            subtitle: const Text('No login. No cloud. No tracking.'),
            onTap: () {
              _showPrivacyPolicy(context);
            },
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

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(context, ThemeMode.system, Icons.brightness_auto),
            _themeOption(context, ThemeMode.light, Icons.light_mode_outlined),
            _themeOption(context, ThemeMode.dark, Icons.dark_mode_outlined),
          ],
        ),
      ),
    );
  }

  Widget _themeOption(BuildContext context, ThemeMode mode, IconData icon) {
    final isSelected = _currentThemeMode == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(mode.name),
      selected: isSelected,
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () async {
        final navigator = Navigator.of(context);
        await SettingsDatabase.setThemeMode(mode);
        if (!mounted) return;

        setState(() {
          _currentThemeMode = mode;
        });

        navigator.pop();
      },
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
    final isSelected = _currentCurrency == code;
    return ListTile(
      title: Text(code),
      subtitle: Text(name),
      selected: isSelected,
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () async {
        final navigator = Navigator.of(context);
        final messenger = ScaffoldMessenger.of(context);

        await SettingsDatabase.setCurrency(code);
        if (!mounted) return;

        setState(() {
          _currentCurrency = code;
        });

        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Currency changed to $code'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Version'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            Text('Build: 102'),
            SizedBox(height: 16),
            Text(
              'Pocket Spend is built with Flutter and uses Hive for high-performance local storage.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutProject(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Pocket Spend'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pocket Spend started with a simple goal: money tracking shouldn\'t be hard.',
            ),
            SizedBox(height: 12),
            Text(
              'We believe your financial data should be private, offline, and friction-free. No accounts, no subscriptions, just you and your money.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy First'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your data stays on your device.'),
            SizedBox(height: 12),
            BulletItem(text: 'No cloud sync (data never leaves your phone)'),
            BulletItem(text: 'No analytics or tracking'),
            BulletItem(text: 'No accounts or personal info requested'),
            BulletItem(
              text: 'You own your data (use Export to take it with you)',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _exportData(BuildContext context) async {
    try {
      // Get all transactions
      final transactions = TransactionDatabase.getAllTransactions();

      // Generate CSV
      final csv = _generateCSV(transactions);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/pocket_spend_transactions.csv';

      // Write CSV to file
      final file = File(filePath);
      await file.writeAsString(csv);

      // Show preview dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Export Data'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${transactions.length} transactions ready to export'),
                const SizedBox(height: 16),
                Text(
                  'CSV Preview:',
                  style: Theme.of(dialogContext).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      dialogContext,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${csv.split('\n').take(4).join('\n')}\n...',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  // Share the file
                  await Share.shareXFiles(
                    [XFile(filePath)],
                    subject: 'Pocket Spend Transactions Export',
                    text:
                        'Your transaction history (${transactions.length} transactions)',
                  );

                  // Show success message
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transactions exported successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Share CSV'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateCSV(List<TransactionModel> transactions) {
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
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              await TransactionDatabase.clearAll();

              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('All transactions deleted permanently'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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

class BulletItem extends StatelessWidget {
  final String text;
  const BulletItem({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
