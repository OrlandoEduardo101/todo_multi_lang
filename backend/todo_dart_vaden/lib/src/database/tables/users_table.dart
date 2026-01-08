import 'package:drift/drift.dart';

class UsersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get roles => text().map(const RolesConverter())();
  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Converter para array de roles
class RolesConverter extends TypeConverter<List<String>, String> {
  const RolesConverter();

  @override
  List<String> fromSql(String fromDb) => fromDb.split(',').where((e) => e.isNotEmpty).toList();

  @override
  String toSql(List<String> value) => value.join(',');
}
