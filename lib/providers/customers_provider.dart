import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../features/auth/domain/auth_state.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

// Manual providers — avoids riverpod_generator's Drift type serialization issue.

final customersStreamProvider = StreamProvider.autoDispose<List<Customer>>(
    (ref) => ref.watch(customersDaoProvider).watchAll());

final debtorsFutureProvider = FutureProvider.autoDispose<List<Customer>>(
    (ref) => ref.watch(customersDaoProvider).getDebtors());

final customerPaymentHistoryProvider =
    FutureProvider.autoDispose.family<List<CustomerPayment>, String>(
        (ref, customerId) =>
            ref.watch(customersDaoProvider).getPaymentsForCustomer(customerId));

class CustomerActions {
  CustomerActions(this._ref);
  final Ref _ref;
  final _uuid = const Uuid();

  String get _userId {
    final s = _ref.read(currentAuthStateProvider);
    return s is Authenticated ? s.user.id : 'system';
  }

  Future<String> addCustomer({
    required String name,
    String? phone,
    String? address,
  }) {
    return _ref.read(customersDaoProvider).insert(CustomersCompanion.insert(
          id: _uuid.v7(),
          name: name,
          phone: Value(phone),
          address: Value(address),
        ));
  }

  Future<void> recordPayment({
    required String customerId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    final dao = _ref.read(customersDaoProvider);
    await dao.recordPayment(CustomerPaymentsCompanion.insert(
      id: _uuid.v7(),
      customerId: customerId,
      amount: amount,
      method: Value(method),
      notes: Value(notes),
      userId: _userId,
    ));
    await dao.updateBalance(customerId, -amount);
  }
}

final customerActionsProvider =
    Provider<CustomerActions>((ref) => CustomerActions(ref));
