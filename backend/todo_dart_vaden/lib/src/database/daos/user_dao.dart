import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import '../../../config/database/database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> {
  UserDao(AppDatabase db) : super(db);

  /// Get all active users
  Future<List<UsersTableData>> getAllActive() =>
      (db.select(db.usersTable)
            ..where((u) => u.deletedAt.isNull())
            ..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)]))
          .get();

  /// Get user by email
  Future<UsersTableData?> findByEmail(String email) =>
      (db.select(db.usersTable)..where((u) => u.email.equals(email) & u.deletedAt.isNull())).getSingleOrNull();

  /// Get user by ID
  Future<UsersTableData?> findById(String id) => (db.select(
    db.usersTable,
  )..where((u) => u.id.equals(UuidValue.fromString(id)) & u.deletedAt.isNull())).getSingleOrNull();

  /// Create user
  Future<String> createUser(UsersTableCompanion user) async {
    await db.into(db.usersTable).insert(user);
    final created = await findByEmail(user.email.value);
    return created?.id.toString() ?? '';
  }

  /// Update user
  Future<bool> updateUser(String id, UsersTableCompanion updates) async {
    final updated = await (db.update(
      db.usersTable,
    )..where((u) => u.id.equals(UuidValue.fromString(id)))).write(updates);
    return updated > 0;
  }

  /// Soft delete
  Future<bool> softDelete(String id) async {
    final updated = await (db.update(db.usersTable)..where((u) => u.id.equals(UuidValue.fromString(id)))).write(
      UsersTableCompanion(deletedAt: Value(PgDateTime(DateTime.now()))),
    );
    return updated > 0;
  }

  /// Paginated query
  Future<List<UsersTableData>> getPaginated(int page, int limit) {
    final offset = (page - 1) * limit;
    return (db.select(db.usersTable)
          ..where((u) => u.deletedAt.isNull())
          ..limit(limit, offset: offset)
          ..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Count active users
  Future<int> countActive() async {
    final query = db.select(db.usersTable)..where((u) => u.deletedAt.isNull());
    final result = await query.get();
    return result.length;
  }
}
