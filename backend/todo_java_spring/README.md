# 🎓 Java Spring Boot - TODO Backend

Status: 🔄 **IN PROGRESS** - User Registration ✅ Completo | User Login + JWT ✅ Completo

---

## 📋 O Que É Este Projeto?

Backend TODO implementado em **Java Spring Boot** como parte de um projeto educacional de comparação entre linguagens e frameworks.

### Objetivo
Aprender desenvolvimento backend em Java enquanto implementamos a mesma API em:
- ✅ Go Fiber
- 🔄 Java Spring Boot (aqui)
- 🏗️ Dart Vaden

---

## 🚀 Quick Start

### Pré-requisitos
- Java 17+
- Maven (ou usar `./mvnw`)
- PostgreSQL 12+
- Docker (opcional)

### Início Rápido

#### 1. Clone e Navigate
```bash
cd backend/todo_java_spring
```

#### 2. Inicie com Docker (recomendado)
```bash
# Volte para backend
cd ..
docker-compose up -d
# Aguarde ~30s para inicializar

# Java rodando em http://localhost:8081
```

#### 3. Ou execute localmente
```bash
cd todo_java_spring

# Configure variáveis de ambiente
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=todo_db
export DB_USER=postgres
export DB_PASSWORD=postgres
export JWT_SECRET=sua-chave-secreta

# Execute
./mvnw spring-boot:run

# Servidor em http://localhost:8080
```

---

## 📚 Aprendendo User Registration

### Para Iniciantes
1. Leia: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Visão geral
2. Estude: [USER_REGISTRATION_GUIDE.md](USER_REGISTRATION_GUIDE.md) - Explicação completa
3. Refira-se: [SPRING_PATTERNS_REFERENCE.md](SPRING_PATTERNS_REFERENCE.md) - Padrões

### Arquitetura Implementada

```
HTTP POST /auth/register
    ↓
AuthController
    ↓
UserService (Lógica)
    ├── Valida email
    ├── Criptografa senha (BCrypt)
    └── Persiste no banco
    ↓
UserRepository
    ↓
PostgreSQL
    ↓
HTTP 201 + UserResponse (SEM password!)
```

### Arquivos Principais

```
src/main/java/com/todo/
├── controller/
│   └── AuthController.java         ← Rotas HTTP
│
├── service/
│   └── UserService.java            ← Lógica de Negócio
│
├── dto/
│   ├── RegisterRequest.java        ← Entrada (JSON)
│   └── UserResponse.java           ← Saída (JSON)
│
├── model/
│   └── User.java                   ← Entity JPA
│
├── repository/
│   └── UserRepository.java         ← Acesso Dados
│
└── config/
    └── SecurityConfig.java         ← Configuração
```

---

## 🔐 Recursos Implementados

### ✅ User Registration
```bash
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "123456",
  "name": "João Silva"
}
```

**Resposta (201 CREATED):**
```json
{
  "id": "uuid-aqui",
  "email": "user@example.com",
  "name": "João Silva"
}
```

**Features:**
- ✅ Validação de email duplicado
- ✅ Validação de campos obrigatórios
- ✅ Criptografia BCrypt
- ✅ Erro handling
- ✅ Resposta sem expor senha

---

## 🧪 Testando

### Com cURL

#### Registrar usuário
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "novo@example.com",
    "password": "senha123",
    "name": "Maria Silva"
  }'
```

#### Email duplicado (erro)
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "novo@example.com",
    "password": "outrasenha",
    "name": "Outro Nome"
  }'

# Resposta: 400 BAD REQUEST
# {"error": "Email já registrado"}
```

### Com Postman

1. POST → `http://localhost:8080/auth/register`
2. Body → Raw → JSON:
```json
{
  "email": "test@example.com",
  "password": "senha123",
  "name": "Test User"
}
```
3. Envie!

---

## 📊 Estrutura de Camadas

### Layer 1: Controller (HTTP)
```java
@RestController
@RequestMapping("/auth")
public class AuthController {
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        // Recebe JSON → RegisterRequest
        // Retorna JSON (201 CREATED)
    }
}
```

**Responsabilidades:**
- Receber requisições
- Controlar HTTP status
- Serializar/Desserializar JSON

### Layer 2: Service (Lógica)
```java
@Service
public class UserService {
    public UserResponse register(RegisterRequest request) {
        // 1. Validar
        // 2. Criptografar
        // 3. Salvar
        // 4. Retornar DTO
    }
}
```

**Responsabilidades:**
- Regras de negócio
- Validações
- Orquestração

### Layer 3: Repository (Dados)
```java
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

**Responsabilidades:**
- Acesso a dados
- Queries SQL abstrato

---

## 🔐 Segurança

### BCrypt Password Hashing

```
Senha: "123456"
    ↓
BCryptPasswordEncoder.encode()
    ↓
Hash: "$2a$10$..." (NUNCA reversível)
    ↓
