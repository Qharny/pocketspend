# Pocket Spend

## Overview
Pocket Spend is an **offline-first personal expense tracker** built with Flutter. The app allows users to record income and expenses without an internet connection, categorize transactions, and view daily and weekly summaries. All data is stored locally on the device, making the app fast, private, and reliable.

The app is designed to be simple, educational, and Play Store–friendly, while also demonstrating real-world Flutter architecture and data-handling practices.

---

## Key Objectives
- Provide a simple way to track personal finances offline
- Demonstrate proper Flutter app architecture
- Teach core Flutter concepts such as forms, state management, local storage, lists, and data aggregation
- Ensure user data privacy by avoiding mandatory cloud dependencies

---

## Core Features

### 1. Income & Expense Tracking
- Add income or expense transactions
- Enter amount, category, date, and optional notes
- Distinguish clearly between income and expenses

### 2. Categories
- Predefined categories (Food, Transport, Data, Utilities, etc.)
- Categories help organize transactions and summaries
- Can be extended later to support custom categories

### 3. Daily & Weekly Summaries
- View total income and expenses for a selected day
- View weekly summaries based on date ranges
- Automatically calculated from stored transaction data

### 4. Offline-First Storage
- Uses local storage only (Hive)
- No internet connection required
- Fast read/write operations

---

## Technology Stack

- **Framework:** Flutter
- **Language:** Dart
- **State Management:** Riverpod (StateNotifier)
- **Local Storage:** Hive
- **Charts (Optional):** fl_chart
- **Platform:** Android (Play Store–ready), expandable to iOS

---

## App Architecture

Pocket Spend follows a **feature-based architecture** combined with MVVM-style separation of concerns.

### Folder Structure
```
lib/
│
├── core/
│   ├── database/        # Hive setup and box management
│   ├── models/          # Data models
│   └── utils/           # Helpers (dates, formatting)
│
├── features/
│   ├── transactions/   # Add/view transactions
│   ├── summary/        # Daily & weekly summaries
│
├── main.dart
```

### Architectural Layers
- **Models:** Define the data structure (transactions, categories)
- **Repository:** Handles data access and storage logic
- **ViewModel:** Manages state and business logic
- **Views (UI):** Displays data and handles user interaction

This separation ensures maintainability, testability, and scalability.

---

## Data Models

### Transaction Model
Represents a single financial transaction.

**Fields:**
- `id` – Unique identifier
- `amount` – Transaction amount
- `category` – Category name
- `note` – Optional description
- `date` – Date of transaction
- `isIncome` – Determines income or expense

### Category Model
Represents a transaction category.

**Fields:**
- `name` – Category name
- `isIncomeCategory` – Income or expense category

---

## Data Storage

Pocket Spend uses **Hive**, a lightweight NoSQL database for Flutter.

### Storage Principles
- All data is stored locally on the device
- No account or login required
- Boxes are opened once during app initialization
- Transactions are indexed using unique IDs

### Advantages
- High performance
- No SQL queries
- Ideal for offline-first applications

---

## State Management

Riverpod is used to manage application state.

### Responsibilities
- Hold the current list of transactions
- Reactively update UI when data changes
- Expose methods for adding and deleting transactions

This ensures a unidirectional data flow and predictable behavior.

---

## Business Logic

### Adding a Transaction
1. User fills the form
2. Input is validated
3. Transaction is saved to Hive
4. State updates automatically
5. UI refreshes

### Summaries Calculation
- Transactions are filtered by date range
- Income and expenses are summed separately
- Results are displayed in text or charts

---

## User Experience Design

- Minimal and distraction-free UI
- Simple forms with validation
- Clear distinction between income and expenses
- Fast navigation and instant feedback

The design prioritizes usability over complexity.

---

## Privacy & Security

- No internet dependency
- No personal data collected
- All financial data remains on the user’s device

---

## Scalability & Future Enhancements

Planned or optional features:
- Data export (CSV / PDF)
- Cloud backup (Firebase / Supabase)
- Monthly summaries
- Budget limits and alerts
- Custom categories
- Multi-currency support

---

## Play Store Readiness

Pocket Spend is:
- Offline-capable
- Lightweight
- Privacy-friendly
- Suitable for productivity and finance categories

Example store tagline:
> "An expense tracker that works even when your data is off."

---

## Conclusion

Pocket Spend is a practical, well-structured Flutter application that demonstrates real-world mobile development fundamentals. It is intentionally simple, offline-first, and focused on long-term usefulness rather than trends.

This app serves both as a daily finance tool and a solid learning project for Flutter developers.

