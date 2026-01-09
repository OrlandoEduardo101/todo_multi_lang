# 🎓 Spring Boot User Registration - Sumário Visual

## 📁 Arquivos Criados

```
src/main/java/com/todo/
├── controller/
│   └── AuthController.java          ← HTTP Endpoints
├── service/
│   └── UserService.java             ← Lógica de Negócio
├── dto/
│   ├── RegisterRequest.java         ← Entrada (JSON)
│   └── UserResponse.java            ← Saída (JSON)
├── model/
│   └── User.java                    ← Entity (Banco)
├── repository/
│   └── UserRepository.java          ← Acesso a Dados
└── config/
    └── SecurityConfig.java          ← PasswordEncoder Bean
```

---

## 🔄 Fluxo de Dados

```
                     HTTP Request
                         │
                    POST /auth/register
                         │
           ┌─────────────┴─────────────┐
           │   JSON → RegisterRequest   │
           │  (Spring desserializa)     │
           └─────────────┬─────────────┘
                         │
                  AuthController
                    .register()
                         │
                   UserService
                   .register()
                         │
         ┌───────────────┼───────────────┐
         │               │               │
      Valida       Criptografa        Salva
    (email)        (BCrypt)          (DB)
         │               │               │
         └───────────────┼───────────────┘
                         │
                  UserRepository
                     .save()
                         │
                  PostgreSQL DB
                         │
           ┌─────────────┴─────────────┐
           │   User salvo com sucesso  │
           │   (id, email, name)       │
           └─────────────┬─────────────┘
                         │
                  UserResponse
                    (SEM password!)
                         │
           ┌─────────────┴─────────────┐
           │   HTTP 201 CREATED        │
           │   + JSON Response         │
           └─────────────────────────────┘
```

---

## 📚 Camadas Explicadas

### Layer 1: Controller (HTTP)
```java
@RestController
@RequestMapping("/auth")
public class AuthController {
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        // Recebe: JSON → RegisterRequest
        // Passa para: UserService
        // Retorna: ResponseEntity com UserResponse ou erro
    }
}
```
**Responsabilidades:**
- ✅ Receber requisição HTTP
- ✅ Desserializar JSON
- ✅ Chamar serviço
- ✅ Controlar HTTP status codes
- ✅ Serializar resposta para JSON

---

### Layer 2: Service (Lógica)
```java
@Service
public class UserService {
    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository userRepository;

    public UserResponse register(RegisterRequest request) {
        // Validações
        // Criptografia
        // Persistência
        // Orquestração
    }
}
```
**Responsabilidades:**
- ✅ Validar dados
- ✅ Regras de negócio
- ✅ Criptografar senha
- ✅ Chamar repository
- ✅ Retornar DTO

---

### Layer 3: Repository (Dados)
```java
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
```
**Responsabilidades:**
- ✅ Abstrair acesso ao banco
- ✅ Converter objeto ↔ SQL
- ✅ Executar queries

---

## 🔐 Segurança: BCrypt

```
Senha digitada:     "123456"
    ↓
BCryptPasswordEncoder.encode()
    ↓
Hash:               "$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcg7Ks9K9WXq1A1hm..."
                    (NUNCA reversível!)
    ↓
Armazena no BD
```

**No login (próximo):**
```
Senha digitada:     "123456"
Senha armazenada:   "$2a$10$N9qo8..."
    ↓
passwordEncoder.matches(digitada, armazenada)
    ↓
Boolean: true/false
    ✅ Sem descriptografar!
```

---

## 🧪 Testar Local

### 1. Inicie o servidor
```bash
cd /Users/orlandoeduardo101/Projects/study/todo_multi_lang/backend/todo_java_spring
./mvnw spring-boot:run
```

### 2. Registre um usuário
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@example.com",
    "password": "Senha@123",
    "name": "João Silva"
  }'
```

### 3. Resposta esperada (201)
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "joao@example.com",
  "name": "João Silva"
}
```

### 4. Tente novamente (erro)
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@example.com",
    "password": "OutraSenha",
    "name": "Outra Pessoa"
  }'
```

### 5. Resposta esperada (400)
```json
{
  "error": "Email já registrado"
}
```

---

## 🎯 O que Aprendemos

| Tópico | Aplicado em |
|--------|------------|
| Anotações Spring | `@RestController`, `@Service`, `@Autowired` |
| Injeção de Dependência | `UserService`, `PasswordEncoder` |
| HTTP Methods | `@PostMapping`, `@RequestBody` |
| Status Codes | `201 CREATED`, `400 BAD REQUEST` |
| DTOs | `RegisterRequest`, `UserResponse` |
| Encriptação | `BCryptPasswordEncoder` |
| JPA/Hibernate | `@Entity`, `JpaRepository` |
| Validações | Email duplicado, campos obrigatórios |
| Error Handling | Try/Catch, `ResponseEntity` |

---

## 🚀 Próximas Features

```
✅ User Registration         [COMPLETO]
🔄 User Login + JWT          [PRÓXIMO]
🔄 Todo CRUD                 [PRÓXIMO]
🔄 Filtering/Pagination      [PRÓXIMO]
🔄 Authorization             [PRÓXIMO]
🔄 Soft Delete               [PRÓXIMO]
🔄 Tests                     [PRÓXIMO]
```

---

## 💡 Dicas Importantes

1. **Sempre use DTOs para entrada/saída**
   - ❌ `public User register(@RequestBody User user)`
   - ✅ `public UserResponse register(@RequestBody RegisterRequest request)`

2. **Nunca retorne a entidade completa**
   - ❌ Expõe: password, timestamps internos, etc.
   - ✅ Retorne um DTO com apenas dados públicos

3. **Use BCrypt, não encrypt**
   - ❌ `encrypt(password)` - pode ser descriptografado
   - ✅ `bcrypt.encode(password)` - não reversível

4. **Valide sempre no Service**
   - ❌ Validações no Controller
   - ✅ Validações no Service (lógica centralizada)

5. **Use Optional em queries**
   ```java
   Optional<User> user = userRepository.findByEmail(email);
   if (user.isPresent()) { ... }
   ```

---

## 📖 Documentação Completa

Para entender melhor cada componente, veja:
- [USER_REGISTRATION_GUIDE.md](USER_REGISTRATION_GUIDE.md) - Guia detalhado
- Código fonte comentado em cada arquivo

---

**Criado:** 9 de janeiro de 2026
**Status:** ✅ Pronto para usar e aprender
