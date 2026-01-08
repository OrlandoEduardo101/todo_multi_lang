# 🗄️ Drift + PostgreSQL com Vaden - Guia de Integração

## Overview

Drift é um type-safe ORM para Dart que integra perfeitamente com o Vaden Framework. Este guia mostra como usar Drift ao invés de queries SQL diretas para o backend TODO.

---

## 1. Setup e Dependências

### pubspec.yaml

```yaml
dependencies:
  vaden: ^3.0.0
  vaden_security: ^2.0.0
  drift: ^2.28.1                    # ORM type-safe
  drift_postgres: ^1.3.1            # PostgreSQL driver
  postgres: ^3.5.0                  # Connection base
  shelf: ^1.4.1
  shelf_router: ^1.1.3
  bcrypt: ^0.1.1
  jwt: ^0.3.0
  dotenv: ^4.1.0

dev_dependencies:
  drift_dev: ^2.28.0                # Code generator
  build_runner: ^2.4.14             # Code generation
  test: ^1.25.0
  mocktail: ^1.0.0
  lints: ^2.1.0
```

---

## 2. Estrutura de Diretórios

```
lib/
├── config/
│   ├── database/
│   │   ├── database.dart           # AppDatabase (Drift)
│   │   ├── drift_configuration.dart # @Configuration @Bean
│   │   └── migrations.dart          # Version control
│   └── ...
├── src/
│   ├── database/
│   │   ├── tables/
│   │   │   ├── users_table.dart    # @DataClassName
│   │   │   └── todos_table.dart    # @DataClassName
│   │   └── daos/
│   │       ├── user_dao.dart       # User DAO
│   │       └── todo_dao.dart       # Todo DAO
│   ├── data/repositories/
│   │   ├── user_repository_impl.dart
│   │   └── todo_repository_impl.dart
│   └── ...
```

---

## 3. Definir Tables com Drift

### lib/src/database/tables/users_table.dart

```dart
import 'package:drift/drift.dart';

class UsersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();

  // Array de roles
  TextColumn get roles => text().map(const RolesConverter())();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// Converter para array de strings
class RolesConverter extends TypeConverter<List<String>, String> {
  const RolesConverter();

  @override
  List<String> fromSql(String fromDb) {
    return fromDb.split(',').where((e) => e.isNotEmpty).toList();
  }

  @override
  String toSql(List<String> value) {
    return value.join(',');
  }
}
```

### lib/src/database/tables/todos_table.dart

```dart
import 'package:drift/drift.dart';
import 'users_table.dart';

class TodosTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(UsersTable, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get updatedAt => dateTime().clientDefault(DateTime.now)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
```

---

## 4. Criar AppDatabase com Drift

### lib/config/database/database.dart

```dart
import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import '../../src/database/tables/users_table.dart';
import '../../src/database/tables/todos_table.dart';

part 'database.g.dart'; // Generated file

@DriftDatabase(tables: [UsersTable, TodosTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  // Optional: Migration strategies
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Handle migrations
      },
    );
  }
}
```

---

## 5. DAOs (Data Access Objects)

### lib/src/database/daos/user_dao.dart

```dart
import 'package:drift/drift.dart';
import '../../config/database/database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> {
  UserDao(AppDatabase db) : super(db);

  // Get all active users
  Future<List<UsersTableData>> getAllActive() {
    return (select(usersTable)
          ..where((u) => u.deletedAt.isNull())
          ..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  // Get user by email
  Future<UsersTableData?> findByEmail(String email) {
    return (select(usersTable)
          ..where((u) => u.email.equals(email) & u.deletedAt.isNull()))
        .getSingleOrNull();
  }

  // Create user
  Future<int> createUser(UsersTablesCompanion user) {
    return into(usersTable).insert(user);
  }

  // Soft delete
  Future<bool> softDelete(int id) async {
    final updated = await (update(usersTable)
          ..where((u) => u.id.equals(id)))
        .write(UsersTablesCompanion(deletedAt: Value(DateTime.now())));
    return updated > 0;
  }

  // Paginated query
  Future<List<UsersTableData>> getPaginated(int page, int limit) {
    final offset = (page - 1) * limit;
    return (select(usersTable)
          ..where((u) => u.deletedAt.isNull())
          ..limit(limit, offset: offset)
          ..orderBy([(u) => OrderingTerm(expression: u.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  // Count active users
  Future<int> countActive() {
    return (select(usersTable)..where((u) => u.deletedAt.isNull())).get().then((list) => list.length);
  }
}
```

### lib/src/database/daos/todo_dao.dart

