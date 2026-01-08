# AI Development Rules - TODO Vaden Backend

**Development guidelines for AI-assisted coding in the TODO Vaden Backend in Dart**

> 📋 **Reference**: For detailed Vaden framework patterns, see [ARCHITECTURE.md](./ARCHITECTURE.md)
> 📋 **Implementation**: For Clean Architecture implementation, see [vaden.md](./vaden.md)
> 📋 **Development**: For step-by-step feature implementation, see [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)

## Project Context

**TODO Backend - Vaden Dart** is a REST API for task management using the **Vaden Framework** following **Clean Architecture** principles. This is part of a multi-language TODO study project demonstrating the same application in different languages and frameworks.

### Features
- User registration and JWT authentication
- Task management (CRUD) with pagination and filters
- Role-based access control (admin, user)
- PostgreSQL database with soft deletes
- Automatic OpenAPI/Swagger documentation
- Modular dependency injection

## 🚫 Prohibited Patterns

### Architecture Violations
- **NEVER** expose database entities directly in controllers - always use DTOs
- **NEVER** implement business logic in controllers - use Services or UseCases
- **NEVER** create repositories without interfaces
- **NEVER** use hard-coded database queries without adapters
- **NEVER** mix data layer with presentation layer
- **NEVER** import data layer directly from controllers

### Code Violations
- **NEVER** use `print()` - use proper logging
- **NEVER** store passwords in plain text - always hash with bcrypt
- **NEVER** skip error handling - catch and convert to domain exceptions
- **NEVER** use magical numbers - use named constants or configuration
- **NEVER** commit sensitive data (.env, secrets)
- **NEVER** leave TODO comments without context

### DTO Violations
- **NEVER** expose database entities in API responses
- **NEVER** include passwords in Profile/Response DTOs
- **NEVER** create DTOs without proper validation
- **NEVER** mix input DTOs (CreateRequest) with output DTOs (Profile)

### Database Violations
- **NEVER** delete records directly - use soft delete with `deletedAt`
- **NEVER** skip timestamp fields (`createdAt`, `updatedAt`, `deletedAt`)
- **NEVER** create tables without proper indexes on frequently queried fields
- **NEVER** expose raw database queries to business logic

### Security Violations
- **NEVER** trust user input - always validate and sanitize
- **NEVER** expose detailed error messages to users
- **NEVER** commit API keys or secrets
- **NEVER** skip authorization checks
- **NEVER** allow SQL injection via query parameters

## ✅ Required Patterns

### Layered Architecture Rules

#### Domain Layer (lib/src/domain/)
- **ALWAYS** define entities in `domain/entities/`
- **ALWAYS** create repository interfaces in `domain/repositories/`
- **ALWAYS** define exceptions in `domain/errors/`
- **ALWAYS** use enums for domain constants in `domain/enums/`
- **ALWAYS** keep domain layer independent of frameworks
- **NEVER** import anything from data, controllers, or config layers

#### Data Layer (lib/src/data/)
- **ALWAYS** implement repositories in `data/repositories/`
- **ALWAYS** implement repository interfaces from domain
- **ALWAYS** convert database entities to domain entities using `_mapTo*` methods
- **ALWAYS** handle database exceptions and convert to domain exceptions
- **ALWAYS** use soft delete by checking `deletedAt.isNull()`
- **NEVER** return database entities directly - always return DTOs or domain entities

#### Controllers Layer (lib/src/controllers/)
- **ALWAYS** use `@Controller()` and `@Api()` annotations
- **ALWAYS** inject repository interfaces (not implementations)
- **ALWAYS** validate input using DTOs with `@Body()`
- **ALWAYS** use descriptive parameter names for Request objects (e.g., `listUsersRequest`, `createTodoRequest`)
- **NEVER** use generic names like `request` for Request parameters
- **ALWAYS** handle all HTTP methods properly
- **ALWAYS** return appropriate HTTP status codes
- **ALWAYS** document endpoints with `@ApiOperation()` and `@ApiResponse()`
- **NEVER** implement business logic - delegate to services/repositories

#### Configuration Layer (lib/config/)
- **ALWAYS** use `@Configuration()` and `@Bean()` for dependency setup
- **ALWAYS** register all repositories, services, and controllers
- **ALWAYS** configure security and middleware
- **ALWAYS** separate concerns by configuration type (Postgres, Security, OpenAPI, etc.)
- **NEVER** hard-code configuration values

