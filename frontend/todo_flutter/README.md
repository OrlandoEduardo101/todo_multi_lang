# Todo Flutter

Cross-platform Flutter frontend for the [`todo_multi_lang`](../../README.md) study project.

The app manages todos **offline-first** — writes go to a local SQLite database (via Drift) and a background sync engine pushes pending changes to a REST backend. Authentication uses JWT persisted locally. The UI targets mobile, tablet, and desktop through a responsive/adaptive layout system.

---

## Features

- JWT login and registration (session persisted locally)
- Create, complete, and delete todos
- Offline-first: all mutations are written locally first, then synced in the background
- Manual sync trigger
- Responsive layout: mobile, tablet, desktop breakpoints
- Dark theme with Material 3

---

## Architecture

```
Presentation (Pages + Stores)
    ↕  Commands (RxCommand / StreamRxCommand)
Domain (Models + Repository Interfaces)
    ↕  Either<AppException, T>
Data (Repository Implementations + TodoSyncService)
    ↕
Infrastructure (Drift/SQLite · Dio/HTTP · AuthInterceptor)
```

| Concern | Solution |
|---|---|
| State management | Custom `RxCommand<T>` + `ChangeNotifier` (no external package) |
| Navigation | `routefly` — file-based, auto-generated from `lib/app/` |
| Dependency injection | `auto_injector` — single root module |
| Local database | `drift` (SQLite) |
| HTTP client | `dio` behind an `HttpClient` interface |
| Error handling | Custom `Either<L, R>` sealed class |

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full deep-dive.

---

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/                         # Routed pages (Routefly scans here)
│   ├── app_widget.dart          # MaterialApp.router root
│   ├── splash_page.dart         # Auth guard / loading
│   ├── home/home_page.dart      # Todo list
│   └── auth/
│       ├── login/login_page.dart
│       └── register/register_page.dart
└── src/
    ├── root_biding.dart         # Single AutoInjector (AppModule)
    ├── modules/
    │   ├── auth/                # Login, register, session management
    │   └── todo/                # CRUD + offline sync
    └── shared/
        ├── database/            # Drift schema (Sessions + Todos)
        ├── either/              # Custom Either<L,R>
        ├── http/                # HttpClient, DioHttpClient, AuthInterceptor
        └── reactive_ui/         # RxCommand, StreamRxCommand, RxCommandBuilder
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.8.1`
- A running backend from `backend/` (or point `DioHttpClient.baseUrl` to any compatible server)

### Install dependencies

```sh
flutter pub get
```

### Generate code (Drift tables + Routefly routes)

```sh
dart run build_runner build --delete-conflicting-outputs
dart run routefly
```

### Run

```sh
flutter run
```

The app connects to `http://localhost:3000` by default. To change the base URL edit `DioHttpClient` in [lib/src/shared/http/dio_http_client.dart](lib/src/shared/http/dio_http_client.dart).

---

## Backend Compatibility

This app works with any of the three backends in this repo. Start one with Docker Compose:

```sh
cd ../../docker
docker compose up
```

See [backend/BACKENDS_OVERVIEW.md](../../backend/BACKENDS_OVERVIEW.md) for details.

---

## Documentation

| File | Content |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Full architecture, layer responsibilities, sequence diagrams |
| [docs/ai-notes.md](docs/ai-notes.md) | Coding rules and prohibited/required patterns for AI-assisted development |
| [docs/dependency-injector.md](docs/dependency-injector.md) | How `auto_injector` is set up and used |
| [docs/routes-navigation-system.md](docs/routes-navigation-system.md) | Routefly navigation guide |
| [docs/responsive-layout.md](docs/responsive-layout.md) | Responsive and adaptive layout standards |
| [docs/screen-componentization-ai-ready.md](docs/screen-componentization-ai-ready.md) | Widget componentization rules |
| [docs/theme-usage-guide.md](docs/theme-usage-guide.md) | Theme and color system usage |
| [docs/INDEX.md](docs/INDEX.md) | Docs index with reading guide |

---

## Key Dependencies

| Package | Role |
|---|---|
| `routefly ^3.1.3` | File-based navigation |
| `auto_injector ^2.1.1` | Dependency injection |
| `drift ^2.31.0` | Local SQLite ORM |
| `sqlite3_flutter_libs ^0.5.42` | SQLite native binaries |
| `dio ^5.9.2` | HTTP client |
| `path_provider ^2.1.5` | Device file path for DB |

---

## Development Guidelines

- Follow the rules in [docs/ai-notes.md](docs/ai-notes.md)
- Use `RxCommand` / `StreamRxCommand` for all async operations — no direct `setState` calls
- Subscribe to individual commands in the page (`addListener`) — never to the whole store
- Always run `dart run routefly` after adding or removing a `*_page.dart` file
- Use `theme.colorScheme.*` and `theme.textTheme.*` — never hardcoded colors or styles

