# Architecture — Todo Flutter

**Version:** 1.0
**Updated:** March 2026
**Status:** `ACTIVE`

---

## Overview

**Todo Flutter** is the cross-platform Flutter frontend of the `todo_multi_lang` study project. It demonstrates how a single mobile/web/desktop client can talk to interchangeable REST backends (Dart Vaden, Go Fiber, Java Spring) while remaining fully functional offline through a local SQLite database and a background sync engine.

The app follows **Clean Architecture** principles organised by feature modules. All layers communicate through explicit contracts (abstract classes and the custom `Either` type), keeping platform and framework concerns isolated from business rules.

---

## Folder Structure

```
lib/
├── main.dart                          # Entry point — initialises DI then runs app
├── app/                               # All routed pages (Routefly scans this folder)
│   ├── app_widget.dart                # MaterialApp.router root — @Main annotation
│   ├── splash_page.dart               # Auth guard / loading screen
│   ├── home/
│   │   └── home_page.dart             # Todo list screen
│   └── auth/
│       ├── login/login_page.dart
│       ├── register/register_page.dart
│       └── widgets/                   # Auth-specific UI components
└── src/
    ├── root_biding.dart               # Single root AutoInjector (AppModule)
    ├── modules/
    │   ├── auth/                      # Authentication feature
    │   │   ├── auth_binding.dart      # Registers auth dependencies
    │   │   ├── models/                # AuthResponseModel, UserModel (sealed)
    │   │   ├── repositories/          # AuthRepository interface + Impl
    │   │   └── stores/
    │   │       ├── auth_store.dart    # Login / register / logout commands
    │   │       └── auth_session_store.dart  # JWT session state (ChangeNotifier)
    │   └── todo/                      # Todo feature
    │       ├── todo_binding.dart      # Registers todo dependencies
    │       ├── mappers/               # Drift ↔ Domain ↔ API JSON converters
    │       ├── models/                # TodoModel (sealed), TodoSyncState
    │       ├── repositories/          # TodoRepository interface + Impl
    │       ├── services/
    │       │   └── todo_sync_service.dart  # Background sync engine
    │       └── stores/
    │           └── todo_store.dart    # CRUD + sync commands
    └── shared/
        ├── database/
        │   ├── app_database.dart      # Drift database (Sessions + Todos tables)
        │   └── tables/                # Drift table definitions
        ├── either/either.dart         # Custom Either<L,R> sealed class
        ├── errors/app_exception.dart  # Domain exception
        ├── http/
        │   ├── http_client.dart       # HttpClient abstract interface
        │   ├── dio_http_client.dart   # Dio implementation
        │   ├── http_exception.dart    # HTTP error hierarchy
        │   └── interceptors/
        │       └── auth_interceptor.dart  # JWT injection + 401 handling
        ├── reactive_ui/
        │   ├── rx_command.dart        # RxCommand<T> and StreamRxCommand<T>
        │   ├── rx_command_builder.dart # Command-aware builder widget
        │   └── shimmer_loading.dart   # Shimmer placeholder widget
        └── widgets/
            └── responsive_layout_widget.dart
```

---

## Layers

### 1. Presentation Layer (`lib/app/`)

Pages live in `lib/app/` and are **automatically turned into routes** by Routefly based on their filename and directory. Each `*_page.dart` file becomes a URL path.

**Responsibilities:**
- Own widget lifecycle (`initState`, `dispose`).
- Obtain stores from the injector (`authModule.get<AuthStore>()`).
- Subscribe to individual Commands with `addListener` / `removeListener`.
- Execute store actions in response to user gestures.
- Navigate with `Routefly.navigate()` or `Routefly.push()`.

**Rules:**
- Pages orchestrate — they do **not** contain business logic.
- UI widgets receive only primitive values and callbacks, never whole stores.
- Theme tokens come exclusively from `Theme.of(context)`.

### 2. Store Layer (`lib/src/modules/<feature>/stores/`)

Stores are plain Dart classes (no superclass needed beyond what Commands provide). They hold **Commands** as `late final` fields and expose one method per action.

