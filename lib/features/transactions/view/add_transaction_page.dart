import 'package:flutter/material.dart';
import '../../../core/database/transaction_database.dart';
import '../../../core/database/settings_database.dart';
import '../../../core/database/models/transaction_model.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/transaction_type_toggle.dart';
import '../widgets/category_selector.dart';
import '../widgets/date_picker_button.dart';

/// Add Transaction Page
/// Fast, friction-free form for adding income/expense transactions
class AddTransactionPage extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isIncome = false; // Default to expense
  String _selectedCategory = TransactionDatabase.expenseCategories.first;
  DateTime _selectedDate = DateTime.now();
  bool _showNoteField = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note ?? '';
      _isIncome = t.isIncome;
      _selectedCategory = t.category;
      _selectedDate = t.date;
      _showNoteField = t.note != null && t.note!.isNotEmpty;
    } else {
      _selectedCategory = TransactionDatabase.expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return amount > 0;
  }

  void _saveTransaction() async {
    if (!_isFormValid) return;

    final amount = double.parse(_amountController.text);
    final transaction = TransactionModel(
      id: _isEditing
          ? widget.transaction!.id
          : TransactionDatabase.generateId(),
      amount: amount,
      category: _selectedCategory,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      date: _selectedDate,
      isIncome: _isIncome,
    );

    if (_isEditing) {
      await TransactionDatabase.updateTransaction(transaction);
    } else {
      await TransactionDatabase.addTransaction(transaction);
    }

    // Show success feedback
    if (mounted) {
      final currencySymbol = SettingsDatabase.getCurrencySymbol();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Transaction updated'
                : (_isIncome
                      ? 'Income added: $currencySymbol ${amount.toStringAsFixed(2)}'
                      : 'Expense added: $currencySymbol ${amount.toStringAsFixed(2)}'),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Close the screen
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  void _toggleType(bool isIncome) {
    setState(() {
      _isIncome = isIncome;
      // Update default category when type changes
      _selectedCategory = isIncome
          ? TransactionDatabase.incomeCategories.first
          : TransactionDatabase.expenseCategories.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancel',
        ),
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Input (Hero Element)
              AmountInputField(
                controller: _amountController,
                isIncome: _isIncome,
              ),
              const SizedBox(height: 32),

              // Type Toggle
              TransactionTypeToggle(
                isIncome: _isIncome,
                onChanged: _toggleType,
              ),
              const SizedBox(height: 24),

              // Category Selector
              CategorySelector(
                selectedCategory: _selectedCategory,
                isIncome: _isIncome,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Date Picker (subtle)
              Row(
                children: [
                  Text(
                    'Date',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DatePickerButton(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Optional Note Field
              if (!_showNoteField)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showNoteField = true;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add note (optional)'),
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft),
                )
              else
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    hintText: 'e.g., Lunch with team',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showNoteField = false;
                          _noteController.clear();
                        });
                      },
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                ),
              const SizedBox(height: 40),

              // Save Button
              FilledButton(
                onPressed: _isFormValid ? _saveTransaction : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  _isEditing ? 'Update Transaction' : 'Save Transaction',
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
