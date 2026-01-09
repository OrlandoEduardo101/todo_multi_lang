# 📊 Estrutura do Projeto Spring Boot

## Árvore de Diretórios Completa

```
todo_java_spring/
├── README_SPRING.md                    ← Leia primeiro!
├── LEARNING_SUMMARY.md                 ← Sumário executivo
├── IMPLEMENTATION_SUMMARY.md           ← Visão geral
├── USER_REGISTRATION_GUIDE.md          ← Guia completo (PRINCIPAL)
├── SPRING_PATTERNS_REFERENCE.md        ← Padrões reutilizáveis
├── STRUCTURE.md                        ← Este arquivo
├── HELP.md                             ← Spring Boot HELP
├── mvnw                                ← Maven wrapper (Unix)
├── mvnw.cmd                            ← Maven wrapper (Windows)
├── pom.xml                             ← Dependências Maven
│
├── src/
│   ├── main/
│   │   ├── java/com/todo/
│   │   │   ├── TodoApplication.java    ← Entry point
│   │   │   │
│   │   │   ├── controller/
│   │   │   │   └── AuthController.java
│   │   │   │       POST /auth/register
│   │   │   │
│   │   │   ├── service/
│   │   │   │   └── UserService.java
│   │   │   │       Lógica: validar, criptografar, salvar
│   │   │   │
│   │   │   ├── repository/
│   │   │   │   └── UserRepository.java
│   │   │   │       Acesso a dados (Auto CRUD)
│   │   │   │
│   │   │   ├── model/
│   │   │   │   └── User.java
│   │   │   │       @Entity mapeado para tabela 'users'
│   │   │   │
│   │   │   ├── dto/
│   │   │   │   ├── RegisterRequest.java
│   │   │   │   │   (email, password, name)
│   │   │   │   │
│   │   │   │   └── UserResponse.java
│   │   │   │       (id, email, name) ← SEM password!
│   │   │   │
│   │   │   └── config/
│   │   │       └── SecurityConfig.java
│   │   │           PasswordEncoder Bean (BCrypt)
│   │   │
│   │   └── resources/
│   │       └── application.properties
│   │           DB_HOST, DB_PORT, DB_NAME, JWT_SECRET
│   │
│   └── test/
│       └── java/com/todo/
│           └── TodoApplicationTests.java
│               (Testes ainda não implementados)
│
├── target/                             ← Compilação (gitignore)
│   └── classes/
│       └── (Bytecode compilado)
│
└── .mvn/wrapper/
    └── maven-wrapper.properties
```

---

## 🔄 Fluxo de uma Requisição

```
1. POST /auth/register
   ├─ Headers: Content-Type: application/json
   └─ Body: {"email": "...", "password": "...", "name": "..."}

2. Spring recebe
   ├─ Desserializa JSON → RegisterRequest
   └─ Passa para AuthController

3. AuthController.register(request)
   ├─ Chama userService.register(request)
   ├─ Try/Catch para erro handling
   └─ Retorna ResponseEntity

4. UserService.register(request)
   ├─ Valida email com userRepository.existsByEmail()
   ├─ Criptografa senha: passwordEncoder.encode()
   ├─ Cria User object
   ├─ Salva: userRepository.save(user)
   └─ Retorna UserResponse (SEM password)

5. AuthController retorna
   ├─ Status: 201 CREATED
   ├─ Body: UserResponse (JSON)
   └─ Headers: Content-Type: application/json

6. Cliente recebe resposta
   └─ {"id": "...", "email": "...", "name": "..."}
```

---

## 📁 Padrão de Arquivos (8 Classes)

### 1. Controller (1 arquivo)
```
AuthController.java
├── @RestController
├── @RequestMapping("/auth")
├── @PostMapping("/register")
└── Método: register(RegisterRequest) → ResponseEntity
```

### 2. Service (1 arquivo)
```
UserService.java
├── @Service
├── Método: register(RegisterRequest) → UserResponse
├── Validações
├── Criptografia
└── Orquestração
```

### 3. Repository (1 arquivo)
```
UserRepository.java
├── extends JpaRepository<User, UUID>
├── Métodos automáticos: save(), findById(), delete()
├── Método: findByEmail(String)
└── Método: existsByEmail(String)
```

### 4. DTOs (2 arquivos)
```
RegisterRequest.java        (ENTRADA)
├── email: String
├── password: String
└── name: String

UserResponse.java           (SAÍDA)
├── id: String
├── email: String
└── name: String
```

### 5. Entity (1 arquivo)
```
User.java
├── @Entity @Table("users")
├── id: UUID (PK)
├── email: String (unique)
├── password: String
├── name: String
└── Getters/Setters
```

### 6. Config (1 arquivo)
```
SecurityConfig.java
├── @Configuration
├── Bean: PasswordEncoder
└── Bean: SecurityFilterChain
```

### 7. Main (1 arquivo)
```
TodoApplication.java
├── @SpringBootApplication
└── main(String[] args)
```

---

## 📦 Dependências Principais (pom.xml)

