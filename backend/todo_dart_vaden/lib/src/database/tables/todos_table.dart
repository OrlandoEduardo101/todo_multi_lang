import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'users_table.dart';

class TodosTable extends Table {
  @override
  String get tableName => 'todos';

  Column<UuidValue> get id => customType(PgTypes.uuid).withDefault(genRandomUuid())();
  Column<UuidValue> get userId => customType(PgTypes.uuid).references(UsersTable, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  Column<PgDateTime> get createdAt =>
      customType(PgTypes.timestampNoTimezone).clientDefault(() => PgDateTime(DateTime.now()))();
  Column<PgDateTime> get updatedAt =>
      customType(PgTypes.timestampNoTimezone).clientDefault(() => PgDateTime(DateTime.now()))();
  Column<PgDateTime> get deletedAt => customType(PgTypes.timestampNoTimezone).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
