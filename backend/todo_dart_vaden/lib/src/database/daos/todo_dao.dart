import 'package:drift/drift.dart';
import '../../../config/database/database.dart';
import '../tables/todos_table.dart';

part 'todo_dao.g.dart';

@DriftAccessor(tables: [TodosTable])
class TodoDao extends DatabaseAccessor<AppDatabase> {
  TodoDao(AppDatabase db) : super(db);

  /// Get todos by user ID with advanced filtering
  Future<List<TodosTableData>> getByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
    String? search,
    bool? completed,
    String sortBy = 'created_at',
    String order = 'desc',
  }) {
    final offset = (page - 1) * limit;

    var query = db.select(db.todosTable)..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());

    // Add search filter
    if (search != null && search.isNotEmpty) {
      query = query..where((t) => t.title.like('%$search%'));
    }

    // Add completed filter
    if (completed != null) {
      query = query..where((t) => t.completed.equals(completed));
    }

    // Add sorting
    query = query
      ..orderBy([
        (t) => OrderingTerm(
          expression: _getSortColumn(sortBy),
          mode: order.toLowerCase() == 'asc' ? OrderingMode.asc : OrderingMode.desc,
        ),
      ])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// Get todo by ID
  Future<TodosTableData?> getById(int id) =>
      (db.select(db.todosTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  /// Create todo
  Future<int> createTodo(TodosTableCompanion todo) => db.into(db.todosTable).insert(todo);

  /// Update todo
  Future<bool> updateTodo(int id, TodosTableCompanion updates) async {
    final updated = await (db.update(db.todosTable)..where((t) => t.id.equals(id))).write(updates);
    return updated > 0;
  }

  /// Soft delete
  Future<bool> softDelete(int id) async {
    final updated = await (db.update(
      db.todosTable,
    )..where((t) => t.id.equals(id))).write(TodosTableCompanion(deletedAt: Value(DateTime.now())));
    return updated > 0;
  }

  /// Count todos for user
  Future<int> countByUserId(int userId, {String? search, bool? completed}) async {
    var query = db.select(db.todosTable)..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());

    if (search != null && search.isNotEmpty) {
      query = query..where((t) => t.title.like('%$search%'));
    }

    if (completed != null) {
      query = query..where((t) => t.completed.equals(completed));
    }

    final result = await query.get();
    return result.length;
  }

  /// Helper to get column for sorting
  Expression _getSortColumn(String sortBy) {
    switch (sortBy) {
      case 'title':
        return db.todosTable.title;
      case 'completed':
        return db.todosTable.completed;
      case 'updated_at':
        return db.todosTable.updatedAt;
      default:
        return db.todosTable.createdAt;
    }
  }
}