```xml
<!-- Web -->
<spring-boot-starter-web>              ← HTTP servers, REST

<!-- Database -->
<spring-boot-starter-data-jpa>         ← Hibernate, JPA
<postgresql>                            ← PostgreSQL driver

<!-- Security -->
<spring-boot-starter-security>         ← BCrypt, Auth
<jjwt>                                 ← JWT (próximo passo)

<!-- Dev Tools -->
<spring-boot-devtools>                 ← Hot reload

<!-- Testing -->
<spring-boot-starter-test>             ← JUnit, Mockito
```

---

## 🏃 Ciclo de Desenvolvimento

### 1. Compilar
```bash
./mvnw clean compile
# Verifica syntax, imports, tipos
```

### 2. Testar
```bash
./mvnw test
# Executa @Test methods
```

### 3. Executar
```bash
./mvnw spring-boot:run
# Inicia Spring Boot server
```

### 4. Build JAR
```bash
./mvnw package
# Cria: target/todo-0.0.1-SNAPSHOT.jar
```

### 5. Deploy JAR
```bash
java -jar target/todo-0.0.1-SNAPSHOT.jar
# Executa JAR standalone
```

---

## 📊 Mapeamento Banco de Dados

### Tabela: users
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);
```

### Entidade Java
```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue
    private UUID id;
    
    @Column(unique = true, nullable = false)
    private String email;
    
    @Column(nullable = false)
    private String password;
    
    private String name;
    // timestamps...
}
```

---

## 🔐 Segurança em Camadas

```
┌─────────────────────────────────────┐
│ HTTP Layer (AuthController)         │
│ - Validar request format            │
│ - Sanitizar input                   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Business Layer (UserService)        │
│ - Validar email duplicado           │
│ - Validar campos obrigatórios       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Encryption (PasswordEncoder)        │
│ - BCrypt password hash              │
│ - Random salt                       │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Data Layer (UserRepository)         │
│ - Salvar apenas hash (nunca senha!) │
│ - Query prepared statements         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│ Database (PostgreSQL)               │
│ - Acesso controlado                 │
│ - Privilégios mínimos               │
└─────────────────────────────────────┘
```

---

## 📚 Documentação Interna do Código

Cada arquivo tem:
- Comentários de classe (classe inteira)
- Comentários de método (o que faz)
- Comentários inline (lógica complexa)
- Javadoc (@param, @return, @throws)

Exemplo:
```java
/**
 * Registra um novo usuário
 * @param request - RegisterRequest com email, password, name
 * @return UserResponse com id, email, name (SEM password)
 * @throws IllegalArgumentException se email já existe
 */
public UserResponse register(RegisterRequest request) {
    // Validar...
}
```

---

## �� Padrão de Testes

```
src/test/java/com/todo/
├── controller/
│   └── AuthControllerTest.java
│       - testRegisterSuccess()
│       - testRegisterDuplicateEmail()
│       - testRegisterMissingFields()
│
├── service/
│   └── UserServiceTest.java
│       - testRegisterValidation()
│       - testPasswordEncryption()
│
└── repository/
    └── UserRepositoryTest.java
        - testFindByEmail()
        - testExistsByEmail()
```

**Status:** 🔄 Ainda não implementados

---

## 🚀 Evolução do Projeto

```
Fase 1: User Registration ✅
├── AuthController
├── UserService
├── UserRepository
└── DTOs

Fase 2: User Login (Próximo)
├── JwtTokenProvider
├── LoginController
└── JwtFilter

Fase 3: Todo CRUD
├── TodoController
├── TodoService
├── TodoRepository
└── Todo Entity

Fase 4: Advanced Features
├── Pagination
├── Filtering
├── Authorization
└── Tests
```

---

## 📖 Por Onde Começar (Roadmap de Aprendizado)

```
Dia 1: Setup
├── Ler README_SPRING.md
├── Compilar projeto: ./mvnw clean compile
└── Executar: ./mvnw spring-boot:run

Dia 2: Entender Estrutura
├── Ler IMPLEMENTATION_SUMMARY.md
├── Ver arquivos em src/main/java/
└── Testar com cURL

Dia 3-4: Aprender em Profundidade
├── Ler USER_REGISTRATION_GUIDE.md
├── Estudar cada arquivo comentado
└── Entender fluxo de dados

Dia 5: Padrões
├── Ler SPRING_PATTERNS_REFERENCE.md
├── Copiar padrões para novas features
└── Prontidão para User Login

Dia 6+: Implementar Features
├── Usar padrões como template
├── Testar frequentemente
└── Documentar código
```

---

## 🎯 Estrutura Resumida

| Componente | Arquivo | Responsabilidade |
|-----------|---------|-----------------|
| **HTTP** | AuthController | Receber/Enviar requests |
| **Lógica** | UserService | Validar, criptografar, orquestrar |
| **Dados** | UserRepository | Abstração do banco |
| **Modelo** | User | Representação da entidade |
| **Entrada** | RegisterRequest | Dados recebidos |
| **Saída** | UserResponse | Dados enviados |
| **Config** | SecurityConfig | Configurações Spring |

---

**Estrutura criada:** 9 de janeiro de 2026  
**Status:** ✅ Pronto para aprendizado  
**Próximo:** User Login + JWT
