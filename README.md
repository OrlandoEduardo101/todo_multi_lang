# 📱 TODO Multi-Language Project

A comprehensive study project demonstrating the implementation of the same TODO application across multiple languages and frameworks. This project serves as a learning resource for comparing architectures, patterns, and development approaches.

## 🎯 Project Objective

To build and compare the **same TODO application** in different technology stacks, exploring:

- How different languages approach the same problem
- Architecture patterns across frameworks
- Code organization and maintainability
- Performance characteristics
- Developer experience
- Learning and education value

## 📂 Project Structure

```
todo_multi_lang/
├── frontend/
│   └── todo_flutter/                 # Flutter mobile app
│       ├── lib/                       # Dart source code
│       ├── pubspec.yaml
│       └── README.md
├── backend/
│   ├── todo_go_fiber/               # Go + Fiber backend ✅
│   ├── todo_java_spring/            # Java + Spring Boot 🔄
│   ├── todo_dart_vaden/             # Dart + Vaden 🏗️
│   ├── docker-compose.yml           # All backends setup
│   └── init.sql                     # Database initialization
├── docs/
│   ├── BACKENDS_OVERVIEW.md         # Backend comparison
│   └── ARCHITECTURE.md              # Overall architecture
├── README.md                        # This file
└── todo_multi_lang.code-workspace  # VS Code workspace
```

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose (recommended)
- PostgreSQL 12+ (if running locally)
- Git

### Docker Setup (Recommended)

```bash
# Clone the repository
git clone <repo-url>
cd todo_multi_lang

# Start all services (PostgreSQL + all backends)
cd backend
docker-compose up -d

# Check services
docker-compose ps
```

**Services will be available at:**
- Go Fiber Backend: http://localhost:3000
- Java Spring Backend: http://localhost:8081
- Dart Vaden Backend: http://localhost:8080
- PostgreSQL: localhost:5432

### Local Setup

**Individual Backend Setup:**

**Go Fiber (✅ Complete)**
```bash
cd backend/todo_go_fiber
go run main.go
# http://localhost:3000
```

**Java Spring Boot (🔄 In Progress)**
```bash
cd backend/todo_java_spring
mvn spring-boot:run
# http://localhost:8081
```

**Dart Vaden (🏗️ Planned)**
```bash
cd backend/todo_dart_vaden
dart pub get
dart run bin/server.dart
# http://localhost:8080
```

**Flutter Frontend**
```bash
cd frontend/todo_flutter
flutter pub get
flutter run
```

---

## 📚 Backend Implementations

Cada backend implementa a mesma API REST com as mesmas funcionalidades, mas usando diferentes linguagens e frameworks. O objetivo é comparar abordagens, arquiteturas e padrões de desenvolvimento.

### ✅ Go + Fiber - COMPLETE

**Location:** `backend/todo_go_fiber/`

**Status:**
- ✅ User authentication and authorization
- ✅ Complete Todo CRUD operations
- ✅ Advanced filtering and pagination
- ✅ Role-based access control
- ✅ OpenAPI/Swagger documentation
- ✅ Docker support
- 🔄 Unit tests (in progress)

**Documentation:** `backend/todo_go_fiber/README.md`

---

### 🔄 Java + Spring Boot - IN PROGRESS

**Location:** `backend/todo_java_spring/`

**Status:**
- ✅ Project structure and setup
- 🔄 User registration
- ⏳ Authentication and authorization
- ⏳ Todo CRUD operations
- ⏳ Advanced filtering and pagination
- ⏳ Tests and documentation
- ⏳ Docker support

**Documentation:** `backend/todo_java_spring/HELP.md`

---

### 🔄 Dart + Vaden - IN PROGRESS

**Location:** `backend/todo_dart_vaden/`

**Status:**
- ✅ Project structure and setup
- ✅ User authentication and authorization
- ✅ User registration and login
- ✅ Password encoding and verification
- ✅ Exception handling
- ✅ Docker support
- ✅ Todo CRUD operations
- ✅ Advanced filtering and pagination
- 🏗️ Tests

**Documentation:** `backend/todo_dart_vaden/README.md`

---