```dart
import 'package:drift/drift.dart';
import '../../config/database/database.dart';
import '../tables/todos_table.dart';

part 'todo_dao.g.dart';

@DriftAccessor(tables: [TodosTable])
class TodoDao extends DatabaseAccessor<AppDatabase> {
  TodoDao(AppDatabase db) : super(db);

  // Get todos by user with filters
  Future<List<TodosTableData>> getByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
    String? search,
    bool? completed,
    String sortBy = 'created_at',
    String order = 'desc',
  }) {
    final offset = (page - 1) * limit;

    var query = select(todosTable)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());

    // Add search filter
    if (search != null && search.isNotEmpty) {
      query = query..where((t) => t.title.like('%$search%'));
    }

    // Add completed filter
    if (completed != null) {
      query = query..where((t) => t.completed.equals(completed));
    }

    // Add sorting
    final orderTerm = OrderingTerm(
      expression: _getOrderColumn(sortBy),
      mode: order.toLowerCase() == 'asc' ? OrderingMode.asc : OrderingMode.desc,
    );

    query = query
      ..orderBy([orderTerm])
      ..limit(limit, offset: offset);

    return query.get();
  }

  // Helper to get column for sorting
  Expression<DateTime> _getOrderColumn(String sortBy) {
    switch (sortBy) {
      case 'title':
        return todosTable.title;
      case 'completed':
        return todosTable.completed;
      case 'updated_at':
        return todosTable.updatedAt;
      default:
        return todosTable.createdAt;
    }
  }

  // Create todo
  Future<int> createTodo(TodosTableCompanion todo) {
    return into(todosTable).insert(todo);
  }

  // Update todo
  Future<bool> updateTodo(int id, TodosTableCompanion updates) async {
    final updated = await (update(todosTable)
          ..where((t) => t.id.equals(id)))
        .write(updates);
    return updated > 0;
  }

  // Soft delete
  Future<bool> softDelete(int id) async {
    final updated = await (update(todosTable)
          ..where((t) => t.id.equals(id)))
        .write(TodosTableCompanion(deletedAt: Value(DateTime.now())));
    return updated > 0;
  }

  // Get by ID
  Future<TodosTableData?> getById(int id) {
    return (select(todosTable)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  // Count todos for user
  Future<int> countByUserId(int userId, {String? search, bool? completed}) {
    var query = select(todosTable)
      ..where((t) => t.userId.equals(userId) & t.deletedAt.isNull());

    if (search != null && search.isNotEmpty) {
      query = query..where((t) => t.title.like('%$search%'));
    }

    if (completed != null) {
      query = query..where((t) => t.completed.equals(completed));
    }

    return query.get().then((list) => list.length);
  }
}
```

---

## 6. Configuration com Vaden

### lib/config/database/drift_configuration.dart

```dart
import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:vaden/vaden.dart';
import 'database.dart';
import '../../src/database/daos/user_dao.dart';
import '../../src/database/daos/todo_dao.dart';

@Configuration()
class DriftConfiguration {
  @Bean()
  Future<AppDatabase> appDatabase(
    String dbHost,
    int dbPort,
    String dbName,
    String dbUser,
    String dbPassword,
  ) async {
    // Create PostgreSQL connection
    final executor = PgDatabase(
      postgres.PgPool(
        postgres.PgEndpoint(
          host: dbHost,
          port: dbPort,
          database: dbName,
          username: dbUser,
          password: dbPassword,
        ),
      ),
    );

    return AppDatabase(executor);
  }

  @Bean()
  UserDao userDao(AppDatabase db) {
    return UserDao(db);
  }

  @Bean()
  TodoDao todoDao(AppDatabase db) {
    return TodoDao(db);
  }
}
```

---

## 7. Repositories Usando DAOs

### lib/src/data/repositories/user_repository_impl.dart

