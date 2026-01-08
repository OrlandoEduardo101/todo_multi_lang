# Vaden Framework Documentation

This document describes the architecture and implementation patterns of the Vaden framework used in the backend application of Meu Doutor.

## Overview

Vaden is a web framework for Dart that follows the principles of **Clean Architecture** and **Dependency Injection**, offering an organized structure for developing REST APIs with full support for PostgreSQL through the Drift ORM.

### Key Features

- **Annotation-Based Architecture**: Controllers, DTOs, Services, and Repositories are defined using decorators
- **Automatic Dependency Injection**: Integrated IoC container with automatic class scanning
- **Automatic Serialization**: DTOs with automatic JSON serialization (fromJson/toJson)
- **Integration with Drift**: Robust ORM for PostgreSQL
- **Integrated Security**: Authentication and authorization module
- **OpenAPI/Swagger**: Automatic API documentation
- **Entity Protection**: DTOs serve as the external interface, keeping database entities protected

## Project Structure

```
backend/
├── lib/
│   ├── config/               # Application configurations
│   │   ├── drift/           # Database configuration
│   │   ├── openapi/         # Documentation configuration
│   │   ├── resources/       # Static resources
│   │   └── security/        # Security configurations
│   └── src/                 # Application source code
│       ├── controller/      # REST Controllers
│       ├── dto/            # Data Transfer Objects
│       ├── repository/     # Data Repositories
│       └── service/        # Business Services
├── bin/
│   └── server.dart         # Application entry point
└── pubspec.yaml            # Project dependencies
```

## Main Dependencies

```yaml
dependencies:
  vaden: ^0.1.3                 # Main framework
  vaden_security: ^0.0.8        # Security module
  drift: ^2.28.1                # ORM for PostgreSQL
  drift_postgres: ^1.3.1        # PostgreSQL driver for Drift
  postgres: ^3.5.6              # PostgreSQL client

dev_dependencies:
  vaden_class_scanner: ^0.1.3   # Class scanner for DI
  drift_dev: 2.28.0             # Drift code generator
  build_runner: ^2.4.14        # Code generator
```

## Layered Architecture

### 1. Controllers (Presentation Layer)

Controllers are responsible for receiving HTTP requests, validating input data, and returning responses. They **SHOULD NEVER** expose database entities directly, only DTOs.

```dart
@Api(tag: 'Users', description: 'User Management Controller')
@Controller('/api/users')
class UserController {
  final UserRepository _userRepository;

  UserController(this._userRepository);

  @Get('/')
  Future<Response> getAllUsers(Request getUsersRequest) async {
    final users = await _userRepository.findAll();
    return Response.ok(
      jsonEncode(users.map((u) => u.toJson()).toList()),
      headers: {'content-type': 'application/json'},
    );
  }

  @Post('/')
  Future<Response> createUser(
    Request createUserRequest,
    @Body() CreateUserRequest requestDto,
  ) async {
    final user = await _userRepository.create(requestDto);
    return Response(
      201,
      body: jsonEncode(user.toJson()),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

**Available Annotations:**
- `@Controller('/path')`: Defines the controller and base route
- `@Api(tag: 'Name', description: 'Description')`: Metadata for OpenAPI
- `@Get('/')`, `@Post('/')`, `@Put('/')`, `@Delete('/')`: HTTP methods
- `@Param()`: URL parameters
- `@Body()`: Request body
- `@Query()`: Query parameters

**Important Notes:**
- Controller methods must always return `Future<Response>` from the Shelf package
- Never return DTOs directly - always wrap them in Response objects with proper HTTP status codes
- Always use descriptive parameter names for Request objects (e.g., `getUserRequest`, not `request`)
- Use `jsonEncode()` to serialize DTOs to JSON in the response body
- Set `content-type: application/json` header for JSON responses

### 2. DTOs (Data Transfer Objects)

DTOs are responsible for transferring data between the layers of the application and ensure that the database entities remain protected. They have automatic JSON serialization.

```dart
@DTO()
class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });
}

