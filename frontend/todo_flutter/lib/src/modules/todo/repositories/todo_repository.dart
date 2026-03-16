import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/modules/todo/mappers/todo_mapper.dart';
import 'package:todo_flutter/src/modules/todo/services/todo_sync_service.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';
import 'package:todo_flutter/src/shared/database/tables/todos_table.dart';
import 'package:todo_flutter/src/shared/either/either.dart';
import 'package:todo_flutter/src/shared/errors/app_exception.dart';
import 'package:todo_flutter/src/shared/http/http_client.dart';

abstract class TodoRepository {
  Future<Either<AppException, TodoModel>> createTodo(TodoModel todo);
  Future<Either<AppException, List<TodoModel>>> fetchTodos();
  Future<Either<AppException, TodoModel>> updateTodo(TodoModel todo);
  Future<Either<AppException, void>> deleteTodo(int id);
  Future<Either<AppException, void>> syncTodos();
  Future<Either<AppException, void>> clearCompleted();
  Future<Either<AppException, void>> clearAll();
  Future<Either<AppException, void>> clearSynced();
  Future<Stream<List<TodoModel>>> watchTodos();
}

class TodoRepositoryImpl implements TodoRepository {
  final AppDatabase database;
  final HttpClient httpClient;
  late final TodoSyncService _syncService;
  static const String _todosEndpoint = '/api/todos';

  TodoRepositoryImpl({required this.database, required this.httpClient}) {
    _syncService = TodoSyncService(database: database, httpClient: httpClient);
    _syncService.startAutoSync();
  }

  @override
  Future<Either<AppException, TodoModel>> createTodo(TodoModel todo) async {
    try {
      final created = TodoModel.pending(
        localId: todo.localId,
        remoteId: todo.remoteId,
        userId: todo.userId,
        title: todo.title,
        description: todo.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncState: TodoSyncState.pendingCreate,
      );

      final localId = await database.insertTodo(created);
      final saved = created.copyWith(localId: localId, syncState: TodoSyncState.pendingCreate);

      return Right(saved);
    } catch (e) {
      return Left(AppException('Failed to create todo: $e'));
    }
  }

  @override
  Future<Either<AppException, List<TodoModel>>> fetchTodos() async {
    try {
      final response = await httpClient.get('$_todosEndpoint?page=1&limit=10&sort=created_at&order=desc');
      final todos = _extractTodoList(response);

      for (final item in todos) {
        await database.upsertRemoteTodo(item);
      }

      return Right(todos);
    } catch (e) {
      return Left(AppException('Failed to fetch todos: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> clearAll() async {
    try {
      await database.clearAllTodos();
      return const Right(null);
    } catch (e) {
      return Left(AppException('Failed to clear all todos: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> clearCompleted() async {
    try {
      await database.clearCompletedTodos();
      return const Right(null);
    } catch (e) {
      return Left(AppException('Failed to clear completed todos: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> clearSynced() async {
    try {
      await database.clearSyncedTodos();
      return const Right(null);
    } catch (e) {
      return Left(AppException('Failed to clear synced todos: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteTodo(int id) async {
    try {
      var existing = await database.getTodoById(id);
      if (existing == null) {
        return Left(AppException('Todo with id $id not found'));
      }

      if (existing.remoteId == null) {
        // Legacy edge-case: item marked as synced but missing remoteId.
        // Pull remote list and try to reconcile before deciding local-only delete.
        if (existing.syncStatus == TodoSyncStatus.synced) {
          await fetchTodos();
          existing = await database.getTodoById(id);
        }
      }

      if (existing?.remoteId == null) {
        await database.deleteTodo(id);
      } else {
        await database.markPendingDelete(id);
      }

      return const Right(null);
    } catch (e) {
      return Left(AppException('Failed to delete todo: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> syncTodos() async {
    try {
      await _syncService.syncNow();
      await fetchTodos();
      return const Right(null);
    } catch (e) {
      return Left(AppException('Failed to sync todos: $e'));
    }
  }

  @override
  Future<Either<AppException, TodoModel>> updateTodo(TodoModel todo) async {
    try {
      final localId = todo.localId;
      if (localId == null) {
        return Left(AppException('Todo localId is required for update'));
      }

      final syncState = todo.remoteId == null ? TodoSyncState.pendingCreate : TodoSyncState.pendingUpdate;
      final updated = todo.copyWith(updatedAt: DateTime.now(), syncState: syncState);

      await database.updateTodo(localId, updated);
      return Right(updated);
    } catch (e) {
      return Left(AppException('Failed to update todo: $e'));
    }
  }

  @override
  Future<Stream<List<TodoModel>>> watchTodos() async {
    return database.watchAllTodos().map((rows) => rows.map((row) => row.toDomain()).toList());
  }

  List<TodoModel> _extractTodoList(Map<String, dynamic> response) {
    final dynamic payload = response['data'] ?? response['results'] ?? response['todos'] ?? response;

    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              return TodoModel.fromJson(item);
            } catch (_) {
              return null;
            }
          })
          .whereType<TodoModel>()
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic> && payload['results'] is List) {
      return (payload['results'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              return TodoModel.fromJson(item);
            } catch (_) {
              return null;
            }
          })
          .whereType<TodoModel>()
          .toList(growable: false);
    }

    if (payload is Map<String, dynamic> && (payload['id'] != null || payload['ID'] != null)) {
      try {
        return [TodoModel.fromJson(payload)];
      } catch (_) {
        return const [];
      }
    }

    return const [];
  }
}
