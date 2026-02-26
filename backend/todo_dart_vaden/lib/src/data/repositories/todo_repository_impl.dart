import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:vaden/vaden.dart';

import '../../../config/database/database.dart';
import '../../database/daos/todo_dao.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../dto/todo_dto.dart';

/// Implementation of Todo repository using Drift DAOs
@Repository()
class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this._todoDao);
  final TodoDao _todoDao;

  @override
  Future<TodoProfile?> findById(String id) async {
    try {
      final todo = await _todoDao.getById(id);
      return todo != null ? _mapToTodoProfile(todo) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TodoProfile>> findByUserId(
    String userId, {
    int page = 1,
    int limit = 10,
    String? search,
    bool? completed,
    String sortBy = 'created_at',
    String order = 'desc',
  }) async {
    try {
      final todos = await _todoDao.getByUserId(
        userId,
        page: page,
        limit: limit,
        search: search,
        completed: completed,
        sortBy: sortBy,
        order: order,
      );
      return todos.map(_mapToTodoProfile).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getTotalCountByUserId(String userId, {String? search, bool? completed}) async {
    try {
      return await _todoDao.countByUserId(userId, search: search, completed: completed);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TodoProfile> create(String userId, CreateTodoRequest request) async {
    try {
      final now = DateTime.now();
      final companion = TodosTableCompanion(
        userId: Value(UuidValue.fromString(userId)),
        title: Value(request.title),
        description: request.description != null ? Value(request.description) : const Value.absent(),
        completed: const Value(false),
        createdAt: Value(PgDateTime(now)),
        updatedAt: Value(PgDateTime(now)),
      );

      final id = await _todoDao.createTodo(companion);
      final todo = await _todoDao.getById(id);
      return _mapToTodoProfile(todo);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TodoProfile?> update(String id, UpdateTodoRequest request) async {
    try {
      final updates = TodosTableCompanion(
        title: request.title != null ? Value(request.title!) : const Value.absent(),
        description: request.description != null ? Value(request.description) : const Value.absent(),
        completed: request.completed != null ? Value(request.completed!) : const Value.absent(),
        updatedAt: Value(PgDateTime(DateTime.now())),
      );

      final success = await _todoDao.updateTodo(id, updates);
      if (!success) {
        return null;
      }

      final todo = await _todoDao.getById(id);
      return todo != null ? _mapToTodoProfile(todo) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      return await _todoDao.softDelete(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Map Drift TodosTableData to TodoProfile DTO
  TodoProfile _mapToTodoProfile(TodosTableData? todo) => TodoProfile(
    id: todo?.id.toString() ?? '',
    userId: todo?.userId.toString() ?? '',
    title: todo?.title ?? '',
    description: todo?.description,
    completed: todo?.completed ?? false,
    createdAt: todo?.createdAt.toDateTime() ?? DateTime.now(),
    updatedAt: todo?.updatedAt.toDateTime() ?? DateTime.now(),
  );
}
