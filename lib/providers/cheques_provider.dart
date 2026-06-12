import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/database/app_database.dart';
import '../features/auth/domain/auth_state.dart';
import 'auth_provider.dart';
import 'database_provider.dart';

// Manual providers — riverpod_generator cannot serialize Drift-generated types
// in function signatures during the build phase, so we use the manual API.

final chequesMonthStreamProvider =
    StreamProvider.autoDispose.family<List<Cheque>, (int, int)>((ref, args) {
  final (year, month) = args;
  return ref.watch(chequesDaoProvider).watchByMonth(year, month);
});

final chequesUpcomingProvider = FutureProvider.autoDispose<List<Cheque>>(
    (ref) => ref.watch(chequesDaoProvider).getDueWithinDays(7));

class ChequeActions {
  ChequeActions(this._ref);
  final Ref _ref;
  final _uuid = const Uuid();

  String get _userId {
    final s = _ref.read(currentAuthStateProvider);
    return s is Authenticated ? s.user.id : 'system';
  }

  Future<void> addCheque({
    required String type,
    required String partyId,
    required String partyType,
    required String partyName,
    required double amount,
    required DateTime dueDate,
    String? chequeNo,
    String? bank,
    String? notes,
  }) {
    return _ref.read(chequesDaoProvider).insert(ChequesCompanion.insert(
          id: _uuid.v7(),
          type: type,
          partyId: partyId,
          partyType: partyType,
          partyName: partyName,
          amount: amount,
          dueDate: dueDate,
          chequeNo: Value(chequeNo),
          bank: Value(bank),
          notes: Value(notes),
          createdBy: _userId,
        ));
  }

  Future<void> updateStatus(String id, String status) =>
      _ref.read(chequesDaoProvider).updateStatus(id, status);
}

final chequeActionsProvider =
    Provider<ChequeActions>((ref) => ChequeActions(ref));
