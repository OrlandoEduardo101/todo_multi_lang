enum TodoSyncState {
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  synced,
  syncError;

  bool get needsSync => switch (this) {
    TodoSyncState.synced => false,
    _ => true,
  };

  static TodoSyncState fromStorage(String value) => switch (value) {
    'pending_create' => TodoSyncState.pendingCreate,
    'pending_update' => TodoSyncState.pendingUpdate,
    'pending_delete' => TodoSyncState.pendingDelete,
    'synced' => TodoSyncState.synced,
    'sync_error' => TodoSyncState.syncError,
    _ => TodoSyncState.syncError,
  };

  String toStorage() => switch (this) {
    TodoSyncState.pendingCreate => 'pending_create',
    TodoSyncState.pendingUpdate => 'pending_update',
    TodoSyncState.pendingDelete => 'pending_delete',
    TodoSyncState.synced => 'synced',
    TodoSyncState.syncError => 'sync_error',
  };
}

sealed class TodoModel {
  const TodoModel({
    this.localId,
    this.remoteId,
    required this.userId,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  TodoModel copyWith({
    int? localId,
    String? remoteId,
    String? userId,
    String? title,
    String? description,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    TodoSyncState? syncState,
  }) {
    final nextCompleted = completed ?? this.completed;
    if (nextCompleted) {
      return CompletedTodo(
        localId: localId ?? this.localId,
        remoteId: remoteId ?? this.remoteId,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncState: syncState ?? this.syncState,
      );
    }
    return PendingTodo(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  const factory TodoModel.pending({
    int? localId,
    String? remoteId,
    required String userId,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    TodoSyncState syncState,
  }) = PendingTodo;

  const factory TodoModel.completed({
    int? localId,
    String? remoteId,
    required String userId,
    required String title,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    TodoSyncState syncState,
  }) = CompletedTodo;

  final int? localId;
  final String? remoteId;
  final String userId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TodoSyncState syncState;

  String get stableId => remoteId ?? 'local:$localId';
  bool get isSynced => syncState == TodoSyncState.synced;
  bool get isLocalOnly => remoteId == null;

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    final completed = json['completed'] as bool;
    final remoteId = json['id'] as String;
    final userId = json['userId'] as String;
    final title = json['title'] as String;
    final description = json['description'] as String?;
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final updatedAt = DateTime.parse(json['updatedAt'] as String);

    return completed
        ? TodoModel.completed(
            remoteId: remoteId,
            userId: userId,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: TodoSyncState.synced,
          )
        : TodoModel.pending(
            remoteId: remoteId,
            userId: userId,
            title: title,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncState: TodoSyncState.synced,
          );
  }

  Map<String, dynamic> toJson() => {
    'id': remoteId,
    'userId': userId,
    'title': title,
    'description': description,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

final class PendingTodo extends TodoModel {
  const PendingTodo({
    super.localId,
    super.remoteId,
    required super.userId,
    required super.title,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.syncState = TodoSyncState.pendingCreate,
  }) : super(completed: false);
}

final class CompletedTodo extends TodoModel {
  const CompletedTodo({
    super.localId,
    super.remoteId,
    required super.userId,
    required super.title,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.syncState = TodoSyncState.synced,
  }) : super(completed: true);
}
