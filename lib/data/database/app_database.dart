import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/audit_log_dao.dart';
import 'daos/cheques_dao.dart';
import 'daos/customers_dao.dart';
import 'daos/inventory_dao.dart';
import 'daos/invoices_dao.dart';
import 'daos/petty_cash_dao.dart';
import 'daos/suppliers_dao.dart';
import 'daos/users_dao.dart';
import 'tables/audit_log_table.dart';
import 'tables/cheques_table.dart';
import 'tables/customers_table.dart';
import 'tables/invoices_table.dart';
import 'tables/payments_table.dart';
import 'tables/petty_cash_table.dart';
import 'tables/products_table.dart';
import 'tables/suppliers_table.dart';
import 'tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Categories,
    Products,
    ProductUnits,
    Stock,
    StockMovements,
    Customers,
    CustomerPayments,
    Suppliers,
    Purchases,
    PurchaseItems,
    SupplierPayments,
    Invoices,
    InvoiceItems,
    NoInvoiceSales,
    Cheques,
    PettyCash,
    AuditLog,
  ],
  daos: [
    UsersDao,
    InventoryDao,
    InvoicesDao,
    CustomersDao,
    SuppliersDao,
    ChequesDao,
    PettyCashDao,
    AuditLogDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDeveloperAccount();
        },
        onUpgrade: (m, from, to) async {
          // Migrations added here for each schema bump.
        },
        beforeOpen: (details) async {
          // Enable WAL mode -- serializes concurrent writes, safe on SQLite.
          await customStatement('PRAGMA journal_mode=WAL');
          // Enforce foreign key constraints.
          await customStatement('PRAGMA foreign_keys=ON');
        },
      );

  /// Seeds a developer account on fresh install.
  /// Credentials must be changed on first login.
  Future<void> _seedDeveloperAccount() async {
    // Password hash for 'changeme' -- MUST be rotated on first login.
    const devPasswordHash =
        r'$2b$12$placeholder.hash.must.be.replaced.on.first.login';

    await into(users).insertOnConflictUpdate(
      UsersCompanion.insert(
        id: const Value('00000000-0000-0000-0000-000000000001'),
        name: 'Developer',
        username: 'dev',
        passwordHash: devPasswordHash,
        role: const Value('developer'),
      ),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'bms_local');
}
