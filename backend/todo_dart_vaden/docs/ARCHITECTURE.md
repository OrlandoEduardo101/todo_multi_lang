# Vaden Architecture - TODO Backend

## Overview

This document outlines the **Clean Architecture** patterns used in the TODO Vaden Backend. The architecture follows Vaden framework conventions with clear separation of concerns across domain, data, and presentation layers.

### Architecture Diagram

```
HTTP Request
    ↓
Controllers (Presentation)
    ↓ (uses DTOs)
Services/Repositories (Business Logic & Data)
    ↓ (uses Domain Entities)
Domain Layer
    ↓ (accesses)
Database (PostgreSQL)
```

## Project Structure

```
lib/
├── config/                      # Configuration & setup
│   ├── app_configuration.dart   # Main app config
│   ├── postgres/               # Database setup
│   ├── security/               # JWT & auth config
│   └── openapi/                # Swagger/OpenAPI config
├── src/                        # Application code
│   ├── controllers/            # HTTP endpoints
│   │   ├── auth_controller.dart
│   │   ├── todo_controller.dart
│   │   └── user_controller.dart
│   ├── dto/                    # Data Transfer Objects
│   │   ├── auth_dto.dart
│   │   ├── todo_dto.dart
│   │   └── user_dto.dart
│   ├── repository/             # Data access layer
│   │   ├── auth_repository_impl.dart
│   │   ├── todo_repository_impl.dart
│   │   └── user_repository_impl.dart
│   ├── service/               # Business logic
│   │   └── auth_service.dart
│   └── domain/                # Core business logic (if needed)
│       ├── entities/
│       └── errors/
├── bin/
│   └── server.dart            # Entry point
└── pubspec.yaml               # Dependencies
```

## Layer Responsibilities

### 1. Domain Layer (Business Logic)

The domain layer contains core business rules independent of any framework.

**Files:**
- `src/domain/entities/*.dart` - Core business objects
- `src/domain/errors/*.dart` - Domain-specific exceptions
- `src/domain/repositories/*.dart` - Repository interfaces (optional)

### 2. Data Layer (Repositories & DTOs)

Handles all data persistence and transformation.

**DTOs (Data Transfer Objects):**
- Transfer data between layers
- Handle JSON serialization
- Validate input data
- Never expose database entities

**DTO Patterns:**
- `UserProfile` - For GET responses (excludes sensitive fields)
- `CreateUserRequest` - For POST requests
- `UpdateUserRequest` - For PUT requests (optional fields)

**Repository Responsibilities:**
- Implement repository interfaces
- Convert between database records and domain entities
- Handle database exceptions
- Implement soft delete logic
- Use `_mapTo*` methods for conversions

### 3. Controllers Layer (HTTP Endpoints)

Handles HTTP requests and responses.

**Responsibilities:**
- Parse HTTP requests
- Validate input data using DTOs
- Call appropriate services/repositories
- Return DTOs (never entities)
- Document with OpenAPI annotations
- Handle HTTP status codes

### 4. Services Layer (Optional)

For complex business logic that spans multiple repositories.

**When to use:**
- Multiple repository operations needed
- Complex transformations
- Orchestration logic

## Database Patterns

### Soft Delete Pattern

All entities support soft delete to maintain data integrity:

```dart
// Table definition
class UsersTable extends Table {
  late final id = integer().autoIncrement()();
  late final email = text().unique()();
  // ... other fields ...
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
  late final deletedAt = dateTime().nullable()();
}

// Repository query
Future<List<UserProfile>> findAll() async {
  final query = _database.select(_database.users)
    ..where((u) => u.deletedAt.isNull());
  return (await query.get()).map(_mapToUserProfile).toList();
}

// Soft delete
Future<bool> delete(int id) async {
  final updated = await (_database.update(_database.users)
        ..where((u) => u.id.equals(id)))
      .write(UsersCompanion(deletedAt: Value(DateTime.now())));
  return updated > 0;
}
```

### Pagination Pattern

Implemented with page, limit, total, and hasMore:

```dart
@DTO()
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  PaginatedResponse({...});
}
```

## Dependency Injection

Uses Vaden's built-in DI with annotations

## Error Handling

Domain exceptions are caught and converted to HTTP responses

## Security

### JWT Authentication
- Algorithm: HS256
- Expiration: 72 hours (configurable)
- Payload includes `user_id` and `exp`

### Authorization
- Public routes: `/auth/**`
- Protected routes: Require Bearer token
- Role-based access control

### Password Management
- Hash with bcrypt (cost: 10)
- Never store plain text passwords
- Never return passwords in API responses

## Endpoints Summary

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token

### Users
- `GET /api/users` - List all users (paginated)
- `POST /api/users` - Create new user
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Soft delete user
- `GET /api/me` - Get current user (authenticated)

### Todos
- `GET /api/todos` - List todos with filters and pagination
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get todo by ID
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Soft delete todo

### Documentation
- `GET /docs/swagger` - Swagger UI
- `GET /docs/openapi.json` - OpenAPI spec

---

For step-by-step feature implementation, see [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
For AI development guidelines, see [AI-NOTES.md](./AI-NOTES.md)
For Vaden framework patterns, see [vaden.md](./vaden.md)