### DTO Patterns
- **ALWAYS** create specific DTOs for each use case:
  - `UserProfile` - For GET responses (no passwords)
  - `CreateUserRequest` - For POST requests
  - `UpdateUserRequest` - For PUT requests (optional fields)
- **ALWAYS** use `@DTO()` annotation for automatic serialization
- **ALWAYS** document DTO fields with comments
- **ALWAYS** validate required vs optional fields
- **NEVER** reuse the same DTO for different purposes

### Repository Patterns
- **ALWAYS** implement methods that return DTOs, never raw database records
- **ALWAYS** create private `_mapTo*` methods for data conversion
- **ALWAYS** handle all database exceptions gracefully
- **ALWAYS** use parameterized queries to prevent SQL injection
- **ALWAYS** implement soft delete correctly:
  ```dart
  Future<List<UserProfile>> findAll() async {
    final query = _database.select(_database.users)
      ..where((u) => u.deletedAt.isNull());
    final users = await query.get();
    return users.map(_mapToUserProfile).toList();
  }
  ```

### Error Handling Rules
- **ALWAYS** catch database exceptions in repositories
- **ALWAYS** convert to domain exceptions
- **ALWAYS** provide meaningful error messages
- **ALWAYS** log errors with context
- **NEVER** expose internal error details to clients

### Testing Rules
- **ALWAYS** write unit tests for repositories
- **ALWAYS** mock database interactions
- **ALWAYS** test all error scenarios
- **ALWAYS** use `mocktail` for mocking
- **MINIMUM** coverage: 80%

## 📋 Code Organization

### File Naming Conventions
- Entities: `user.dart` (singular)
- Repositories: `user_repository.dart` (interface), `user_repository_impl.dart` (implementation)
- DTOs: `user_profile.dart`, `create_user_request.dart`
- Controllers: `user_controller.dart`
- Services: `user_service.dart`
- Configuration: `user_configuration.dart`

### Class Naming Conventions
- Entities: `PascalCase` (e.g., `User`, `Todo`)
- Interfaces: `UserRepository` (no suffix)
- Implementations: `UserRepositoryImpl` (suffix `Impl`)
- DTOs: `UserProfile`, `CreateUserRequest` (suffix `Profile`/`Request`/`Response`)
- Exceptions: `UserNotFoundException` (suffix `Exception`)
- Services: `UserService`
- Controllers: `UserController`

### Method Organization in Classes
1. Constructors
2. Public methods
3. Private methods
4. Mapping/conversion methods

## 🚀 Development Workflow

### Creating a New Feature

**Step 1: Domain Layer**
- Create entity in `lib/src/domain/entities/todo.dart`
- Define repository interface in `lib/src/domain/repositories/todo_repository.dart`
- Create exceptions if needed in `lib/src/domain/errors/`

**Step 2: DTOs**
- Create `TodoProfile` for GET responses
- Create `CreateTodoRequest` for POST
- Create `UpdateTodoRequest` for PUT (optional fields)

**Step 3: Data Layer**
- Implement repository in `lib/src/data/repositories/todo_repository_impl.dart`
- Implement all interface methods
- Create `_mapToTodoProfile()` conversion method
- Handle all exceptions

**Step 4: Controllers**
- Create `TodoController` in `lib/src/controllers/`
- Define all HTTP endpoints
- Add documentation with `@ApiOperation()` and `@ApiResponse()`
- Validate input with DTOs

**Step 5: Configuration**
- Register repository in `lib/config/app_configuration.dart` or specific configuration file
- Ensure dependency injection is configured

**Step 6: Database**
- Create migration SQL file in `migrations/`
- Include all necessary fields (id, createdAt, updatedAt, deletedAt)

**Step 7: Testing**
- Write unit tests for repository
- Mock database interactions
- Test all error paths

**Step 8: Documentation**
- Update API docs with new endpoints
- Document DTOs and validation rules
- Update architecture diagrams if needed

## 🔐 Security Requirements

### Authentication
- JWT tokens with HS256 algorithm
- Token expiration: 72 hours (configurable)
- Payload includes `user_id` and `exp`

