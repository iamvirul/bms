import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<User?> findByUsername(String username) =>
      (select(users)..where((u) => u.username.equals(username))).getSingleOrNull();

  Future<User?> findById(String id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<List<User>> findAll({bool activeOnly = true}) =>
      (select(users)..where((u) => activeOnly ? u.isActive.equals(true) : const Constant(true)))
          .get();

  Future<String> insert(UsersCompanion entry) =>
      into(users).insertReturning(entry).then((u) => u.id);

  Future<bool> update(UsersCompanion entry) =>
      (update(users)..where((u) => u.id.equals(entry.id.value))).write(entry).then((n) => n > 0);

  Future<void> incrementFailedAttempts(String id) async {
    await (update(users)..where((u) => u.id.equals(id))).write(
      UsersCompanion(
        failedAttempts: Value(
          (await findById(id))!.failedAttempts + 1,
        ),
      ),
    );
  }

  Future<void> resetFailedAttempts(String id) =>
      (update(users)..where((u) => u.id.equals(id)))
          .write(const UsersCompanion(failedAttempts: Value(0)));

  Future<void> lockAccount(String id, DateTime until) =>
      (update(users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(lockedUntil: Value(until)));
}
