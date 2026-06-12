# BMS — Business Management System

A local-first business management system for retail and wholesale operations, built with Flutter. All data is stored on-device using SQLite — no cloud backend, no sync.

## Features

- **POS / Invoicing** — create sales invoices and no-invoice cash sales
- **Inventory** — products, categories, units, stock tracking with low-stock alerts
- **Customers & Debtors** — credit sales, outstanding balances, payment history
- **Suppliers & Purchases** — purchase orders, supplier payments
- **Cheque Management** — track post-dated cheques with due-date reminders
- **Petty Cash** — daily petty cash ledger
- **Reports & Dashboard** — sales summary, stock valuation, debtor ageing
- **Role-based access** — developer / admin / cashier with route guards
- **Audit log** — immutable, insert-only financial audit trail

## Tech Stack

| Layer | Package |
|---|---|
| UI | Flutter 3.44 + Material 3 |
| State | Riverpod 3.x (`riverpod_annotation`) |
| Navigation | go_router 14.x |
| Database | Drift 2.34 on SQLite (WAL mode, FK enforced) |
| Models | Freezed 3.x |
| Auth | bcrypt (logRounds 12), flutter_secure_storage |
| Primary keys | UUID v7 (time-ordered, sync-safe) |

## Project Structure

```
lib/
  core/           # Theme, router, constants, error types, utilities
  data/
    database/     # Drift tables, DAOs, AppDatabase
    models/       # Freezed value objects (UserModel, etc.)
    repositories/ # Business logic + data access
  features/       # Feature-first screens (auth, dashboard, inventory, ...)
  providers/      # Riverpod providers (auth, database)
  shared/         # Reusable widgets
```

## Getting Started

### Prerequisites

- Flutter 3.24+
- Dart 3.8+

### Run

```bash
flutter pub get
flutter pub run build_runner build
flutter run
```

Primary target is **Windows desktop**. For development on macOS, use Chrome:

```bash
flutter run -d chrome --web-port 9090 --no-wasm
```

### Default credentials

| Field | Value |
|---|---|
| Username | `dev` |
| Password | `changeme` |

> Change the password immediately after first login.

### Web: clear database on schema change

The web build uses IndexedDB. After a schema change, clear the old database:
Chrome DevTools -> Application -> IndexedDB -> delete `bms_local` -> refresh.

## Development

### Code generation

```bash
flutter pub run build_runner build
# or watch mode
flutter pub run build_runner watch
```

### Migrations

Bump `schemaVersion` in `AppDatabase` and add a migration step in `onUpgrade`. Never alter the schema manually.

### Adding a new role restriction

Edit `RouteGuard._adminOnlyRoutes` in `lib/core/router/route_guard.dart`.
