import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';

class UsersTable extends Table {
  @override
  String get tableName => 'users';

  Column<UuidValue> get id => customType(PgTypes.uuid).withDefault(genRandomUuid())();
  TextColumn get name => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get roles => text().map(const RolesConverter())();
  Column<PgDateTime> get createdAt =>
      customType(PgTypes.timestampNoTimezone).clientDefault(() => PgDateTime(DateTime.now()))();
  Column<PgDateTime> get updatedAt =>
      customType(PgTypes.timestampNoTimezone).clientDefault(() => PgDateTime(DateTime.now()))();
  Column<PgDateTime> get deletedAt => customType(PgTypes.timestampNoTimezone).nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Converter para array de roles
class RolesConverter extends TypeConverter<List<String>, String> {
  const RolesConverter();

  @override
  List<String> fromSql(String fromDb) => fromDb.split(',').where((e) => e.isNotEmpty).toList();

  @override
  String toSql(List<String> value) => value.join(',');
}