## 📱 Frontend Implementation

### Flutter App

**Location:** `frontend/todo_flutter/`

Aplicativo multiplataforma construído com Flutter, consumindo qualquer um dos backends disponíveis.

**Supported Platforms:**
- iOS ✅
- Android ✅
- Web (planned)
- Windows (planned)
- macOS (planned)

**Status:**
- ✅ Base structure
- ✅ UI components
- ✅ Firebase integration
- 🔄 Backend API integration
- 🏗️ Offline support

**Documentation:** `frontend/todo_flutter/README.md`

---

## 🗄️ Database

All backends use the same PostgreSQL database schema:

### Tables

**`users`** - User accounts
```sql
- id (Primary Key)
- first_name, last_name
- email (Unique)
- password (bcrypt hash)
- roles (Array of strings)
- created_at, updated_at, deleted_at (Soft delete)
```

**`todos`** - Task items
```sql
- id (Primary Key)
- user_id (Foreign Key to users)
- title
- completed (Boolean flag)
- created_at, updated_at, deleted_at (Soft delete)
```

### Database Setup

The `docker-compose.yml` automatically creates the database and schema.

For manual setup:
```bash
psql -h localhost -U postgres -d postgres -f backend/init.sql
```

---

## 🔐 API Specification

All backends implement the same REST API:

### Authentication Endpoints
```
POST /auth/register          # Create new user account
POST /auth/login             # Authenticate and get JWT token
```

### User Endpoints
```
GET /api/users               # List all users (paginated)
GET /api/users/:id           # Get specific user
GET /api/me                  # Get current user (authenticated)
POST /api/users              # Create new user
PUT /api/users/:id           # Update user
DELETE /api/users/:id        # Delete user (soft delete)
```

### Todo Endpoints
```
GET /api/todos               # List todos (paginated, filterable)
GET /api/todos/:id           # Get specific todo
POST /api/todos              # Create new todo
PUT /api/todos/:id           # Update todo
DELETE /api/todos/:id        # Delete todo (soft delete)
```

**Query Parameters (Todos):**
- `page` - Pagination page number
- `limit` - Items per page
- `search` - Search in title
- `completed` - Filter by completion status
- `sort` - Sort field (created_at, title, completed)
- `order` - Sort direction (asc, desc)

### Documentation
```
GET /docs/swagger            # Swagger UI
GET /docs/openapi.json       # OpenAPI specification
```

---

## 📊 Comparison Matrix

| Feature | Go Fiber | Java Spring | Dart Vaden | Flutter |
|---------|----------|------------|-----------|---------|
| Status | ✅ Complete | 🔄 In Dev | 🏗️ Planned | ✅ Active |
| Auth | ✅ | 🔄 | ✅ | ✅ |
| CRUD | ✅ | 🔄 | ✅ | ✅ |
| Filtering | ✅ | 🔄 | ✅ | ✅ |
| Pagination | ✅ | 🔄 | ✅ | ✅ |
| Tests | 🔄 | 🔄 | 🏗️ | 🔄 |
| Docker | ✅ | 🔄 | ✅ | - |
| Docs | ✅ | 🔄 | ✅ | 🔄 |

---

## 🛠️ Development

### Adding a Feature Across All Backends

1. **Design the feature** - Specify endpoints and data models
2. **Go Fiber** - Implement in Go
3. **Java Spring** - Implement in Java
4. **Dart Vaden** - Implement in Dart
5. **Flutter** - Update mobile app if needed
6. **Database** - Add migrations if needed
7. **Tests** - Test in all backends
8. **Documentation** - Update API docs

### Running Tests

**Go Fiber:**
```bash
cd backend/todo_go_fiber
go test ./...
```

**Java Spring:**
```bash
cd backend/todo_java_spring
mvn test
```

**Dart Vaden:**
```bash
cd backend/todo_dart_vaden
dart test
```

**Flutter:**
```bash
cd frontend/todo_flutter
flutter test
```

### Benchmark & Endpoint Validation (3 Backends)

Com os três backends rodando, execute:

```bash
cd todo_multi_lang
python3 scripts/backend_benchmark.py --repeats 5
```

