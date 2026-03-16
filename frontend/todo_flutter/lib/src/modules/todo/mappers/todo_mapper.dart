import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';

extension TodoDriftToDomainMapper on Todo {
  TodoModel toDomain() {
    if (done) {
      return TodoModel.completed(
        localId: id,
        remoteId: remoteId,
        userId: userId ?? '',
        title: title,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
        syncState: TodoSyncState.fromStorage(syncStatus),
      );
    }

    return TodoModel.pending(
      localId: id,
      remoteId: remoteId,
      userId: userId ?? '',
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: TodoSyncState.fromStorage(syncStatus),
    );
  }
}

extension TodoDomainApiMapper on TodoModel {
  Map<String, dynamic> toApiJson() => {
    if (remoteId != null) 'id': remoteId,
    'userId': userId,
    'title': title,
    'description': description,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
