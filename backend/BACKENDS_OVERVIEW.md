# TODO Multi-Language Backends

## 📚 Overview

This document provides a high-level overview of all backend implementations in the **TODO Multi-Language Study Project**. The same TODO application has been implemented in multiple languages and frameworks to compare architectures, patterns, and development approaches.

---

## 🎯 Project Objective

To demonstrate the implementation of the same application across different technology stacks, comparing:

- **Architecture patterns** (Clean Architecture, Hexagonal, MVC)
- **Language paradigms** (Go, Java, Dart)
- **Framework capabilities** (Fiber, Spring Boot, Vaden)
- **Development experience** (ease of use, productivity, scalability)
- **Performance characteristics** (speed, memory usage, concurrency)
- **Code organization** (structure, maintainability, testability)

---

## 🌍 Implemented Backends

### 1. **Go Fiber** ✅ (COMPLETE)
📁 `/backend/todo_go_fiber/`

**Stack:**
- Language: Go 1.24.3
- Framework: Fiber v2.52.8
- Database: PostgreSQL
- Auth: JWT with golang-jwt
- Password: bcrypt

**Architecture:**
- RESTful API
- Internal package structure
- Repository pattern (implicit)
- Middleware-based auth
- Swagger documentation with swag

**Features:**
- ✅ User registration & JWT login
- ✅ Todo CRUD with pagination and filters
- ✅ Advanced filtering (search, completed status)
- ✅ Advanced sorting (by field and direction)
- ✅ Role-based access control
- ✅ Soft delete
- ✅ OpenAPI/Swagger documentation
- ✅ Docker support

**Performance:**
- High concurrency handling
- Low memory footprint
- Fast request processing
- Optimized routing with radix tree

**Key Files:**
- `main.go` - Entry point
- `internal/handlers/` - HTTP request handlers
- `internal/routes/` - Route definitions
- `internal/middlewares/` - Auth middleware
- `internal/models/` - Data models
- `internal/database/` - Database initialization
- `docs/` - Swagger files (auto-generated)

---

### 2. **Java Spring Boot** 🔄 (IN PROGRESS)
📁 `/backend/todo_java_spring/`

**Stack:**
- Language: Java 17+
- Framework: Spring Boot 3.x
- Build: Maven
- Database: PostgreSQL
- Auth: Spring Security + JWT

**Architecture:**
- Layered architecture (Controller → Service → Repository)
- Dependency injection with Spring IoC
- Transaction management
- AOP for cross-cutting concerns

**Status:**
- Project structure setup
- Base configurations in place
- User registration started

**Planned Features:**
- ⏳ User authentication with JWT
- ⏳ Todo CRUD operations
- ⏳ Advanced filtering and pagination
- ⏳ Exception handling
- ⏳ Swagger/OpenAPI docs
- ⏳ Docker support

**Key Directories:**
- `src/main/java/com/todo/` - Application code
- `src/main/resources/` - Configuration files
- `pom.xml` - Maven dependencies

---

### 3. **Dart Vaden** � (IN PROGRESS)
📁 `/backend/todo_dart_vaden/`

**Stack:**
- Language: Dart 3.10.4
- Framework: Vaden v3.0.0
- Database: PostgreSQL
- ORM: Drift (drift_postgres)
- Auth: VadenSecurity (JWT)
- Password: BCryptPasswordEncoder (cost=10)

**Architecture:**
- Clean Architecture (Domain → Data → Controllers)
- Annotation-based (Controllers, DTOs, Repositories, Services)
- Automatic dependency injection (auto-injector)
- Drift ORM for type-safe queries
- VadenSecurity integration
- Code generation with build_runner