```dart
import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../../dto/user_dto.dart';
import '../../database/daos/user_dao.dart';
import '../../database/tables/users_table.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDao _userDao;
  final PasswordEncoder _passwordEncoder;

  UserRepositoryImpl(this._userDao, this._passwordEncoder);

  @override
  Future<UserProfile?> findById(int id) async {
    final user = await _userDao.db.select(_userDao.db.usersTable)
      ..where((u) => u.id.equals(id) & u.deletedAt.isNull());

    final result = await user.getSingleOrNull();
    if (result == null) return null;

    return _mapToUserProfile(result);
  }

  @override
  Future<UserProfile?> findByEmail(String email) async {
    final user = await _userDao.findByEmail(email);
    if (user == null) return null;

    return _mapToUserProfile(user);
  }

  @override
  Future<List<UserProfile>> findAll({int page = 1, int limit = 10}) async {
    final users = await _userDao.getPaginated(page, limit);
    return users.map(_mapToUserProfile).toList();
  }

  @override
  Future<int> getTotalCount() {
    return _userDao.countActive();
  }

  @override
  Future<UserProfile> create(CreateUserRequest request) async {
    final hashedPassword = _passwordEncoder.encode(request.password);

    final id = await _userDao.createUser(
      UsersTableCompanion(
        firstName: Value(request.firstName),
        lastName: Value(request.lastName),
        email: Value(request.email),
        password: Value(hashedPassword),
        roles: Value(request.roles),
      ),
    );

    // Fetch and return created user
    final user = await _userDao.db.select(_userDao.db.usersTable)
      ..where((u) => u.id.equals(id));

    final result = await user.getSingle();
    return _mapToUserProfile(result);
  }

  @override
  Future<UserProfile?> update(int id, UpdateUserRequest request) async {
    final updates = <String, dynamic>{};

    if (request.firstName != null) updates['firstName'] = request.firstName;
    if (request.lastName != null) updates['lastName'] = request.lastName;
    if (request.email != null) updates['email'] = request.email;
    if (request.roles != null) updates['roles'] = request.roles;

    if (updates.isEmpty) return findById(id);

    updates['updatedAt'] = DateTime.now();

    final updateQuery = _userDao.db.update(_userDao.db.usersTable)
      ..where((u) => u.id.equals(id));

    await updateQuery.write(
      UsersTableCompanion(
        firstName: request.firstName != null ? Value(request.firstName!) : const Value.absent(),
        lastName: request.lastName != null ? Value(request.lastName!) : const Value.absent(),
        email: request.email != null ? Value(request.email!) : const Value.absent(),
        roles: request.roles != null ? Value(request.roles!) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return findById(id);
  }

  @override
  Future<bool> delete(int id) {
    return _userDao.softDelete(id);
  }

  UserProfile _mapToUserProfile(UsersTableData user) {
    return UserProfile(
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      roles: user.roles,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
```

---

## 8. Generate Code

```bash
# Generate Drift code
dart run build_runner build

# Watch mode (regenerate on file changes)
dart run build_runner watch
```

---

## 9. Vantagens do Drift

✅ **Type-safe** - Erros de query em compile-time
✅ **Auto-generated** - Menos boilerplate
✅ **Refactoring** - Rename columns com segurança
✅ **Testable** - Mock databases facilmente
✅ **PostgreSQL support** - Native integration
✅ **Migrations** - Versionamento automático
✅ **Relations** - Foreign keys com type-safety

---

## 10. Comparação: SQL direto vs Drift

### ❌ Com SQL direto (atual)
```dart
final result = await _connection.execute(
  Sql.named('''
    SELECT * FROM users WHERE email = @email AND deleted_at IS NULL
  '''),
  parameters: {'email': email},
);
```
**Problemas:** String queries, sem type-safety, erros em runtime

### ✅ Com Drift
```dart
final user = await (select(usersTable)
  ..where((u) => u.email.equals(email) & u.deletedAt.isNull())
).getSingleOrNull();
```
**Benefícios:** Type-safe, refactoring seguro, erros em compile-time

---

## 11. Migration Path

### Fase 1: Manutenção Atual (✅ Pronto)
- Usar SQL direto com postgres package
- Funcional e em produção

### Fase 2: Preparação (🔄 Próximo)
- Adicionar Drift gradualmente
- Manter compatibilidade

### Fase 3: Migração Completa (🏗️ Futuro)
- Converter todos repositórios para DAOs
- Usar Drift como única fonte de queries

---

## 12. Exemplo Completo: Migrar TodoRepository

### Antes (SQL direto)
```dart
class TodoRepositoryImpl implements TodoRepository {
  final Connection _connection;

  Future<TodoProfile?> findById(int id) async {
    final result = await _connection.execute(
      Sql.named('SELECT * FROM todos WHERE id = @id AND deleted_at IS NULL'),
      parameters: {'id': id},
    );
    // ... parse result
  }
}
```

### Depois (Drift)
```dart
class TodoRepositoryImpl implements TodoRepository {
  final TodoDao _todoDao;

  Future<TodoProfile?> findById(int id) async {
    final todo = await _todoDao.getById(id);
    return todo != null ? _mapToTodoProfile(todo) : null;
  }
}
```

---

## Referências

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Drift + PostgreSQL](https://drift.simonbinder.eu/docs/setup/database_setup/)
- [Vaden Integration](https://doc.vaden.dev/docs/)

---

**Status:** 🏗️ Guia para integração futura com Drift
**Quando implementar:** Após validação do backend SQL atual
**Benefício:** Type-safety e melhor experiência de desenvolvimento
