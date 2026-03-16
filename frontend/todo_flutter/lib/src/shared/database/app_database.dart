// database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_flutter/src/modules/auth/models/auth_model.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/shared/database/tables/auth_table.dart';
import 'package:todo_flutter/src/shared/database/tables/todos_table.dart';

part 'app_database.g.dart'; // gerado pelo build_runner

@DriftDatabase(tables: [Todos, Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Todos
  Stream<List<Todo>> watchAllTodos() => select(todos).watch();
  Stream<List<Todo>> watchPendingTodos() => (select(todos)..where((t) => t.done.equals(false))).watch();

  // Sessão — linha única com id fixo em 1
  Stream<Session?> watchSession() => (select(sessions)..where((s) => s.id.equals(1))).watchSingleOrNull();

  Future<void> saveSession(AuthResponseModel auth) {
    final user = auth.user;
    return into(sessions).insertOnConflictUpdate(
      SessionsCompanion.insert(
        id: const Value(1),
        token: auth.token,
        tokenType: Value(auth.tokenType),
        expiresIn: auth.expiresIn,
        expiresAt: DateTime.now().add(Duration(seconds: auth.expiresIn)),
        userId: Value(user is LoggedUserModel ? user.id : null),
        userEmail: Value(user is LoggedUserModel ? user.email : null),
        userName: Value(user is LoggedUserModel ? user.name : null),
      ),
    );
  }

  Future<void> clearSession() => (delete(sessions)..where((s) => s.id.equals(1))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'todos.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