Esse comando:
- testa os endpoints principais de auth e todo em Java, Go e Dart
- mede latência por endpoint
- salva dados brutos em JSON
- gera relatório Markdown com gráficos Mermaid

Saídas:
- `reports/benchmark/benchmark_latest.json`
- `reports/benchmark/benchmark_report_latest.md`

---

## 📖 Documentation

- **[Backend Comparison](docs/BACKENDS_OVERVIEW.md)** - Detailed backend comparison
- **[Overall Architecture](docs/ARCHITECTURE.md)** - Project architecture overview
- **Go Fiber** - [README](backend/todo_go_fiber/README.md)
- **Java Spring** - [HELP](backend/todo_java_spring/HELP.md)
- **Dart Vaden** - [Full Documentation](backend/todo_dart_vaden/docs/)
- **Flutter** - [README](frontend/todo_flutter/README.md)

---

## 🚀 Deployment

### Docker Compose

All services in Docker:
```bash
cd backend
docker-compose up -d
docker-compose down  # Stop services
```

### Individual Deployments

**Go Fiber:**
```bash
cd backend/todo_go_fiber
docker build -t todo-go-fiber .
docker run -p 3000:3000 todo-go-fiber
```

**Java Spring:**
```bash
cd backend/todo_java_spring
docker build -t todo-java-spring .
docker run -p 8081:8081 todo-java-spring
```

**Dart Vaden:**
```bash
cd backend/todo_dart_vaden
docker build -t todo-dart-vaden .
docker run -p 8080:8080 todo-dart-vaden
```

---

## 🎓 Learning Resources

### By Language

- **Go** - See Go Fiber implementation for simplicity and performance
- **Java** - See Spring Boot for enterprise patterns and ecosystem
- **Dart** - See Vaden for modern language features and clean architecture

### By Pattern

- **REST APIs** - All three backends
- **Authentication** - JWT implementation in all backends
- **Database Access** - ORM patterns (GORM, Spring Data, Drift)
- **Clean Architecture** - Dart Vaden implementation
- **MVC Pattern** - Go Fiber and Spring Boot implementations

---

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Check PostgreSQL is running
docker-compose ps

# View logs
docker-compose logs db

# Reset database
docker-compose exec db psql -U postgres -d todo_db -c "SELECT 1"
```

### Backend Connection Issues
```bash
# Test Go Fiber
curl http://localhost:3000/

# Test Java Spring
curl http://localhost:8081/

# Test Dart Vaden
curl http://localhost:8080/
```

### Port Conflicts
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Kill process on port 8080
lsof -ti:8080 | xargs kill -9
```

---

## 📝 Conventions

### Code Style

- **Go** - Follow `gofmt` conventions
- **Java** - Follow Google Java Style Guide
- **Dart** - Follow Dart Style Guide
- **Flutter** - Follow Flutter Best Practices

### Naming

- **English** for code
- **Portuguese** for UI strings in Flutter
- **snake_case** for files and directories
- **PascalCase** for classes
- **camelCase** for variables and methods

### Directory Structure

Each backend follows its own conventions but maintain similar logical layers:
- **Controllers/Handlers** - HTTP endpoints
- **Services** - Business logic
- **Repositories** - Data access
- **Models/Entities** - Data structures

---

## 🤝 Contributing

To contribute to this project:

1. Choose a backend or feature to work on
2. Follow the existing patterns in that backend
3. Add tests for your changes
4. Update documentation
5. Ensure all backends remain in sync for shared features

---

## 📄 License

MIT License - Feel free to use this project for learning and education.

---

## 👨‍💻 Author

Created as an educational project to explore different technology stacks and architectural patterns.

**Created:** January 2026
**Type:** Educational/Study Project
**Purpose:** Learning and comparison of multiple technology stacks

---

## 🔗 Links

- [Go Fiber Docs](https://docs.gofiber.io/)
- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Vaden Docs](https://doc.vaden.dev)
- [Flutter Docs](https://flutter.dev)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

**Last Updated:** January 8, 2026

For detailed backend information, see [BACKENDS_OVERVIEW.md](docs/BACKENDS_OVERVIEW.md)
