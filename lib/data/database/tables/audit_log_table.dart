import 'package:drift/drift.dart';

/// Immutable financial audit trail. No updates -- insert only.
/// Required for: void invoices, stock adjustments, petty cash approvals,
/// cheque status changes, user permission changes.
class AuditLog extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // invoice | stock | cheque | payment | user | petty_cash
  TextColumn get entityId => text()();
  TextColumn get action => text()(); // create | update | void | approve | reject | delete
  TextColumn get oldValue => text().nullable()(); // JSON snapshot
  TextColumn get newValue => text().nullable()(); // JSON snapshot
  TextColumn get userId => text()();
  TextColumn get userName => text()(); // snapshot -- user may be deleted later
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
