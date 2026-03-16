import 'dart:async';

import 'package:todo_flutter/src/modules/todo/mappers/todo_mapper.dart';
import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';
import 'package:todo_flutter/src/shared/database/tables/todos_table.dart';
import 'package:todo_flutter/src/shared/http/http_client.dart';

class TodoSyncService {
  TodoSyncService({required this.database, required this.httpClient});

  final AppDatabase database;
  final HttpClient httpClient;
  static const String _todosEndpoint = '/api/todos';

  StreamSubscription<List<Todo>>? _subscription;
  bool _isSyncing = false;

  Future<void> startAutoSync() async {
    await _subscription?.cancel();
    _subscription = database.watchUnsyncedTodos().listen((_) {
      // Fire-and-forget, guarded by _isSyncing.
      unawaited(syncNow());
    });
  }

  Future<void> stopAutoSync() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await database.watchUnsyncedTodos().first;
      for (final entry in pending) {
        await _syncEntry(entry);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncEntry(Todo entry) async {
    try {
      switch (entry.syncStatus) {
        case TodoSyncStatus.pendingCreate:
          await _syncCreate(entry);
          break;
        case TodoSyncStatus.pendingUpdate:
          await _syncUpdate(entry);
          break;
        case TodoSyncStatus.pendingDelete:
          await _syncDelete(entry);
          break;
        case TodoSyncStatus.syncError:
          await _retrySyncError(entry);
          break;
        case TodoSyncStatus.synced:
          break;
      }
    } catch (_) {
      await database.markSyncError(entry.id);
    }
  }

  Future<void> _syncCreate(Todo entry) async {
    final response = await httpClient.post(_todosEndpoint, body: entry.toDomain().toApiJson());
    final remote = _extractTodo(response);

    if (remote != null) {
      await database.markSynced(localId: entry.id, remoteId: remote.remoteId);
      return;
    }

    // If the server response cannot be parsed, keep it unsynced so it can be
    // retried instead of becoming a local-only "synced" record.
    await database.markSyncError(entry.id);
  }

  Future<void> _syncUpdate(Todo entry) async {
    if (entry.remoteId == null) {
      // If there is no remote ID yet, this update should be treated as create.
      await _syncCreate(entry);
      return;
    }

    final response = await httpClient.put('$_todosEndpoint/${entry.remoteId}', body: entry.toDomain().toApiJson());
    final remote = _extractTodo(response);

    await database.markSynced(localId: entry.id, remoteId: remote?.remoteId ?? entry.remoteId);
  }

  Future<void> _syncDelete(Todo entry) async {
    if (entry.remoteId == null) {
      // Local-only item: safe to remove permanently.
      await database.deleteTodo(entry.id);
      return;
    }

    await httpClient.delete('$_todosEndpoint/${entry.remoteId}');
    await database.deleteTodo(entry.id);
  }

  Future<void> _retrySyncError(Todo entry) async {
    if (entry.remoteId == null) {
      await _syncCreate(entry);
      return;
    }

    if (entry.deletedAt != null) {
      await _syncDelete(entry);
      return;
    }

    await _syncUpdate(entry);
  }

  TodoModel? _extractTodo(Map<String, dynamic> response) {
    final dynamic payload = response['data'] ?? response['todo'] ?? response;
    if (payload is Map<String, dynamic> && (payload['id'] != null || payload['ID'] != null)) {
      return TodoModel.fromJson(payload);
    }

    if (payload is Map<String, dynamic> && payload['results'] is List) {
      final list = (payload['results'] as List).whereType<Map<String, dynamic>>().toList(growable: false);
      if (list.isNotEmpty) {
        return TodoModel.fromJson(list.first);
      }
    }
    return null;
  }
}