### Authorization
- Public routes: `/auth/**`
- Protected routes: Require `Authorization: Bearer <token>`
- Role-based access control via user roles

### Password Management
- Hash with bcrypt (cost: 10)
- Never store plain text passwords
- Never return passwords in API responses

### Input Validation
- Validate all user input
- Use DTOs with proper types
- Sanitize strings to prevent injection
- Validate email format
- Check password strength

## 🗄️ Database Patterns

### Soft Delete
```dart
// In table definition
late final deletedAt = dateTime().nullable()();

// In queries
..where((e) => e.deletedAt.isNull())

// In delete method
await (_database.update(_database.tableName)
  ..where((e) => e.id.equals(id)))
  .write(TableNameCompanion(deletedAt: Value(DateTime.now())));
```

### Pagination
```dart
Future<PaginatedResponse<UserProfile>> findPaginated(int page, int limit) async {
  final query = _database.select(_database.users)
    ..where((u) => u.deletedAt.isNull())
    ..limit(limit, offset: (page - 1) * limit);
  final users = await query.get();
  final total = await _countTotal();
  return PaginatedResponse(
    data: users.map(_mapToUserProfile).toList(),
    total: total,
    page: page,
    limit: limit,
  );
}
```

## 📊 API Response Structure

### Success Response
```json
{
  "data": {...},
  "status": "success",
  "timestamp": "2024-01-08T10:30:00Z"
}
```

### Error Response
```json
{
  "error": "Meaningful error message",
  "code": "ERROR_CODE",
  "timestamp": "2024-01-08T10:30:00Z"
}
```

### Paginated Response
```json
{
  "data": [...],
  "page": 1,
  "limit": 10,
  "total": 50,
  "hasMore": true
}
```

## 🤖 Prompt Templates for AI

### To implement a new feature:
```
"Implement [FEATURE_NAME] in TODO Vaden Backend following patterns:
- Create domain entity and repository interface
- Create DTOs for CRUD operations (Profile, CreateRequest, UpdateRequest)
- Implement repository converting DB entities to DTOs
- Create controller with proper HTTP methods and documentation
- Add soft delete support
- Write unit tests with mocked database
- Create migration SQL file
- Follow Clean Architecture separation of concerns"
```

### For bug fixes:
```
"Fix [BUG_DESCRIPTION] in TODO Vaden Backend considering:
- Check repository layer for database errors
- Verify DTO conversions are correct
- Ensure soft delete logic is implemented
- Validate error handling and exception conversion
- Check authorization/authentication
- Verify input validation"
```

### For refactoring:
```
"Refactor [COMPONENT] following Vaden Clean Architecture:
- Separate domain, data, and presentation concerns
- Ensure DTOs are used for data transfer
- Repository interfaces in domain, implementations in data
- Controllers only for HTTP routing and validation
- All business logic in services or repositories"
```

## ✨ Best Practices

### Code Quality
- Use meaningful variable and method names
- Keep methods focused and small (max 30 lines)
- Avoid deep nesting (max 3 levels)
- Use const constructors where possible
- Document public APIs

### Error Handling
- Catch specific exceptions, not generic `Exception`
- Convert database exceptions to domain exceptions
- Provide context in error messages
- Log errors with full stack trace
- Return appropriate HTTP status codes

### Performance
- Use database indexes on frequently queried fields
- Implement pagination for large result sets
- Use soft delete instead of hard delete (maintains data integrity)
- Cache configuration values
- Use connection pooling

### Maintainability
- Follow consistent naming conventions
- Keep layers separated and independent
- Document architecture decisions
- Write tests alongside features
- Keep dependencies updated

## 🧪 Testing Checklist

For each feature, ensure:
- [ ] Unit tests for repository methods
- [ ] Error path tests (database failures, invalid data, etc.)
- [ ] Soft delete tests
- [ ] Pagination tests
- [ ] Authorization tests
- [ ] DTO serialization/deserialization tests
- [ ] API integration tests (if applicable)
- [ ] Error response format tests

## 📚 References

- [Vaden Framework Documentation](https://doc.vaden.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Dart Language Guide](https://dart.dev/guides)

---

*This document serves as the primary reference for AI-assisted development in the TODO Vaden Backend. Always consult this before implementing new features or making changes.*