@DTO()
class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String role;

  const CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
  });
}
```

**DTO Patterns:**
- **Profile**: DTOs for reading (GET), exclude sensitive fields
- **Details**: DTOs with complete information, including passwords (internal use)
- **CreateRequest**: DTOs for creating resources
- **UpdateRequest**: DTOs for updating (optional fields)
- **Response**: DTOs for specific responses (e.g., AuthResponse)

### 3. Repositories (Data Layer)

Repositories are responsible for interacting with the database through Drift. They convert between database entities and DTOs.

```dart
@Repository()
class UserRepository {
  final AppDatabase _database;
  final PasswordEncoder _passwordEncoder;

  UserRepository(this._database, this._passwordEncoder);

  Future<List<UserProfile>> findAll() async {
    final query = _database.select(_database.users)
      ..where((u) => u.deletedAt.isNull());
    final users = await query.get();
    return users.map(_mapToUserProfile).toList();
  }

  Future<UserProfile> create(CreateUserRequest request) async {
    final user = await _database
        .into(_database.users)
        .insertReturning(
          UsersCompanion.insert(
            name: request.name,
            email: request.email,
            password: _passwordEncoder.encode(request.password),
            phone: Value.absentIfNull(request.phone),
            role: Value(request.role),
          ),
        );
    return _mapToUserProfile(user);
  }

  // Private mapping methods
  UserProfile _mapToUserProfile(User user) {
    return UserProfile(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      isActive: user.isActive,
      role: user.role,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }
}
```

**Repository Patterns:**
- Methods always return DTOs, never database entities
- Implement soft delete by checking `deletedAt.isNull()`
- Use `_mapTo*` methods to convert entities to DTOs
- Encrypt passwords before persisting

### 4. Services (Business Logic Layer)

Services contain complex business logic and can orchestrate multiple repositories.

```dart
@Service()
class DashboardService {
  final AppDatabase _database;
  final UserRepository _userRepository;
  final MachineRepository _machineRepository;

  DashboardService(
    this._database,
    this._userRepository,
    this._machineRepository,
  );

  Future<DashboardResponse> getCardsData(DashboardFilters filters) async {
    final cards = <DashboardCardData>[];

    // Complex business logic
    final totalMachines = await _getTotalMachines(filters);
    final activeUsers = await _userRepository.findActive();

    return DashboardResponse(cards: cards);
  }
}
```

## Database Configuration (Drift)

### Table Definition (Entities)

Tables are defined as classes that extend `Table`:

```dart
class TestEntity extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final email = text().unique()();
  late final emailVerifiedAt = dateTime().nullable()();
  late final password = text()();
  late final phone = text().nullable()();
  late final isActive = boolean().withDefault(const Constant(true))();
  late final role = text().withDefault(const Constant('franchise'))();
  late final photo = text().nullable()();
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
  late final deletedAt = dateTime().nullable()(); // Soft delete
}
```

### Database Configuration

```dart
@DriftDatabase(tables: [TestEntity])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

@Configuration()
class DriftConfiguration {
  @Bean()
  AppDatabase createAppDatabase(QueryExecutor queryExecutor) {
    return AppDatabase(queryExecutor);
  }

  @Bean()
  QueryExecutor createQueryExecutor(ApplicationSettings applicationService) {
    return PgDatabase(
      settings: pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      endpoint: pg.Endpoint(
        host: applicationService['database']['host'],
        database: applicationService['database']['database'],
        username: applicationService['database']['username'],
        password: applicationService['database']['password'],
      ),
    );
  }
}
```

## Dependency Injection

Vaden uses an IoC container that automatically scans classes with annotations:

```dart
@VadenModule([VadenSecurity])
class AppModule {}
```

**DI Annotations:**
- `@Controller()`: Registers controllers
- `@Repository()`: Registers repositories
- `@Service()`: Registers services
- `@Configuration()`: Configuration classes
- `@Bean()`: Methods that produce beans

## Security

The `vaden_security` module provides:

- **JWT Authentication**: Login/logout with tokens
- **Authorization**: Access control by roles
- **Password Encryption**: Automatic encoder
- **UserDetailsService**: User loading

```dart
@DTO()
class LoginCredentials {
  final String email;
  final String password;

  const LoginCredentials({required this.email, required this.password});
}

