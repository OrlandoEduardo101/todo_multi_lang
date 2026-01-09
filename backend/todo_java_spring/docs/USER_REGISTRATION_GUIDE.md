# 📚 Guia: User Registration em Spring Boot

## Visão Geral do que Implementamos

Criamos um sistema completo de **User Registration** seguindo a arquitetura em camadas do Spring Boot.

```
HTTP Request (POST /auth/register)
    ↓
AuthController (@PostMapping)
    ↓
UserService.register()
    ↓
BCryptPasswordEncoder.encode()
    ↓
UserRepository.save()
    ↓
PostgreSQL Database
    ↓
HTTP Response (201 CREATED)
```

---

## 🏗️ Arquitetura em Camadas (MVC)

Spring Boot segue o padrão **Model-View-Controller**:

### 1️⃣ **CONTROLLER** (HTTP Layer)
- **Arquivo:** `AuthController.java`
- **Responsabilidade:** Receber requisições HTTP
- **Anotações:**
  - `@RestController` = Transformar retorno em JSON
  - `@PostMapping` = Marca como POST HTTP
  - `@RequestBody` = Spring converte JSON → Java Object

**O que acontece:**
```
POST /auth/register com JSON
    ↓
Spring converte JSON → RegisterRequest
    ↓
Passa para UserService
```

### 2️⃣ **SERVICE** (Business Logic Layer)
- **Arquivo:** `UserService.java`
- **Responsabilidade:** Lógica de negócio
  - Validações
  - Criptografia de senha
  - Orquestração de operações

**O que faz:**
```
1. Valida se email já existe
2. Criptografa senha com BCrypt
3. Cria novo objeto User
4. Chama repository.save()
5. Retorna UserResponse (SEM a senha!)
```

### 3️⃣ **REPOSITORY** (Data Access Layer)
- **Arquivo:** `UserRepository.java`
- **Responsabilidade:** Comunicar com banco de dados
- **Tecnologia:** Spring Data JPA

**O que fornece:**
```
JpaRepository <User, UUID>
    ├── save(user)                    // INSERT
    ├── findById(id)                  // SELECT BY ID
    ├── findAll()                     // SELECT ALL
    └── delete(user)                  // DELETE
```

### 4️⃣ **MODEL** (Data Structure)
- **Arquivo:** `User.java`
- **Responsabilidade:** Representar tabela no banco
- **Anotação:** `@Entity` = Essa classe mapeia para uma tabela SQL

---

## 🔐 Fluxo de Criptografia de Senha

### Por que criptografar?

Nunca armazene senhas em texto plano! Sempre use **BCrypt**.

```
Senha do usuário: "123456"
    ↓
BCryptPasswordEncoder.encode()
    ↓
Hash criptografado: "$2a$10$N9qo8uLO....."  (não reversível!)
    ↓
Armazena no banco
```

### Como funciona:

1. **Registro:**
```java
String senhaPlana = "123456";
String senhaHash = passwordEncoder.encode(senhaPlana);
// senhaHash = "$2a$10$..." (random, sempre diferente)
user.setPassword(senhaHash);
userRepository.save(user);
```

2. **Login (próximo passo):**
```java
String senhaDigitada = "123456";
String senhaArmazenada = user.getPassword(); // "$2a$10$..."

boolean senhaCorreta = passwordEncoder.matches(senhaDigitada, senhaArmazenada);
// Compara sem descriptografar!
```

---

## 📋 DTOs (Data Transfer Objects)

### Por que usar DTOs?

**Má prática:**
```java
@PostMapping("/register")
public User register(@RequestBody User user) {
    // ❌ Expõe TODA a entidade User
    // Cliente pode enviar: id, createdAt, deletedAt, etc.
}
```

**Boa prática:**
```java
@PostMapping("/register")
public UserResponse register(@RequestBody RegisterRequest request) {
    // ✅ Controla exatamente o que recebe e envia
}
```

### Nossas DTOs:

**RegisterRequest** (entrada)
```java
{
  "email": "user@example.com",
  "password": "123456",
  "name": "João Silva"
}
```

**UserResponse** (saída)
```java
{
  "id": "uuid-aqui",
  "email": "user@example.com",
  "name": "João Silva"
  // ❌ SEM password!
}
```

---

## 🧪 Testando com cURL

### 1. Registrar novo usuário:
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "123456",
    "name": "João Silva"
  }'
```

**Resposta esperada (201 CREATED):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "teste@example.com",
  "name": "João Silva"
}
```

### 2. Tentar registrar email duplicado:
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "outrasenha",
    "name": "Maria"
  }'
```

**Resposta esperada (400 BAD REQUEST):**
```json
{
  "error": "Email já registrado"
}
```

---

## 🔍 Anatomia de Cada Componente

### AuthController.java

```java
@RestController              // Spring cria uma instância e gerencia
@RequestMapping("/auth")     // Prefixo das rotas
public class AuthController {

    @Autowired               // Spring injeta automaticamente
    private UserService userService;

