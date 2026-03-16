// database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:todo_flutter/src/modules/auth/models/auth_model.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/shared/database/tables/auth_table.dart';
import 'package:todo_flutter/src/shared/database/tables/todos_table.dart';

part 'app_database.g.dart'; // gerado pelo build_runner

@DriftDatabase(tables: [Todos, Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        // SQLite does not support `ADD COLUMN ... UNIQUE`.
        // For upgraded databases, add the column first and enforce uniqueness with an index.
        final columns = await customSelect('PRAGMA table_info(todos)').get();
        final existingColumns = columns.map((row) => row.data['name'] as String?).whereType<String>().toSet();

        if (!existingColumns.contains('remote_id')) {
          await customStatement('ALTER TABLE todos ADD COLUMN remote_id TEXT NULL;');
        }
        if (!existingColumns.contains('user_id')) {
          await customStatement('ALTER TABLE todos ADD COLUMN user_id TEXT NULL;');
        }
        if (!existingColumns.contains('description')) {
          await customStatement('ALTER TABLE todos ADD COLUMN description TEXT NULL;');
        }
        if (!existingColumns.contains('updated_at')) {
          await customStatement('ALTER TABLE todos ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0;');
          await customStatement('UPDATE todos SET updated_at = created_at WHERE updated_at = 0;');
        }
        if (!existingColumns.contains('sync_status')) {
          await customStatement("ALTER TABLE todos ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'pending_create';");
        }
        if (!existingColumns.contains('last_synced_at')) {
          await customStatement('ALTER TABLE todos ADD COLUMN last_synced_at INTEGER NULL;');
        }
        if (!existingColumns.contains('deleted_at')) {
          await customStatement('ALTER TABLE todos ADD COLUMN deleted_at INTEGER NULL;');
        }

        await customStatement('CREATE UNIQUE INDEX IF NOT EXISTS todos_remote_id_unique_idx ON todos(remote_id);');
      }
    },
  );

  // Todos
  Stream<List<Todo>> watchAllTodos() =>
      (select(todos)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
  Stream<List<Todo>> watchPendingTodos() =>
      (select(todos)
            ..where((t) => t.done.equals(false) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();
  Stream<List<Todo>> watchUnsyncedTodos() =>
      (select(todos)
            ..where(
              (t) =>
                  t.syncStatus.equals(TodoSyncStatus.pendingCreate) |
                  t.syncStatus.equals(TodoSyncStatus.pendingUpdate) |
                  t.syncStatus.equals(TodoSyncStatus.pendingDelete) |
                  t.syncStatus.equals(TodoSyncStatus.syncError),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<int> insertTodo(TodoModel entry) {
    return into(todos).insert(
      TodosCompanion.insert(
        remoteId: Value(entry.remoteId),
        userId: Value(entry.userId),
        title: entry.title,
        description: Value(entry.description),
        done: Value(entry.completed),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
        syncStatus: Value(entry.syncState.toStorage()),
      ),
    );
  }

  Future<int> updateTodo(int id, TodoModel entry) {
    return (update(todos)..where((t) => t.id.equals(id))).write(
      TodosCompanion(
        remoteId: Value(entry.remoteId),
        userId: Value(entry.userId),
        title: Value(entry.title),
        description: Value(entry.description),
        done: Value(entry.completed),
        createdAt: Value(entry.createdAt),
        updatedAt: Value(entry.updatedAt),
        syncStatus: Value(entry.syncState.toStorage()),
      ),
    );
  }

  Future<int> deleteTodo(int id) {
    return (delete(todos)..where((t) => t.id.equals(id))).go();
  }

  Future<Todo?> getTodoById(int id) {
    return (select(todos)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Todo?> getTodoByRemoteId(String remoteId) {
    return (select(todos)..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();
  }

  Future<List<Todo>> getUnsyncedTodos() {
    return (select(todos)
          ..where(
            (t) =>
                t.syncStatus.equals(TodoSyncStatus.pendingCreate) |
                t.syncStatus.equals(TodoSyncStatus.pendingUpdate) |
                t.syncStatus.equals(TodoSyncStatus.pendingDelete) |
                t.syncStatus.equals(TodoSyncStatus.syncError),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<void> markPendingCreate(int localId) async {
    await (update(todos)..where((t) => t.id.equals(localId))).write(
      TodosCompanion(syncStatus: const Value(TodoSyncStatus.pendingCreate), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> markPendingUpdate(int localId) async {
    await (update(todos)..where((t) => t.id.equals(localId))).write(
      TodosCompanion(syncStatus: const Value(TodoSyncStatus.pendingUpdate), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> markPendingDelete(int localId) async {
    await (update(todos)..where((t) => t.id.equals(localId))).write(
      TodosCompanion(
        syncStatus: const Value(TodoSyncStatus.pendingDelete),
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markSyncError(int localId) async {
    await (update(
      todos,
    )..where((t) => t.id.equals(localId))).write(const TodosCompanion(syncStatus: Value(TodoSyncStatus.syncError)));
  }

  Future<void> markSynced({required int localId, String? remoteId}) async {
    await (update(todos)..where((t) => t.id.equals(localId))).write(
      TodosCompanion(
        remoteId: remoteId == null ? const Value.absent() : Value(remoteId),
        syncStatus: const Value(TodoSyncStatus.synced),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> upsertRemoteTodo(TodoModel model) async {
    final existing = model.remoteId == null ? null : await getTodoByRemoteId(model.remoteId!);

    if (existing != null) {
      await (update(todos)..where((t) => t.id.equals(existing.id))).write(
        TodosCompanion(
          remoteId: Value(model.remoteId),
          userId: Value(model.userId),
          title: Value(model.title),
          description: Value(model.description),
          done: Value(model.completed),
          createdAt: Value(model.createdAt),
          updatedAt: Value(model.updatedAt),
          syncStatus: const Value(TodoSyncStatus.synced),
          lastSyncedAt: Value(DateTime.now()),
          deletedAt: const Value(null),
        ),
      );
      return;
    }

    // Legacy recovery: map remote entries to local rows that were marked as
    // synced without a remoteId.
    final missingRemote =
        await (select(todos)
              ..where(
                (t) =>
                    t.remoteId.isNull() &
                    t.syncStatus.equals(TodoSyncStatus.synced) &
                    t.title.equals(model.title) &
                    t.userId.equals(model.userId) &
                    t.deletedAt.isNull(),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
              ..limit(1))
            .getSingleOrNull();

    if (missingRemote != null) {
      await (update(todos)..where((t) => t.id.equals(missingRemote.id))).write(
        TodosCompanion(
          remoteId: Value(model.remoteId),
          userId: Value(model.userId),
          title: Value(model.title),
          description: Value(model.description),
          done: Value(model.completed),
          createdAt: Value(model.createdAt),
          updatedAt: Value(model.updatedAt),
          syncStatus: const Value(TodoSyncStatus.synced),
          lastSyncedAt: Value(DateTime.now()),
          deletedAt: const Value(null),
        ),
      );
      return;
    }

    await into(todos).insert(
      TodosCompanion.insert(
        remoteId: Value(model.remoteId),
        userId: Value(model.userId),
        title: model.title,
        description: Value(model.description),
        done: Value(model.completed),
        createdAt: Value(model.createdAt),
        updatedAt: Value(model.updatedAt),
        syncStatus: const Value(TodoSyncStatus.synced),
        lastSyncedAt: Value(DateTime.now()),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> clearAllTodos() async {
    await delete(todos).go();
  }

  Future<void> clearCompletedTodos() async {
    await (delete(todos)..where((t) => t.done.equals(true) & t.deletedAt.isNull())).go();
  }

  Future<void> clearSyncedTodos() async {
    await (delete(todos)..where(
          (t) =>
              t.syncStatus.equals(TodoSyncStatus.synced) |
              (t.syncStatus.equals(TodoSyncStatus.pendingDelete) & t.remoteId.isNull()),
        ))
        .go();
  }

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
