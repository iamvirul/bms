import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../features/auth/domain/auth_state.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

// Manual providers — avoids riverpod_generator's Drift type serialization issue.

final suppliersStreamProvider = StreamProvider.autoDispose<List<Supplier>>(
    (ref) => ref.watch(suppliersDaoProvider).watchAll());

class SupplierActions {
  SupplierActions(this._ref);
  final Ref _ref;
  final _uuid = const Uuid();

  String get _userId {
    final s = _ref.read(currentAuthStateProvider);
    return s is Authenticated ? s.user.id : 'system';
  }

  Future<String> addSupplier({
    required String name,
    String? phone,
    String? address,
    String? paymentTerms,
  }) {
    return _ref.read(suppliersDaoProvider).insert(SuppliersCompanion.insert(
          id: _uuid.v7(),
          name: name,
          phone: Value(phone),
          address: Value(address),
          paymentTerms: Value(paymentTerms),
        ));
  }

  Future<void> recordPayment({
    required String supplierId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    final dao = _ref.read(suppliersDaoProvider);
    await dao.recordPayment(SupplierPaymentsCompanion.insert(
      id: _uuid.v7(),
      supplierId: supplierId,
      amount: amount,
      method: Value(method),
      notes: Value(notes),
      userId: _userId,
    ));
    await dao.updateBalance(supplierId, -amount);
  }
}

final supplierActionsProvider =
    Provider<SupplierActions>((ref) => SupplierActions(ref));