**Features:**
- ✅ User registration with password hashing
- ✅ JWT authentication (Basic Auth → JWT)
- ✅ VadenSecurity UserDetailsService integration
- ✅ Custom authentication endpoints (POST /auth/register, POST /auth/login)
- ✅ Password encoding/verification with BCrypt
- ✅ Exception handling with proper HTTP status codes
- ✅ CORS middleware
- ✅ OpenAPI/Swagger documentation
- ✅ Docker support
- ✅ Todo CRUD operations (create, read, update, delete)
- ✅ Advanced filtering and pagination (search, completed status, sorting)
- 🏗️ Unit and integration tests

**Architecture Layers:**
- `lib/config/` - Configuration (Database, Security, DI)
- `lib/src/controllers/` - HTTP endpoints (AuthController, TodoController, UserController)
- `lib/src/dto/` - Data Transfer Objects with @DTO annotation
- `lib/src/domain/repositories/` - Repository interfaces
- `lib/src/data/repositories/` - Repository implementations
- `lib/src/services/` - Business logic (UserDetailsServiceImpl)
- `lib/src/domain/entities/` - Drift database entities
- `lib/vaden_application.dart` - Generated aggregator (routes, DI, exception handling)
- `application.yaml` - Configuration with environment variables

**Key Advantages:**
- Type-safe with strong null safety
- Fast compilation and hot reload
- Excellent code generation capabilities
- Easy to learn for Flutter developers
- Clean separation of concerns
- Automatic API documentation generation
- Strong community support

**Authentication Flow:**
1. User registers via POST /auth/register → password hashed with BCrypt
2. User logs in via GET /auth/login (Basic Auth) or POST /auth/login (JSON)
3. VadenSecurity validates credentials via UserDetailsServiceImpl
4. BCrypt verifies password hash
5. JWT token returned to client
6. Protected endpoints require JWT in Authorization header

**Recent Fixes:**
- Fixed double-encoding password bug (register was hashing twice)
- Fixed exception handling to return correct HTTP status codes (401, 403, etc.) instead of always 500
- Fixed type mismatch between CustomUserDetails and UserProfile in context injection
- Enhanced CustomUserDetails with full user information for context propagation

---

## 📊 Feature Comparison

| Feature | Go Fiber | Java Spring | Dart Vaden |
|---------|----------|------------|-----------|
| **User Registration** | ✅ | 🔄 | ✅ |
| **JWT Login** | ✅ | 🔄 | ✅ |
| **Todo CRUD** | ✅ | 🔄 | ✅ |
| **Pagination** | ✅ | 🔄 | ✅ |
| **Filtering** | ✅ | 🔄 | ✅ |
| **Sorting** | ✅ | 🔄 | ✅ |
| **Soft Delete** | ✅ | 🔄 | ✅ |
| **Role-Based Access** | ✅ | 🔄 | ✅ |
| **OpenAPI Docs** | ✅ | 🔄 | ✅ |
| **Docker Support** | ✅ | 🔄 | ✅ |
| **Unit Tests** | 🔄 | 🔄 | 🏗️ |
| **Integration Tests** | 🔄 | 🔄 | 🏗️ |

---

## 🗄️ Database Schema

All backends use the same PostgreSQL schema:

### `users` Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL (bcrypt hash),
  roles TEXT[] DEFAULT ARRAY['user'],
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);
```

### `todos` Table
```sql
CREATE TABLE todos (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);
```

---

## 🔐 API Endpoints (Standardized)

All backends implement the same API specification:

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Authenticate and get JWT token

### Users
- `GET /api/users` - List all users (paginated)
- `POST /api/users` - Create new user
- `GET /api/users/:id` - Get user by ID
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Soft delete user
- `GET /api/me` - Get current user (authenticated)

### Todos
- `GET /api/todos` - List todos with filtering/pagination
- `POST /api/todos` - Create new todo
- `GET /api/todos/:id` - Get todo by ID
- `PUT /api/todos/:id` - Update todo
- `DELETE /api/todos/:id` - Soft delete todo

### Documentation
- `GET /docs/swagger` or `/docs/` - Swagger UI
- `GET /docs/openapi.json` - OpenAPI specification

---

## 🏗️ Shared Database

All backends connect to the same PostgreSQL database, enabling:

- **Cross-backend testing** - Test data consistency
- **API comparison** - Same operations in different frameworks
- **Load testing** - Compare performance under load
- **Migration testing** - Test DB schema changes across stacks

**Connection String Pattern:**
```
postgresql://postgres:postgres@localhost:5432/todo_db
```

---

## 🚀 Running All Backends

### Prerequisites
- Docker & Docker Compose
- PostgreSQL 12+
- Go 1.24+
- Java 17+
- Dart 3.0+

### Quick Start (Docker Compose)
```bash
cd backend
docker-compose up -d