@DTO()
class AuthResponse {
  final String token;
  final UserProfile user;

  const AuthResponse({required this.token, required this.user});
}
```

## Implementation Patterns

### 1. Creating a New Feature

To implement a new feature (e.g., `Product`):

1. **Create the Table** in `lib/config/drift/drift_configuration.dart`:
```dart
class ProductEntity extends Table {
  late final id = integer().autoIncrement()();
  late final name = text()();
  late final price = real()();
  late final createdAt = dateTime().clientDefault(DateTime.now)();
  late final updatedAt = dateTime().clientDefault(DateTime.now)();
  late final deletedAt = dateTime().nullable()();
}
```

2. **Create DTOs** in `lib/src/dto/product_dto.dart`:
```dart
@DTO()
class ProductProfile {
  final int id;
  final String name;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductProfile({...});
}

@DTO()
class CreateProductRequest {
  final String name;
  final double price;

  const CreateProductRequest({...});
}

@DTO()
class UpdateProductRequest {
  final String? name;
  final double? price;

  const UpdateProductRequest({...});
}
```

3. **Create Repository** in `lib/src/repository/product_repository.dart`:
```dart
@Repository()
class ProductRepository {
  final AppDatabase _database;

  ProductRepository(this._database);

  Future<List<ProductProfile>> findAll() async {
    // Implementation
  }

  Future<ProductProfile> create(CreateProductRequest request) async {
    // Implementation
  }
}
```

4. **Create Controller** in `lib/src/controller/product_controller.dart`:
```dart
@Api(tag: 'Products', description: 'Product Management')
@Controller('/api/products')
class ProductController {
  final ProductRepository _repository;

  ProductController(this._repository);

  @Get('/')
  Future<Response> getAll(Request getAllProductsRequest) async {
    final products = await _repository.findAll();
    return Response.ok(
      jsonEncode(products.map((p) => p.toJson()).toList()),
      headers: {'content-type': 'application/json'},
    );
  }
}
```

### 2. Soft Delete Pattern

All tables should implement soft delete:

```dart
// In the table
late final deletedAt = dateTime().nullable()();

// In the repository
Future<List<Entity>> findAll() async {
  final query = _database.select(_database.tableName)
    ..where((e) => e.deletedAt.isNull());
  return await query.get();
}

Future<bool> delete(int id) async {
  final updated = await (_database.update(_database.tableName)
    ..where((e) => e.id.equals(id)))
    .write(TableNameCompanion(deletedAt: Value(DateTime.now())));
  return updated > 0;
}
```

### 3. Pagination

To implement pagination:

```dart
@DTO()
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;

  const PaginatedResponse({...});
}

Future<PaginatedResponse<ProductProfile>> findPaginated(int page, int limit) async {
  final query = _database.select(_database.products)
    ..where((p) => p.deletedAt.isNull())
    ..limit(limit, offset: (page - 1) * limit);

  final products = await query.get();
  final total = await _countTotal();

  return PaginatedResponse(
    data: products.map(_mapToProfile).toList(),
    total: total,
    page: page,
    limit: limit,
  );
}
```

## Development Commands

### Generate Drift Code
```bash
dart run build_runner build
```

### Run Application
```bash
dart run bin/server.dart
```

### Run in Watch Mode
```bash
dart run build_runner watch
```

## Example File Structure

For each domain entity, follow this structure:

```
src/
├── controller/
│   └── entity_controller.dart    # REST endpoints
├── dto/
│   └── entity_dto.dart          # DTOs (Profile, Request, Response)
├── repository/
│   └── entity_repository.dart   # Data access
└── service/
    └── entity_service.dart      # Business logic (optional)
```

## Important Notes

1. **Never expose database entities**: Always use DTOs in controllers
2. **Soft Delete**: Implement in all tables
3. **Validation**: DTOs are automatically validated
4. **Encryption**: Passwords are always encrypted in repositories
5. **Dependency Injection**: All classes must use DI
6. **OpenAPI**: Documentation is automatically generated from controllers

This framework provides a solid foundation for developing REST APIs in Dart with PostgreSQL, following clean architecture patterns and good development practices.
