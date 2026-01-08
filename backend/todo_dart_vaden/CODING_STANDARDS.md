# Coding Standards - Todo Dart Vaden Backend

## Null Safety & Type Handling

### ✅ CORRECT: Nullable Mapping with Safe Navigation

Always use safe navigation operator (`?.`) with default values (`??`) when handling nullable types. Never use `dynamic` or type casting.

```dart
// ✅ CORRECT - Safe navigation with specific type and defaults
UserProfile _mapToUserProfile(UsersTableData? user) => UserProfile(
  id: user?.id ?? 0,
  firstName: user?.firstName ?? '',
  lastName: user?.lastName ?? '',
  email: user?.email ?? '',
  roles: user?.roles ?? [],
  createdAt: user?.createdAt ?? DateTime.now(),
  updatedAt: user?.updatedAt ?? DateTime.now(),
);
```

### ❌ INCORRECT: Dynamic with Type Casting

Never use `dynamic` with type casting (`.as`) for nullable handling.

```dart
// ❌ WRONG - Using dynamic and type casting
UserProfile _mapToUserProfile(dynamic user) => UserProfile(
  id: user.id as int,
  firstName: user.firstName as String,
  // ...
);
```

### ❌ INCORRECT: Nullable Checking Inside Method

Don't use null checks before calling mapper if the mapper can handle it.

```dart
// ❌ WRONG - Unnecessary null check
final user = await _userDao.findById(id);
if (user == null) {
  throw Exception('User not found');
}
return _mapToUserProfile(user);

// ✅ CORRECT - Let mapper handle null
final user = await _userDao.findById(id);
return user != null ? _mapToUserProfile(user) : null;
```

## Repository Pattern

### ✅ CORRECT: Use DAO Methods

Always delegate data access to DAOs. Don't access `_dao.db` directly in repositories.

```dart
// ✅ CORRECT - Using DAO methods
@override
Future<List<UserProfile>> findAll({int page = 1, int limit = 10}) async {
  try {
    final users = await _userDao.getPaginated(page, limit);
    return users.map(_mapToUserProfile).toList();
  } catch (e) {
    rethrow;
  }
}
```

### ❌ INCORRECT: Direct Database Access

Never bypass the DAO layer by accessing database directly.

```dart
// ❌ WRONG - Accessing _dao.db directly
@override
Future<List<UserProfile>> findAll({int page = 1, int limit = 10}) async {
  final users = await _userDao.db.select(_userDao.db.usersTable)
    ..limit(limit, offset: offset)
    .get();
  return users.map(_mapToUserProfile).toList();
}
```

## Import Management

### ✅ CORRECT: Remove Unused Imports

Keep imports clean and minimal. Remove any imports that aren't directly used in the file.

```dart
// ✅ CORRECT - Only necessary imports
import 'package:drift/drift.dart';
import 'package:vaden/vaden.dart';

import '../../database/daos/user_dao.dart';
import '../../domain/repositories/user_repository.dart';
import '../../dto/user_dto.dart';
```

### ❌ INCORRECT: Unused Imports

Don't keep unused imports, especially re-exports like `database.dart` or `tables`.

```dart
// ❌ WRONG - Unused imports
import '../../../config/database/database.dart'; // Not used
import '../../database/tables/users_table.dart'; // Generated type, already through DAO
```

## Drift Companion Classes

### ✅ CORRECT: Drift Generated Names

Use exact Drift-generated names for companion classes (no `$` suffix).

```dart
// ✅ CORRECT - Exact Drift generated names
final companion = UsersTableCompanion(
  firstName: Value(request.firstName),
  email: Value(request.email),
  // ...
);

final companion = TodosTableCompanion(
  title: Value(request.title),
  // ...
);
```

### ❌ INCORRECT: Wrong Companion Class Names

Don't use `$Companion` suffix or generic names.

```dart
// ❌ WRONG - Incorrect names
final companion = UsersTable$Companion(...); // Wrong format
final companion = UsersTableData(...); // This is the row type, not companion
```

## DAO Pattern

### ✅ CORRECT: Type-Specific Returns

DAOs return specific data types, not generic types.

```dart
// ✅ CORRECT - Specific types
@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> {
  // Returns data type, not table definition
  Future<List<UsersTableData>> getAllActive() => ...;

  // Returns nullable data type
  Future<UsersTableData?> findById(int id) => ...;

  // Takes companion type for mutations
  Future<int> createUser(UsersTableCompanion user) => ...;
}
```

### ❌ INCORRECT: Mixed Type Returns

Don't mix table types with data types.

```dart
// ❌ WRONG - Inconsistent types
Future<List<UsersTable>> getAllActive() => ...; // Should be UsersTableData
Future<UsersTable?> findById(int id) => ...; // Should be UsersTableData?
```

## Summary of Type Mapping

| Context | Type | Example |
|---------|------|---------|
| DAO Select | `DataType` | `UsersTableData`, `TodosTableData` |
| DAO Nullable Select | `DataType?` | `UsersTableData?`, `TodosTableData?` |
| DAO Insert/Update | `Companion` | `UsersTableCompanion`, `TodosTableCompanion` |
| Mapper Input (Nullable) | `DataType?` | `UsersTableData? user` |
| Mapper Safe Access | `?.` operator | `user?.id ?? defaultValue` |

---

**Last Updated:** 2026-01-08
**Standards Version:** 1.0