    @PostMapping("/register")  // POST /auth/register
    public ResponseEntity<?> register(
        @RequestBody RegisterRequest request
    ) {
        try {
            UserResponse user = userService.register(request);
            return ResponseEntity
                .status(HttpStatus.CREATED)  // 201
                .body(user);
        } catch (IllegalArgumentException e) {
            return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)  // 400
                .body(new ErrorResponse(e.getMessage()));
        }
    }
}
```

**Conceitos:**
- `@RestController` = Controller + Serializa respostas para JSON
- `@RequestMapping("/auth")` = Todas as rotas começam com `/auth`
- `@PostMapping` = Método HTTP POST
- `@RequestBody` = Spring desserializa JSON para objeto Java
- `ResponseEntity` = Controlar HTTP status code
- Try/Catch = Tratar erros de forma legível

---

### UserService.java

```java
@Service                     // Spring cria uma instância única (Singleton)
public class UserService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    public UserResponse register(RegisterRequest request) {
        // 1. Validar
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new IllegalArgumentException("Email já registrado");
        }

        // 2. Criar objeto
        User user = new User();
        user.setEmail(request.getEmail());
        user.setName(request.getName());

        // 3. Criptografar senha ✨
        user.setPassword(
            passwordEncoder.encode(request.getPassword())
        );

        // 4. Salvar
        User savedUser = userRepository.save(user);

        // 5. Retornar (SEM senha!)
        return new UserResponse(
            savedUser.getId().toString(),
            savedUser.getEmail(),
            savedUser.getName()
        );
    }
}
```

**Conceitos:**
- `@Service` = Componente de lógica de negócio
- `@Autowired` = Injeção de dependência (Spring cria os objetos)
- `userRepository.existsByEmail()` = Metódos gerados automaticamente!
- `passwordEncoder.encode()` = BCrypt criptografia
- Sempre devolver DTO, nunca a entidade completa

---

### UserRepository.java

```java
public interface UserRepository extends JpaRepository<User, UUID> {
    // JpaRepository fornece:
    // - save(user)
    // - findById(id)
    // - findAll()
    // - delete(user)
    // - deleteById(id)

    // Você adiciona métodos de negócio:
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    // Spring cria a implementação AUTOMATICAMENTE!
    // Basta seguir a convenção de nomenclatura
}
```

**Magia do Spring Data JPA:**
```
Você escreve:   boolean existsByEmail(String email);
Spring cria:    SELECT COUNT(*) FROM users WHERE email = ?;
```

---

### User.java (Model)

```java
@Entity                      // = Mapear para tabela SQL
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue          // Gerado automaticamente (UUID)
    private UUID id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;

    private String name;

    // Getters e Setters...
}
```

---

## 🔄 Fluxo Completo de uma Requisição

```
1. Cliente envia:
   POST /auth/register
   {
     "email": "novo@example.com",
     "password": "123456",
     "name": "João"
   }

2. Spring recebe e desserializa:
   RegisterRequest {
     email: "novo@example.com"
     password: "123456"
     name: "João"
   }

3. AuthController.register() é chamado
   ↓
4. Chama userService.register(request)
   ↓
5. UserService valida e criptografa:
   - Verifica se email existe
   - Cria User object
   - Criptografa senha: "123456" → "$2a$10$..."
   ↓
6. Chama userRepository.save(user)
   ↓
7. Spring gera SQL:
   INSERT INTO users (id, email, password, name)
   VALUES ('uuid', 'novo@example.com', '$2a$10$...', 'João')
   ↓
8. PostgreSQL salva no banco
   ↓
9. UserService retorna UserResponse (SEM senha)
   ↓
10. AuthController retorna com status 201
   ↓
11. Cliente recebe:
    HTTP 201 CREATED
    {
      "id": "uuid-aqui",
      "email": "novo@example.com",
      "name": "João"
    }
```

---

## 🚀 Próximos Passos

Agora que o **User Registration** está pronto, os próximos passos são:

1. **User Login** - Implementar autenticação com JWT
2. **Todo CRUD** - Operações CRUD para todos
3. **Filtering/Pagination** - Listar todos com filtros
4. **Authorization** - Proteger endpoints com Spring Security

---

## 📚 Conceitos-Chave Aprendidos

| Conceito | O que é | Exemplo |
|----------|---------|---------|
| `@RestController` | Controller que retorna JSON | `@RestController` |
| `@Service` | Camada de lógica de negócio | `UserService` |
| `@Repository` | Camada de acesso a dados | `JpaRepository` |
| `@Autowired` | Injeção de dependência | Automatic wiring |
| `DTO` | Objeto para transferir dados | `RegisterRequest` |
| `ResponseEntity` | Controlar resposta HTTP | Status, headers, body |
| `BCrypt` | Criptografia de senhas | `passwordEncoder.encode()` |
| `JPA` | Mapeamento Objeto-Relacional | `@Entity`, `@Column` |

---

## ❓ Dúvidas Comuns

**P: Por que Spring injeta automaticamente?**
A: É o padrão de design **Dependency Injection**. O Spring gerencia as instâncias e as passa quando necessário. Benefícios: testabilidade, flexibilidade, menos acoplamento.

**P: Por que usar DTOs?**
A: Separar dados que recebemos (RegisterRequest) dos dados que guardamos (User). Mais segurança e controle.

**P: Por que BCrypt e não simplesmente criptografar?**
A: BCrypt é **unidirecional**. Impossível recuperar a senha original. No login, apenas comparamos com `matches()`.

**P: Preciso criar userRepository.save() manualmente?**
A: NÃO! Spring Data JPA cria automaticamente. Basta estender `JpaRepository<User, UUID>`.

---

**Criado em:** 9 de janeiro de 2026
**Objetivo:** Aprender Spring Boot através do User Registration
**Nível:** Iniciante → Intermediário
