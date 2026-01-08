import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

import '../../src/database/daos/todo_dao.dart';
import '../../src/database/daos/user_dao.dart';
import '../../src/database/tables/todos_table.dart';
import '../../src/database/tables/users_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [UsersTable, TodosTable], daos: [UserDao, TodoDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Handle migrations if needed
    },
  );
}