```dart
class TodoStore {
  final TodoRepository todoRepository;

  final StreamRxCommand<List<TodoModel>> todoList = StreamRxCommand();
  final RxCommand<TodoModel> createTodoCommand    = RxCommand();
  final RxCommand<TodoModel> updateTodoCommand    = RxCommand();
  final RxCommand<void>      deleteTodoCommand    = RxCommand();

  TodoStore(this.todoRepository);

  Future<void> createTodo(TodoModel todo) async {
    await createTodoCommand.execute(() async { ... });
  }
}
```

### 3. Domain Layer (`lib/src/modules/<feature>/models/` + `repositories/`)

- **Models** are plain Dart objects. `TodoModel` is a sealed class with `PendingTodo` and `CompletedTodo` subtypes.
- **Repository interfaces** declare the contract in terms of domain types and `Either<AppException, T>` return values.

### 4. Data Layer (`lib/src/modules/<feature>/repositories/` implementation classes + `services/`)

- **Repository implementations** call the HTTP client or local database, map raw data to domain models, and catch all exceptions inside `Either`.
- **`TodoSyncService`** is the offline-sync engine. It watches the `watchUnsyncedTodos()` stream and fires HTTP calls for each pending entry, updating the sync status column on success.

### 5. Infrastructure Layer (`lib/src/shared/`)

| Component | Responsibility |
|---|---|
| `AppDatabase` (Drift) | SQLite persistence: `Sessions` and `Todos` tables |
| `DioHttpClient` | Concrete `HttpClient` backed by Dio |
| `AuthInterceptor` | Injects `Authorization: Bearer <token>`; clears session on 401 |
| `AuthSessionStore` | Reactive JWT state read from the DB, consumed by the interceptor |

---

## State Management

The project uses a **custom reactive Command pattern** built on top of `ChangeNotifier`. No external state-management library (GetX, BLoC, Riverpod) is used.

### `RxCommand<T>`

Wraps an `async` operation and tracks its lifecycle:

| Property | Meaning |
|---|---|
| `isExecuting` | `true` while the action runs |
| `completed` | `true` after a successful run |
| `error` | Non-null string when the action threw |
| `value` / `valueOrNull` | The result after completion |

```dart
// Store — declaration
late final RxCommand<AuthResponseModel?> authCommand = RxCommand();

// Store — execution
Future<void> login(String email, String password) async {
  await authCommand.execute(() async {
    final result = await authRepository.login(email, password);
    return result.fold((e) => throw e, (auth) => auth);
  });
}

// Page — subscription (granular, not whole-store)
_authStore.authCommand.addListener(_onAuthChanged);

void _onAuthChanged() {
  if (_authStore.authCommand.completed) { ... navigate ... }
  if (_authStore.authCommand.error != null) { ... show snackbar ... }
}
```

### `StreamRxCommand<T>`

Wraps a continuous `Stream` (e.g., database watchers):

```dart
final StreamRxCommand<List<TodoModel>> todoList = StreamRxCommand();

todoList.listen(() => todoRepository.watchTodos());
```

UI reacts with `ValueListenableBuilder` targeting the command, never the whole store.

### `RxCommandBuilder`

Convenience widget that renders different states of an `RxCommand`:

```dart
RxCommandBuilder(
  rxCommand: store.myCommand,
  loadingBehavior: RxLoadingBehavior.replace, // or .overlay for pagination
  builder: (context, cmd) => ...,
  loadingBuilder: (context, cmd) => const ShimmerLoading(...),
  errorBuilder: (context, cmd) => Text(cmd.error!),
)
```

---

## Dependency Injection

`auto_injector` manages all dependencies through a **single root module** (`AppModule`). Feature bindings are plain functions that receive the injector and register their types.

```
main()
  └─ rootModule (AutoInjector, tag: 'AppModule')
       ├─ AppDatabase          (Singleton)
       ├─ AuthSessionStore     (Singleton)
       ├─ HttpClient           (Singleton → DioHttpClient)
       ├─ registerAuthBindings(i)
       │    ├─ AuthRepository  (Singleton → AuthRepositoryImpl)
       │    └─ AuthStore       (LazySingleton)
       └─ registerTodoBindings(i)
            ├─ TodoRepository  (Singleton → TodoRepositoryImpl)
            └─ TodoStore       (LazySingleton)
```

`authModule` and `todoModule` are `late final` aliases pointing to the same root injector after `commit()`. Pages resolve dependencies via `authModule.get<AuthStore>()` — never `new AuthStore(...)`.

