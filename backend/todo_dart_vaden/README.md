# TODO Vaden Backend

API REST para gerenciamento de tarefas usando **Vaden Framework** em Dart com arquitetura hexagonal (Clean Architecture).

## 🚀 Rápido Início

### Pré-requisitos
- Dart >= 3.10.4
- PostgreSQL >= 12
- Docker (opcional)

### Setup Local

```bash
# 1. Clonar e instalar dependências
cd backend/todo_dart_vaden
dart pub get

# 2. Configurar variáveis de ambiente
# As configurações estão em application.yaml com valores padrão
# Para sobrescrever, use variáveis de ambiente:
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=todo_db
export DB_USER=postgres
export DB_PASSWORD=postgres
export JWT_SECRET=your-secret-key
export JWT_EXPIRATION_HOURS=72

# 3. Gerar código (DTOs, repositórios, agregador)
dart run build_runner build --delete-conflicting-outputs

# 4. Rodar servidor
dart run bin/server.dart
```

O servidor estará em `http://localhost:8080`

### Docker

```bash
cd ../../docker
docker-compose up -d
```

## 🔐 Autenticação

Este projeto usa **VadenSecurity** para autenticação JWT com duas opções de login:

### Endpoints Públicos

**Registrar usuário:**
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john@example.com",
    "password": "123456"
  }'
```

**Login (VadenSecurity - Basic Auth):**
```bash
curl -X GET http://localhost:8080/auth/login \
  -u "john@example.com:123456"
# Retorna: {"access_token": "eyJ...", "token_type": "Bearer"}
```

**Login (Custom - JSON):**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "123456"
  }'
# Retorna: {"accessToken": "eyJ...", "tokenType": "Bearer", "expiresIn": "72h", "user": {...}}
```

### Usar Token em Requisições Protegidas

```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/todos
```

## 📦 Stack Tecnológico

| Tecnologia | Versão | Propósito |
|-----------|--------|-----------|
| Vaden | ^3.0.0 | Framework web com DI e OpenAPI |
| VadenSecurity | ^1.0.0 | Autenticação e autorização JWT |
| Dart | >=3.10.4 | Linguagem |
| Drift | ^2.22.0 | ORM type-safe para PostgreSQL |
| PostgreSQL | ^12 | Banco de dados |
| BCrypt | - | Hash de senhas (cost=10) |
| Auto Injector | ^3.0.0 | Injeção de dependências |

## 🏗️ Estrutura do Projeto

```
todo_dart_vaden/
├── bin/
│   └── server.dart              # Entrypoint
├── lib/
│   ├── config/
│   │   ├── database/
│   │   │   └── drift_configuration.dart  # Config Drift + PostgreSQL
│   │   └── security/
│   │       └── security_configuration.dart  # Config VadenSecurity
│   ├── src/
│   │   ├── controllers/         # HTTP endpoints
│   │   │   ├── auth_controller.dart     # POST /auth/register, /auth/login
│   │   │   ├── todo_controller.dart     # CRUD de todos
│   │   │   └── user_controller.dart     # CRUD de users
│   │   ├── dto/                 # Data Transfer Objects (@DTO)
│   │   │   ├── paginated_response.dart  # Interface genérica
│   │   │   ├── todo_dto.dart
│   │   │   ├── user_dto.dart
│   │   │   └── common_dto.dart
│   │   ├── domain/
│   │   │   ├── entities/        # Drift entities
│   │   │   │   ├── user_entity.dart
│   │   │   │   └── todo_entity.dart
│   │   │   └── repositories/    # Repository interfaces
│   │   │       ├── user_repository.dart
│   │   │       └── todo_repository.dart
│   │   ├── data/
│   │   │   └── repositories/    # Repository implementations
│   │   │       ├── user_repository_impl.dart
│   │   │       └── todo_repository_impl.dart
│   │   └── services/
│   │       └── user_details_service.dart  # VadenSecurity integration
│   ├── vaden_application.dart   # GENERATED - Agregador de rotas e DI
│   └── application.yaml         # Configurações (DB, JWT, CORS, etc.)
├── test/                        # Testes
├── docs/                        # Documentação completa
│   ├── ARCHITECTURE.md          # Arquitetura Clean/Hexagonal
│   ├── DEVELOPMENT_GUIDE.md     # Como desenvolver features
│   ├── AI-NOTES.md              # Guidelines para IA
│   └── vaden.md                 # Referência do framework
└── pubspec.yaml                 # Dependências
```

## 🔄 Workflow de Desenvolvimento

### 1. Criar/Modificar DTOs
```dart
@DTO()
class MyDTO {
  // campos...
}
```

### 2. Criar/Modificar Controllers
```dart
@Controller('/api/my-resource')
class MyController {
  @Get('/')
  Future<MyDTO> list() async { /* ... */ }
}
```

### 3. Regenerar código
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Testar
```bash
dart run bin/server.dart
```

## 🛣️ Roadmap

- [x] Setup projeto inicial
- [x] Arquitetura hexagonal
- [x] Autenticação JWT (VadenSecurity)
- [x] Registro de usuários
- [x] Login com Basic Auth e JSON
- [x] Hash de senhas com BCrypt
- [x] Exception handling com HTTP codes corretos
- [x] Docker support
- [x] CRUD completo de TODO
- [x] Filtros avançados e paginação
- [ ] Testes unitários
- [ ] Testes de integração
- [ ] CI/CD pipeline

## 📝 Features

### ✅ Implementadas
- Arquitetura Clean/Hexagonal
- VadenSecurity com JWT
- Registro de usuários (POST /auth/register)
- Login com Basic Auth (GET /auth/login)
- Login com JSON (POST /auth/login)
- Password hashing com BCrypt (cost=10)
- Exception handling com status codes corretos (401, 403, 500, etc.)
- CORS middleware
- OpenAPI/Swagger documentation (`/docs/swagger`)
- Docker support
- Environment variable resolution em application.yaml
- CRUD completo de TODO (create, read, update, delete)
- Filtros avançados (search, completed status)
- Paginação com page e limit
- Soft delete de todos
- Ordenação por campo e direção (sortBy, order)

### 🔄 Em Desenvolvimento
- Testes unitários e de integração

### 📋 Planejadas
- Comentários em TODOs
- Compartilhamento de tarefas
- Webhooks
- Rate limiting
- Testes completos

## 🤝 Contribuindo

Veja [DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md) para detalhes sobre como adicionar features.

## 📄 Licença

MIT

## 🆘 Suporte

Dúvidas?
- Veja a [documentação completa](docs/)
- [Vaden Framework Docs](https://doc.vaden.dev)
- Abra uma issue
