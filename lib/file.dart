import 'dart:io';

void main() {
  final base = Directory('lib');

  final folders = [
    'core/database',
    'core/models',
    'core/utils',

    'features/transactions/data',
    'features/transactions/view',
    'features/transactions/viewmodel',

    'features/summary/view',
    'features/summary/viewmodel',
  ];

  final files = [
    'core/database/hive_service.dart',
    'core/database/boxes.dart',

    'core/models/transaction_model.dart',
    'core/models/category_model.dart',

    'core/utils/date_utils.dart',
    'core/utils/currency_formatter.dart',

    'features/transactions/data/transaction_repository.dart',
    'features/transactions/view/add_transaction_page.dart',
    'features/transactions/view/transactions_page.dart',
    'features/transactions/viewmodel/transaction_vm.dart',

    'features/summary/view/summary_page.dart',
    'features/summary/viewmodel/summary_vm.dart',

    'main.dart',
  ];

  for (final folder in folders) {
    final dir = Directory('${base.path}/$folder');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
      print('Created folder: ${dir.path}');
    }
  }

  for (final file in files) {
    final dartFile = File('${base.path}/$file');
    if (!dartFile.existsSync()) {
      dartFile.createSync(recursive: true);
      dartFile.writeAsStringSync('// ${file.split('/').last}\n');
      print('Created file: ${dartFile.path}');
    }
  }

  print('\n✅ Pocket Spend structure created successfully.');
}
