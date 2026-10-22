# Pocket Spend — Project Documentation (AI Context)

> This document describes the Pocket Spend codebase so an AI assistant can understand, modify, and extend it correctly. It reflects the actual code as of 2026-10-22.
> Note: `pocket_spend_app_documentation.md` in the repo root is an older planning doc and is **outdated** (it mentions Riverpod, fl_chart, a Category model, and repository/viewmodel layers — none of which exist). Trust this file instead.

---

## 1. What the app is

**Pocket Spend** is an **offline-first personal expense tracker** built with **Flutter**. Users record income and expense transactions, view balances and category breakdowns for today / this week / this month, browse and filter their full history, and export everything as CSV.

Product principles (stated in the app's About/Privacy screens — keep them intact when making changes):

- **No login, no accounts, no cloud, no analytics/tracking.** All data stays on the device.
- **Friction-free entry**: adding a transaction should take seconds.
- **User owns their data**: CSV export via the OS share sheet.

Default currency is **GHS (Ghanaian Cedi)**; the target audience is primarily Ghana-based users (note the "Data" expense category for mobile data bundles).

---

## 2. Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Material 3, `useMaterial3: true`) |
| Dart SDK | `^3.10.7` |
| Local storage | `hive` ^2.2.3 + `hive_flutter` ^1.1.0 (no code generation — adapter is hand-written) |
| State management | **None (no Provider/Riverpod/Bloc)**. Uses `StatefulWidget` + `setState`, Hive's `box.listenable()` with `ValueListenableBuilder`, and one global `ValueNotifier<ThemeMode>` |
| File export | `path_provider` ^2.1.5 (temp dir) + `share_plus` ^10.1.4 (`Share.shareXFiles`) |
| Formatting | `intl` ^0.20.2 is a dependency but currently **unused**; formatting is manual (`toStringAsFixed(2)`, hand-built month names) |
| Charts | No chart library — bars are built with `Container` + `FractionallySizedBox` |
| Icons | `flutter_launcher_icons` (source: `assets/logo.png`), Material icons, emoji for categories |
| Lints | `flutter_lints` ^6.0.0; `deprecated_member_use` is ignored in `analysis_options.yaml` (code uses `Color.withOpacity`) |
| Platforms | Android (min SDK 21) and iOS |

App version: `1.0.0+1` (pubspec). The Settings screen hardcodes "Version 1.0.0" and "Build: 102".

---

## 3. Directory structure

```
lib/
├── main.dart                         # Entry point: inits Hive, builds MaterialApp
├── file.dart                         # One-off scaffolding script (creates empty folders/files). NOT part of the app.
├── core/
│   ├── database/
│   │   ├── transaction_database.dart # ★ All transaction CRUD + queries + aggregations (static class)
│   │   ├── settings_database.dart    # ★ Theme + currency settings (static class)
│   │   ├── models/
│   │   │   └── transaction_model.dart# ★ TransactionModel + manual Hive TypeAdapter (typeId 0)
│   │   ├── boxes.dart                # EMPTY placeholder
│   │   └── hive_service.dart         # EMPTY placeholder
│   ├── models/                       # EMPTY placeholders (category_model.dart, transaction_model.dart)
│   ├── utils/                        # EMPTY placeholders (currency_formatter.dart, date_utils.dart)
│   ├── navigation/
│   │   ├── app_routes.dart           # Route name constants, push helpers, onGenerateRoute
│   │   ├── bottom_nav_scaffold.dart  # 4-tab NavigationBar + IndexedStack (the real home)
│   │   ├── route_transitions.dart    # Factory: slideRight, slideBottom, fade, scale, none, custom
│   │   └── custom_page_route.dart    # PageRoute implementation + TransitionType enum
│   └── theme/
│       ├── app_colors.dart           # Color constants (light/dark) + helpers like getIncomeColor(context)
│       ├── app_theme.dart            # AppTheme.lightTheme / AppTheme.darkTheme (ThemeData)
│       └── text_styles.dart          # Typography (Roboto)
└── features/
    ├── home/
    │   ├── view/home_page.dart       # Dashboard
    │   └── widgets/
    │       ├── balance_summary_card.dart
    │       ├── period_toggle.dart    # Defines `enum Period { today, thisWeek, thisMonth }`
    │       ├── expense_breakdown_chart.dart
    │       ├── recent_transactions_list.dart
    │       └── transaction_list_item.dart   # Shared row widget (also used by transactions feature)
    ├── transactions/
    │   ├── view/
    │   │   ├── add_transaction_page.dart     # Add AND edit form
    │   │   ├── transactions_page.dart        # Full history, grouped by date, filters, swipe-delete
    │   │   └── transaction_details_page.dart # Single transaction view, edit/delete
    │   ├── widgets/
    │   │   ├── amount_input_field.dart
    │   │   ├── transaction_type_toggle.dart  # Expense / Income switch
    │   │   ├── category_selector.dart        # Opens a picker of categories
    │   │   ├── date_picker_button.dart
    │   │   ├── dismissible_transaction_item.dart # Swipe-to-delete wrapper with confirm dialog
    │   │   └── transaction_date_section.dart # Date group header with group total
    │   ├── data/transaction_repository.dart  # EMPTY placeholder
    │   └── viewmodel/transaction_vm.dart     # EMPTY placeholder
    ├── summary/
    │   ├── view/summary_page.dart    # Net balance + top-5 expense category bars
    │   └── viewmodel/summary_vm.dart # EMPTY placeholder
    └── settings/
        └── view/settings_page.dart   # Theme, currency, export CSV, clear data, about/privacy
test/
└── widget_test.dart                  # Default test — currently BROKEN (see §10)
assets/
└── logo.png
```

**Important:** Several files contain only a single comment line (e.g. `// boxes.dart`). They were generated by `lib/file.dart` for an intended MVVM/repository structure that was never filled in. The real logic lives in `core/database/*` and is called directly from the views. Don't assume repository/viewmodel layers exist.

---

## 4. Startup flow

`lib/main.dart`:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await TransactionDatabase.init()` → `Hive.initFlutter()`, registers `TransactionModelAdapter`, opens box `transactions`
3. `await SettingsDatabase.init()` → opens box `settings`, loads theme into `themeNotifier`
4. `runApp(PocketSpendApp())`

`PocketSpendApp` wraps `MaterialApp` in a `ValueListenableBuilder<ThemeMode>` on `SettingsDatabase.themeNotifier`, so changing the theme rebuilds the whole app instantly. `home:` is `BottomNavScaffold`; named routes go through `AppRoutes.onGenerateRoute`.

> Order matters: `TransactionDatabase.init()` must run first because it calls `Hive.initFlutter()`.

---

## 5. Data layer

### 5.1 `TransactionModel` (`lib/core/database/models/transaction_model.dart`)

Extends `HiveObject`. Fields:

| Hive field | Name | Type | Notes |
|---|---|---|---|
| 0 | `id` | `String` | Millisecond timestamp string from `TransactionDatabase.generateId()`. Also used as the Hive box **key**. |
| 1 | `amount` | `double` | Always **positive**. Sign is determined by `isIncome`. |
| 2 | `category` | `String` | One of the predefined category names (plain string, not an enum). |
| 3 | `isIncome` | `bool` | `true` = income, `false` = expense. |
| 4 | `date` | `DateTime` | Date chosen by the user. |
| 5 | `note` | `String?` | Optional; stored as `null` when empty. |

Also has `fromMap` / `toMap` helpers.

**The `TransactionModelAdapter` is hand-written (no `build_runner`).** To add a field:
1. Give it the next index (`@HiveField(6)`).
2. Update `read()` — handle a missing key for old records (e.g. `fields[6] as String? ?? defaultValue`).
3. Update `write()` — bump `writeByte(6)` to the new field count and write the new field.
4. Never reuse or renumber existing indices; never change `typeId = 0`.

### 5.2 `TransactionDatabase` (`lib/core/database/transaction_database.dart`)

Static-only service over `Box<TransactionModel>` named `transactions`. Accessing `TransactionDatabase.box` before `init()` throws.

**Categories (hardcoded constants):**
- `expenseCategories`: Food, Transport, Shopping, Entertainment, Utilities, Data, Health, Other
- `incomeCategories`: Salary, Freelance, Investment, Gift, Other
- `getCategoryIcon(category)` → emoji (🍔 🚗 🛍️ 🎬 💡 📱 💊 💰 💼 📈 🎁 📝), defaults to 📝.
- "Other" exists in both lists, so a category string alone doesn't tell you the type — always use `isIncome`.

**CRUD:**
- `addTransaction(t)` / `updateTransaction(t)` — both `box.put(t.id, t)` (upsert).
- `getTransaction(id)`, `getAllTransactions()` (unsorted), `deleteTransaction(id)` → `bool`, `clearAll()`.
- `generateId()` → `DateTime.now().millisecondsSinceEpoch.toString()`.

**Queries / aggregations** (pure functions over a list):
- `filterTransactions({source, category, dateFrom, dateTo, isIncome})` — date bounds are inclusive via ±1 day padding.
- `groupTransactionsByDate(list)` → ordered `Map<String, List>`, newest first. Keys: `Today`, `Yesterday`, weekday name (within the last 7 days), `Mon D` (this year), `Mon D, YYYY` (older).
- `getBalance`, `getGroupTotal` (identical: income − expenses), `getTotalIncome`, `getTotalExpenses`.
- `getExpensesByCategory(list)` → `Map<String, double>` sorted by amount descending (expenses only).
- `getRecentTransactions({limit = 8})` — all time, newest first.
- Period helpers: `getToday()`, `getThisWeek()` (week starts **Monday**), `getThisMonth()`. Week/month only apply a start bound, so future-dated transactions are included.

### 5.3 `SettingsDatabase` (`lib/core/database/settings_database.dart`)

Static service over the untyped box `settings`.

| Key | Values | Default |
|---|---|---|
| `themeMode` | `'light'`, `'dark'`, `'system'` | `'system'` |
| `currency` | `'GHS'`, `'USD'`, `'EUR'`, `'GBP'` | `'GHS'` |

- `themeNotifier` (`ValueNotifier<ThemeMode>`) — global; `setThemeMode()` persists and updates it.
- `getCurrency()`, `setCurrency(code)`, `getCurrencySymbol()` (GHS→`GHS`, USD→`$`, EUR→`€`, GBP→`£`), `getCurrencyName()`.
- Currency is **display-only**: changing it doesn't convert stored amounts.
- `extension ThemeModeExtension on ThemeMode { String get name }` returns "Light"/"Dark"/"System".

To add a currency, update `getCurrencySymbol`, `getCurrencyName`, and the `_currencyOption` list in `settings_page.dart`.

---

## 6. Reactivity model

- Screens that show transactions wrap their body in `ValueListenableBuilder` on `TransactionDatabase.box.listenable()`, so any add/update/delete rebuilds them automatically. `TransactionDetailsPage` listens only to its own key.
- Theme: the global `themeNotifier`.
- Local UI state (selected period, filters, form fields) lives in each page's `State` and changes via `setState`.
- The currency symbol is read with `SettingsDatabase.getCurrencySymbol()` at build time. There's **no** currency notifier, so other tabs only show a currency change on their next rebuild.

---

## 7. Navigation

**Main shell:** `BottomNavScaffold` — Material 3 `NavigationBar` with an `IndexedStack` (tabs keep their state):

| Index | Tab | Page |
|---|---|---|
| 0 | Home | `HomePage` |
| 1 | Transactions | `TransactionsPage` |
| 2 | Summary | `SummaryPage` |
| 3 | Settings | `SettingsPage` |

**Named routes** (`AppRoutes`, used via `AppRoutes.push(context, AppRoutes.x, arguments: ...)`):

| Constant | Path | Page | Arguments | Transition |
|---|---|---|---|---|
| `home` | `/` | `BottomNavScaffold` | — | none |
| `addTransaction` | `/add-transaction` | `AddTransactionPage` | `TransactionModel?` (non-null = edit mode) | slide from bottom |
| `transactions` | `/transactions` | `TransactionsPage` | — | slide right |
| `summary` | `/summary` | `SummaryPage` | — | slide right |
| `transactionDetails` | `/transaction-details` | `TransactionDetailsPage` | `TransactionModel` (required) | slide right |
| `settings` | `/settings` | `SettingsPage` | — | slide right |
| `categories` | `/categories` | `Placeholder()` | — | not implemented |

Unknown routes show a "Page Not Found" scaffold (`onUnknownRoute`). `AppRoutes` also provides `pushWidget`, `pushModal`, `pushFade`, `pushReplacement*`, `pushAndRemoveUntil`, `pop`, `popUntil`, `popToHome`, `canPop`.

To add a screen: add a constant to `AppRoutes`, add a `case` in `onGenerateRoute` that uses a `RouteTransitions.*` factory, and navigate with `AppRoutes.push`.

---

## 8. Screens & behavior

### Home (`features/home/view/home_page.dart`)
- AppBar: title "Pocket Spend", a notifications button (shows a "coming soon" snackbar), and a light ↔ dark theme toggle.
- `BalanceSummaryCard` — balance, income, and expenses for the selected period.
- `PeriodToggle` — Today / This Week / This Month (default **This Month**).
- `ExpenseBreakdownChart` — category bars for the period's expenses.
- `RecentTransactionsList` — the 8 most recent transactions (all time). Tap → details; "See all" → `/transactions`.
- Extended FAB "Add Transaction" → `/add-transaction`. Pull-to-refresh calls `setState`.

### Add / Edit Transaction (`add_transaction_page.dart`)
- Edit mode when a `TransactionModel` is passed in (fields are prefilled and the same `id` is kept).
- Fields: amount (hero input), Expense/Income toggle (default **Expense**; switching resets the category to that list's first item), category picker, date picker (default today), optional note (revealed via "Add note").
- Save is enabled only when `amount > 0`. Saving adds or updates, shows a snackbar, and pops with `true`.

### Transactions (`transactions_page.dart`)
- Full history grouped by date. Each group has a `TransactionDateSection` header with the group's net total.
- Filter bottom sheet: Type (All/Income/Expense) and a Category dropdown. A badge on the filter icon shows the active filter count, and active filters appear as removable chips.
- Swipe either direction to delete (confirm dialog), then a snackbar with **Undo** that re-adds the same object.
- Tap → details. Separate empty states for "no transactions" and "no matches".

### Transaction Details (`transaction_details_page.dart`)
- Shows the amount (colored by type), category, date, and note.
- Edit → `/add-transaction` with the transaction. Delete → confirm dialog → deletes, then closes the dialog and the page.

### Summary (`features/summary/view/summary_page.dart`)
- Same `PeriodToggle`. A net balance card (income color if ≥ 0, otherwise expense color) with income/expense totals.
- "Expense Breakdown": top 5 categories with percentage, amount, and a horizontal bar sized relative to the largest category.
- When the period has no transactions it shows "Not enough data yet". This also hides the period toggle.

### Settings (`features/settings/view/settings_page.dart`)
- **General**: Theme picker (System/Light/Dark) and Currency picker (GHS/USD/EUR/GBP).
- **Data**: Export CSV writes `pocket_spend_transactions.csv` to the temp dir, shows a preview dialog, then shares it via `Share.shareXFiles`. Clear All Data asks for confirmation, then calls `TransactionDatabase.clearAll()`.
- **About**: version, about, and privacy dialogs.
- CSV format: header `Date,Type,Category,Amount,Note`; date as `YYYY-MM-DD`; type `Income`/`Expense`; commas in notes are replaced with `;` (no quoting).

---

## 9. Theming & UI conventions

- Colors live in `AppColors` as `...Light` / `...Dark` pairs. Primary is teal (`#00796B` light / `#4DB6AC` dark); secondary is orange.
- **Income = green, Expense = deep orange.** Always get them through `AppColors.getIncomeColor(context)` / `AppColors.getExpenseColor(context)` so dark mode works.
- The full `ThemeData` for both modes is in `AppTheme`; typography is in `text_styles.dart` (Roboto).
- In widgets, prefer `Theme.of(context).colorScheme` / `textTheme` over raw colors.
- Amounts are displayed as `'$currencySymbol ${amount.toStringAsFixed(2)}'`; signed values get a leading `+`.
- User feedback uses `SnackBar` (often `SnackBarBehavior.floating`). Destructive actions always get a confirmation `AlertDialog`.
- After an `await`, the code checks `mounted` / `context.mounted` before using `context`. Keep doing this.

---

## 10. Known issues & gaps

1. **Broken test**: `test/widget_test.dart` pumps `PocketSpendApp` without initializing Hive (it throws on `TransactionDatabase.box`) and expects the text "Welcome to Pocket Spend", which doesn't exist.
2. **Hardcoded currency**: the swipe-delete confirm dialog in `dismissible_transaction_item.dart` says `GHS` instead of using `SettingsDatabase.getCurrencySymbol()`.
3. **No UI for the date-range filter**: `TransactionsPage` keeps `_dateFrom`/`_dateTo` state and counts it as a filter, but the filter sheet has no date pickers, so these are never set.
4. **Currency changes don't update open tabs** (there's no notifier; see §6).
5. **Period queries include future-dated transactions** (only a lower bound is applied).
6. **Empty placeholder files** in `core/models`, `core/utils`, `core/database/boxes.dart`, `hive_service.dart`, `transaction_repository.dart`, and `*_vm.dart`. `lib/file.dart` is a scaffolding script that sits in `lib/` but isn't imported anywhere.
7. **Duplicated logic**: date-group formatting repeats the month arrays; `_CategoryBar` exists separately in Home and Summary; `getGroupTotal` is identical to `getBalance`. `intl` is installed but unused.
8. **The categories route** is a `Placeholder`, and categories can't be edited by the user. The notifications button is a stub.
9. **CSV export** doesn't escape quotes or newlines in notes, and rows aren't sorted by date.
10. **Version strings** in Settings are hardcoded and don't match pubspec (`Build: 102` vs `+1`).
11. **No backup or import**: data lives only in the Hive boxes on the device, so uninstalling the app loses it unless it was exported.

---

## 11. Commands

```bash
flutter pub get                          # install dependencies
flutter run                              # run on a connected device/emulator
flutter analyze                          # lint
flutter test                             # tests (currently fails, see §10.1)
flutter build apk --release              # Android release build
dart run flutter_launcher_icons          # regenerate launcher icons from assets/logo.png
```

---

## 12. Guidelines for making changes

- Put data access in `TransactionDatabase` / `SettingsDatabase` as static methods, not in widgets.
- New screens go in `lib/features/<feature>/view/`, their widgets go in `lib/features/<feature>/widgets/`, and each screen is registered in `AppRoutes`.
- For screens that display transactions, use `ValueListenableBuilder` on `TransactionDatabase.box.listenable()` so they stay in sync.
- Keep the app fully offline. Don't add network calls, analytics, or accounts unless someone explicitly decides to change the product's privacy promise.
- When changing the Hive model, follow the adapter rules in §5.1 so existing user data still loads.
- Match the existing style: `const` constructors, `///` doc comments on classes, section comments like `// ========== X ==========`, and `mounted` checks after `await`.
