# AI Development Rules

**Development guidelines for AI-assisted coding in the Todo Flutter project**

> 📋 **Architecture reference**: [ARCHITECTURE.md](./ARCHITECTURE.md)
> 📋 **Theme usage**: [theme-usage-guide.md](./theme-usage-guide.md)
> 📋 **Component rules**: [screen-componentization-ai-ready.md](./screen-componentization-ai-ready.md)
> 📋 **Responsive layout**: [responsive-layout.md](./responsive-layout.md)
> 📋 **Navigation**: [routes-navigation-system.md](./routes-navigation-system.md)
> 📋 **Dependency injection**: [dependency-injector.md](./dependency-injector.md)

---

## Project Context

**Todo Flutter** is the cross-platform Flutter frontend of the `todo_multi_lang` study project. It is a Todo management app that works **offline-first** (local SQLite via Drift) and syncs data in the background to a configurable REST backend (Dart Vaden, Go Fiber, or Java Spring). It targets mobile, tablet, and desktop through responsive and adaptive layouts.

### Screens
- **Splash**: Auth guard. Reads local session and redirects to Login or Home.
- **Login / Register**: JWT authentication forms with responsive brand panel.
- **Home**: Todo list with create, toggle-complete, delete, and manual sync actions.

---

## 🚫 Prohibited Patterns

### Architecture Violations
- **NEVER** use GetX — the project uses `auto_injector` + `routefly` + custom `RxCommand`
- **NEVER** use BLoC, Riverpod, or any other external state-management library
- **NEVER** create `.route.dart` files manually — Routefly auto-generates them
- **NEVER** instantiate services/repositories directly in widgets or pages
- **NEVER** use the Controller pattern — use Stores instead
- **NEVER** declare Commands outside a Store

### Code Violations
- **NEVER** use `print()` — use `log()` from `dart:developer`
- **NEVER** use inline `_build...()` methods to build layouts — create named custom widgets
- **NEVER** use `withOpacity()` — use `withValues(alpha:)`
- **NEVER** use hardcoded colors or text styles — always use the theme
- **NEVER** use `CircularProgressIndicator` for content loading states — use shimmer effects

### UI State Listening Violations
- **NEVER** listen to an entire Store with `ListenableBuilder`
- **NEVER** pass whole stores to shared or reusable widgets
- **ALWAYS** listen to individual Commands with `addListener` / `removeListener` in pages
- **NEVER** rebuild the entire UI when only one command state changes

### Temporary File Violations
- **NEVER** commit temporary files (`_refactored.dart`, `_new.dart`, `_tmp.dart`, etc.)
- Temporary files are only allowed on short-lived feature branches; delete them before merging

### Theme and Style Violations
- **NEVER** use `AppColors.*` directly — use `theme.colorScheme.*`
- **NEVER** use `Colors.*` directly in widgets
- **NEVER** use hardcoded `Color(0xFF...)` values
- **NEVER** call `Theme.of(context)` more than once per widget — cache it in `final theme`

---

## ✅ Required Patterns

### State Management
- **ALWAYS** use `RxCommand<T>` or `StreamRxCommand<T>` for async business logic
- **ALWAYS** declare Commands as `late final` fields inside the Store
- **ALWAYS** expose one public method per action on the Store:
  ```dart
  late final RxCommand<TodoModel> createTodoCommand = RxCommand<TodoModel>();

  Future<void> createTodo(TodoModel todo) async {
    await createTodoCommand.execute(() async {
      final result = await todoRepository.createTodo(todo);
      return result.fold((e) => throw e, (created) => created);
    });
  }
  ```
- **ALWAYS** use `result.fold()` to convert `Either` results — never re-throw raw exceptions

### Navigation
- **ALWAYS** use `Routefly.navigate()` or `Routefly.push()` for navigation
- **ALWAYS** place pages in `lib/app/` with filenames ending in `_page.dart`
- **ALWAYS** run `dart run routefly` after adding or removing a page
- **ALWAYS** pass route arguments via `Routefly.of(context).query.arguments`

### Data Layer
- **ALWAYS** define repository contracts in the abstract interface class
- **ALWAYS** return `Either<AppException, T>` from every repository method
- **ALWAYS** catch all exceptions inside repository implementations; never let them propagate raw
- **ALWAYS** use the mapper extension (`toDomain()`, `toApiJson()`) to convert between layers

### Dependency Injection
- **ALWAYS** type registrations explicitly: `injector.addSingleton<AuthStore>(AuthStore.new)`
- **ALWAYS** use `.new` for constructor references in DI registration
- **ALWAYS** resolve dependencies at the page level: `authModule.get<AuthStore>()`
- **NEVER** resolve dependencies inside constructors of other classes