---

## Navigation

Routefly generates route configuration automatically from the `lib/app/` folder. Every file matching `*_page.dart` becomes a route.

| File | Route path |
|---|---|
| `lib/app/splash_page.dart` | `/splash` (set as `initialPath`) |
| `lib/app/home/home_page.dart` | `/home` |
| `lib/app/auth/login/login_page.dart` | `/auth/login` |
| `lib/app/auth/register/register_page.dart` | `/auth/register` |

**After adding or removing a page, regenerate routes:**

```sh
dart run routefly
```

Navigation methods:

| Method | Behaviour |
|---|---|
| `Routefly.navigate(path)` | Replace entire stack |
| `Routefly.push(path)` | Push onto stack |
| `Routefly.pop()` | Pop current route |

---

## Offline-First Sync

`TodoSyncService` is started automatically when `TodoRepositoryImpl` is created. It subscribes to `AppDatabase.watchUnsyncedTodos()` and processes each pending record:

```
Local write (create / update / delete)
  └─ Set syncStatus = pendingCreate / pendingUpdate / pendingDelete
     └─ watchUnsyncedTodos() emits
          └─ TodoSyncService.syncNow()
               ├─ pendingCreate  → POST /api/todos
               ├─ pendingUpdate  → PUT  /api/todos/:id
               ├─ pendingDelete  → DELETE /api/todos/:id
               └─ syncError      → retry
```

On success the local row gets `syncStatus = synced` and the remote `remoteId` is stored locally.

---

## Error Handling

All repository methods return `Either<AppException, T>`:

```dart
Future<Either<AppException, AuthResponseModel>> login(...) async {
  try {
    ...
    return Either.right(auth);
  } on HttpException catch (e) {
    return Left(AppException(e.toString(), statusCode: e.statusCode));
  } catch (e) {
    return Left(AppException('Unexpected error: $e'));
  }
}
```

Callers use `.fold()` to handle both sides without try/catch:

```dart
final result = await authRepository.login(email, password);
return result.fold((error) => throw error, (auth) => auth);
```

---

## Data Models

### `TodoModel` (sealed)

```
TodoModel (sealed)
  ├─ PendingTodo   (completed = false)
  └─ CompletedTodo (completed = true)
```

`TodoSyncState` enum: `pendingCreate`, `pendingUpdate`, `pendingDelete`, `synced`, `syncError`

### `UserModel` (sealed)

```
UserModel (sealed)
  ├─ LoggedUserModel   (id, name, email, roles)
  └─ GuestUserModel    (anonymous / unauthenticated)
```

---

## Key Dependencies

| Package | Version | Role |
|---|---|---|
| `routefly` | ^3.1.3 | File-based navigation |
| `auto_injector` | ^2.1.1 | Dependency injection |
| `drift` | ^2.31.0 | Local SQLite ORM |
| `sqlite3_flutter_libs` | ^0.5.42 | SQLite native binaries |
| `dio` | ^5.9.2 | HTTP client |
| `path_provider` | ^2.1.5 | Device path resolution (DB file) |

No external state-management package is used. The reactive layer is implemented from scratch on top of `ChangeNotifier`.

---

## Sequence Diagram — Login Flow

```
User taps Login
  → LoginPage calls authStore.login(email, password)
    → authCommand.execute(...)
      → AuthRepositoryImpl.login(...)
        → DioHttpClient.post('/auth/login')
          → server responds with { token, user }
        → database.saveSession(auth)           // persist JWT locally
        → Either.right(auth)
      → authCommand.completed = true → notifyListeners()
    → _onAuthChanged() fires (addListener)
  → Routefly.navigate(routePaths.home)
```

---

## Sequence Diagram — Offline Todo Create

```
User adds a Todo (offline)
  → TodoStore.createTodo(todo)
    → TodoRepositoryImpl.createTodo(todo)
      → database.insertTodo(todo with syncStatus=pendingCreate)
      → Either.right(saved)
    → createTodoCommand.completed → UI updates

TodoSyncService (background)
  → watchUnsyncedTodos() emits [newTodo]
    → syncNow() → _syncCreate(entry)
      → DioHttpClient.post('/api/todos', body: entry.toApiJson())
        → server responds with remoteId
      → database.markSynced(localId, remoteId)
```
