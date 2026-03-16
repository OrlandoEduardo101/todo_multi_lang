import 'package:drift/drift.dart';

abstract final class TodoSyncStatus {
  static const pendingCreate = 'pending_create';
  static const pendingUpdate = 'pending_update';
  static const pendingDelete = 'pending_delete';
  static const synced = 'synced';
  static const syncError = 'sync_error';
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable().unique()();
  TextColumn get userId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant(TodoSyncStatus.pendingCreate))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