Armazena no banco
```

**No login (próximo):**
```java
boolean match = passwordEncoder.matches(
    senhaDigitada,           // "123456"
    senhaArmazenada          // "$2a$10$..."
);
// true/false (sem descriptografar!)
```

---

## 📖 Conceitos Aprendidos

| Conceito | O Que É | Exemplo |
|----------|---------|---------|
| **@RestController** | Controller REST | `@RestController` |
| **@Service** | Componente de lógica | `UserService` |
| **@Repository** | Acesso a dados | `JpaRepository` |
| **@Autowired** | Injeção de dependência | Auto-wiring |
| **DTO** | Transferência de dados | `RegisterRequest`, `UserResponse` |
| **JPA** | ORM (Object-Relational Mapping) | `@Entity`, `@Column` |
| **BCrypt** | Hash de senha | `passwordEncoder` |
| **ResponseEntity** | Controle HTTP | Status, headers, body |

---

## 🚀 Próximas Features

```
✅ User Registration          [COMPLETO]
✅ User Login + JWT           [COMPLETO]
🔄 Todo CRUD                  [PRÓXIMO]
🔄 Filtering/Pagination       [PRÓXIMO]
🔄 Authorization              [PRÓXIMO]
🔄 Tests                      [PRÓXIMO]
🔄 Swagger/OpenAPI            [PRÓXIMO]
```

---

## 🛠️ Desenvolvimento

### Adicionar Nova Feature

1. **Criar Model (Entity)**
```java
@Entity
@Table(name = "table_name")
public class EntityName {
    @Id
    @GeneratedValue
    private UUID id;
    // campos...
}
```

2. **Criar Repository**
```java
public interface EntityRepository extends JpaRepository<Entity, UUID> {
    // Métodos customizados
}
```

3. **Criar DTOs**
```java
public class CreateRequest { /* campos */ }
public class EntityResponse { /* campos */ }
```

4. **Criar Service**
```java
@Service
public class EntityService {
    public EntityResponse create(CreateRequest req) {
        // Lógica
    }
}
```

5. **Criar Controller**
```java
@RestController
@RequestMapping("/api/entity")
public class EntityController {
    @PostMapping
    public ResponseEntity<?> create(@RequestBody CreateRequest req) {
        // HTTP handling
    }
}
```

---

## 🐛 Troubleshooting

### Erro: Connection refused - localhost:5432
```bash
# PostgreSQL não está rodando
docker-compose up -d db
```

### Erro: Compilation error
```bash
./mvnw clean compile
# Se persistir:
rm -rf target/
./mvnw clean compile
```

### Erro: Port 8080 already in use
```bash
# Encontre o processo
lsof -ti:8080
# Mate o processo
kill -9 <PID>
```

---

## 📚 Referência Rápida

### Compilar
```bash
./mvnw clean compile
```

### Executar Tests
```bash
./mvnw test
```

### Build JAR
```bash
./mvnw package -DskipTests
```

### Executar JAR
```bash
java -jar target/todo-0.0.1-SNAPSHOT.jar
```

---

## 🔗 Links Úteis

- [Spring Boot Docs](https://spring.io/projects/spring-boot)
- [Spring Data JPA](https://spring.io/projects/spring-data-jpa)
- [Spring Security](https://spring.io/projects/spring-security)
- [JWT Introduction](https://tools.ietf.org/html/rfc7519)
- [PostgreSQL Docs](https://www.postgresql.org/docs/)

---

## 📖 Documentação Detalhada

- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Overview visual
- [USER_REGISTRATION_GUIDE.md](USER_REGISTRATION_GUIDE.md) - Guia completo
- [SPRING_PATTERNS_REFERENCE.md](SPRING_PATTERNS_REFERENCE.md) - Padrões reutilizáveis

---

## 🎓 Comparação com Outros Backends

| Feature | Go Fiber | Java Spring | Dart Vaden |
|---------|----------|------------|-----------|
| Status | ✅ Completo | 🔄 In Progress | 🏗️ Planejado |
| User Register | ✅ | ✅ | ✅ |
| User Login | ✅ | 🔄 | ✅ |
| Todo CRUD | ✅ | 🔄 | ✅ |
| Filtering | ✅ | 🔄 | ✅ |
| Pagination | ✅ | 🔄 | ✅ |
| JWT | ✅ | 🔄 | ✅ |
| Tests | 🔄 | 🔄 | 🏗️ |

---

## 💡 Dicas para Aprender

1. **Comece pelo código existente**
   - Entenda `AuthController` → `UserService` → `UserRepository`

2. **Use o padrão de referência**
   - [SPRING_PATTERNS_REFERENCE.md](SPRING_PATTERNS_REFERENCE.md) para copiar estrutura

3. **Teste frequentemente**
   - Use cURL para validar cada endpoint

4. **Estude a documentação**
   - [USER_REGISTRATION_GUIDE.md](USER_REGISTRATION_GUIDE.md) explica tudo em detalhe

5. **Compare com Go Fiber**
   - Veja como os mesmos conceitos são implementados diferentemente

---

## 👨‍💻 Contribuindo

Para adicionar features:
1. Siga o padrão em [SPRING_PATTERNS_REFERENCE.md](SPRING_PATTERNS_REFERENCE.md)
2. Mantenha consistência com User Registration
3. Adicione comentários para outros aprenderem
4. Teste com cURL antes de submeter

---

## 📄 License

MIT - Educacional

---

**Última atualização:** 9 de janeiro de 2026
**Mantém por:** Projeto TODO Multi-Language
**Status:** 🔄 Ativo em desenvolvimento
