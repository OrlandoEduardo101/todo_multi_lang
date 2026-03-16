// database/tables/sessions_table.dart
import 'package:drift/drift.dart';
import 'package:todo_flutter/src/modules/auth/models/auth_model.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';

class Sessions extends Table {
  // Linha única — id fixo em 1
  IntColumn get id => integer()();

  TextColumn get token => text()();
  TextColumn get tokenType => text().withDefault(const Constant('Bearer'))();
  IntColumn get expiresIn => integer()();
  DateTimeColumn get expiresAt => dateTime()(); // calculado no save

  // UserModel — nullable = GuestUser
  TextColumn get userId => text().nullable()();
  TextColumn get userEmail => text().nullable()();
  TextColumn get userName => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// extension para não poluir o model
// Session = classe de dados gerada pelo Drift (não Sessions que é a definição da tabela)
extension SessionMapper on Session {
  AuthResponseModel toModel() => AuthResponseModel(
    token: token,
    tokenType: tokenType,
    expiresIn: expiresIn,
    user: userId != null
        ? UserModel.loggedUser(id: userId!, email: userEmail!, name: userName!)
        : const UserModel.guestUser(),
  );

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