### UI and Design
- **ALWAYS** cache theme: `final theme = Theme.of(context);`
- **ALWAYS** use semantic theme tokens:
  ```dart
  color: theme.colorScheme.primary        // ✅
  color: Colors.blue                      // ❌
  textStyle: theme.textTheme.bodyMedium   // ✅
  textStyle: AppTextStyles.bodyMedium     // ❌
  ```
- **ALWAYS** use `withValues(alpha:)` for transparency:
  ```dart
  theme.colorScheme.primary.withValues(alpha: 0.1)  // ✅
  AppColors.primary.withOpacity(0.1)                // ❌
  ```
- **ALWAYS** use shimmer for content/list loading states (see `ShimmerLoading`)
- **ALWAYS** prefer small `CircularProgressIndicator` (max 20×20) only inside action buttons

### Lifecycle
- **ALWAYS** add command listeners in `initState()` and remove them in `dispose()`
- **ALWAYS** call store actions that start background work from `initState()` (not the constructor)
- **ALWAYS** call `dispose()` on Stores and Streams when the widget is unmounted

### Code Style
- **ALWAYS** use English for identifiers (files, classes, variables, methods)
- **ALWAYS** use Brazilian Portuguese for user-facing text displayed in the app
- **ALWAYS** use `snake_case` for file and folder names
- **ALWAYS** name files `[feature]_[type].dart` (e.g., `todo_store.dart`, `auth_repository.dart`)
- **EXCEPTION** — generated files (`*.g.dart`, `*.route.dart`) are exempt from naming rules
- **ALWAYS** use `PascalCase` for class names, `camelCase` for variables and methods
- **ALWAYS** use `log()` from `dart:developer` (never `print()`)

---

## 📁 Project Structure

```
lib/
├── main.dart                        # Entry point — init DI, runApp
├── app/                             # Routefly pages (folder = route segment, *_page.dart = route)
│   ├── app_widget.dart              # MaterialApp.router root
│   ├── splash_page.dart
│   ├── home/home_page.dart
│   └── auth/
│       ├── login/login_page.dart
│       └── register/register_page.dart
└── src/
    ├── root_biding.dart             # Single AutoInjector root (AppModule)
    ├── modules/
    │   ├── auth/                    # Auth feature module
    │   │   ├── auth_binding.dart
    │   │   ├── models/
    │   │   ├── repositories/
    │   │   └── stores/
    │   └── todo/                    # Todo feature module
    │       ├── todo_binding.dart
    │       ├── mappers/
    │       ├── models/
    │       ├── repositories/
    │       ├── services/
    │       └── stores/
    └── shared/
        ├── database/                # Drift (SQLite) — Sessions + Todos tables
        ├── either/                  # Custom Either<L,R> type
        ├── errors/                  # AppException
        ├── http/                    # HttpClient interface, DioHttpClient, AuthInterceptor
        ├── reactive_ui/             # RxCommand, StreamRxCommand, RxCommandBuilder, ShimmerLoading
        └── widgets/                 # Shared reusable widgets (ResponsiveLayoutWidget)
```

---

## 🔄 Development Workflow

### Adding a new page
1. Create `lib/app/<feature>/<name>_page.dart`
2. Run `dart run routefly` to regenerate routes
3. Navigate with `Routefly.navigate(routePaths.<feature>.<name>)`

### Adding a new feature module
1. Create `lib/src/modules/<feature>/`
2. Add: `models/`, `repositories/` (interface + impl), `stores/<feature>_store.dart`, `<feature>_binding.dart`
3. Register bindings in `root_biding.dart` inside `registerXBindings(i)`
4. Add module accessor: `late final AutoInjector xModule;`

### Adding a new store command
1. Declare `late final RxCommand<T> myCommand = RxCommand<T>();` in the Store
2. Write `Future<void> myAction(args) async { await myCommand.execute(() async { ... }); }`
3. In the page: `store.myCommand.addListener(_onMyCommand)` in `initState`, remove in `dispose`

---

## 🧪 Testing

- **Unit tests**: test Store logic with mocked repositories
- **Widget tests**: test UI with mocked Stores / fake commands
- Run tests: `flutter test`

---

## 🔍 Useful References

- [ARCHITECTURE.md](./ARCHITECTURE.md) — full architecture deep-dive
- [Routefly docs](https://pub.dev/packages/routefly)
- [auto_injector docs](https://pub.dev/packages/auto_injector)
- [Drift docs](https://drift.simonbinder.eu/)
- [Dio docs](https://pub.dev/packages/dio)
- [Material Design 3](https://m3.material.io/)