# Backends will be available at:
# Go Fiber: http://localhost:3000
# Java Spring: http://localhost:8081
# Dart Vaden: http://localhost:8080
```

### Individual Setup

**Go Fiber:**
```bash
cd backend/todo_go_fiber
go run main.go
# Runs on http://localhost:3000
```

**Java Spring Boot:**
```bash
cd backend/todo_java_spring
mvn spring-boot:run
# Runs on http://localhost:8081
```

**Dart Vaden:**
```bash
cd backend/todo_dart_vaden
dart pub get
dart run bin/server.dart
# Runs on http://localhost:8080
```

---

## 📚 Documentation Structure

Each backend has its own documentation:

### Go Fiber
- `README.md` - Quick start guide
- `docs/STRUCTURE.md` - Project organization

### Java Spring Boot
- `HELP.md` - Spring Boot documentation
- `README.md` - Setup instructions

### Dart Vaden
- `README.md` - Quick start guide
- `docs/ARCHITECTURE.md` - Clean Architecture patterns
- `docs/DEVELOPMENT_GUIDE.md` - How to add features
- `docs/AI-NOTES.md` - AI development guidelines
- `docs/vaden.md` - Vaden framework reference

---

## 🔬 Learning Outcomes

By studying these implementations, you'll understand:

1. **Architecture Patterns**
   - How different frameworks enforce architecture
   - Trade-offs between opinionated vs flexible frameworks
   - Organizing code across languages

2. **Language Features**
   - Go's simplicity and performance
   - Java's mature ecosystem and type system
   - Dart's null safety and strong typing

3. **Framework Differences**
   - Fiber's minimalist approach
   - Spring's comprehensive ecosystem
   - Vaden's developer experience and code generation

4. **Best Practices**
   - Authentication strategies
   - Error handling patterns
   - Database access patterns
   - Testing approaches

5. **Performance Considerations**
   - Request handling speed
   - Memory usage patterns
   - Concurrency models
   - Startup time

---

## 🛣️ Development Status

```
✅ = Production Ready
🔄 = In Development
🏗️ = Planned
```

| Milestone | Go Fiber | Java Spring | Dart Vaden |
|-----------|----------|------------|-----------|
| Basic Setup | ✅ | ✅ | ✅ |
| Auth System | ✅ | 🔄 | ✅ |
| Todo CRUD | ✅ | 🔄 | ✅ |
| Advanced Features | ✅ | 🔄 | ✅ |
| Documentation | ✅ | 🔄 | ✅ |
| Tests | 🔄 | 🏗️ | 🏗️ |
| Deployment | ✅ | 🔄 | ✅ |

---

## 📖 Additional Resources

- [Go Fiber Documentation](https://docs.gofiber.io/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Vaden Documentation](https://doc.vaden.dev)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc7519)

---

## 🤝 Contributing

Each backend implementation follows its own patterns and conventions:

- **Go Fiber** - See `backend/todo_go_fiber/`
- **Java Spring** - See `backend/todo_java_spring/`
- **Dart Vaden** - See `backend/todo_dart_vaden/docs/AI-NOTES.md`

---

**Last Updated:** January 8, 2026
**Project Type:** Educational/Study Project
**License:** MIT
