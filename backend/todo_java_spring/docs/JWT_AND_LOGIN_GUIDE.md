# 📚 Guia Completo: User Login + JWT em Spring Boot

## 🎯 O Que Você Aprenderá

Neste guia, você entenderá:

1. **O que é JWT?** - Tokens autenticação seguros
2. **Como funciona Login?** - Fluxo de autenticação
3. **JWT Token Provider** - Geração e validação de tokens
4. **JWT Authentication Filter** - Interceptação de requisições
5. **Como Testar** - Com cURL e Postman

---

## 🔐 Conceito: JWT (JSON Web Token)

### O Que É JWT?

JWT é um **token seguro** que representa a identidade de um usuário.

**Formato:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJpYXQiOjE1MTYyMzkwMjIsImV4cCI6MTUxNjMyNTQyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c
        │                                                 │                                                           │
      HEADER                                        PAYLOAD                                                   SIGNATURE
```

### 3 Partes do JWT

#### 1️⃣ HEADER (Cabeçalho)
```json
{
  "alg": "HS256",    // Algoritmo de assinatura
  "typ": "JWT"       // Tipo de token
}
```

#### 2️⃣ PAYLOAD (Dados)
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",  // user_id (subject)
  "email": "user@example.com",                     // email do usuário
  "iat": 1516239022,                               // issued at (data emissão)
  "exp": 1516325422                                // expiration (data expiração)
}
```

#### 3️⃣ SIGNATURE (Assinatura)
```
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  "sua-chave-secreta-muito-segura"
)
```

**Segurança:** Se alguém alterar o payload, a assinatura fica inválida!

---

## 🔄 Fluxo de Login

```
STEP 1: Cliente registra usuário
┌─────────────────────────────────────────────────────────────┐
│ POST /auth/register                                         │
│ {                                                           │
│   "email": "user@example.com",                              │
│   "password": "123456",                                     │
│   "name": "João Silva"                                      │
│ }                                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
         ✅ User criado com sucesso
         (senha criptografada com BCrypt)

────────────────────────────────────────────────────────────────

STEP 2: Cliente faz login
┌─────────────────────────────────────────────────────────────┐
│ POST /auth/login                                            │
│ {                                                           │
│   "email": "user@example.com",                              │
│   "password": "123456"                                      │
│ }                                                           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                ┌──────▼──────────────┐
                │ AuthController      │
                │ .login()            │
                └──────┬──────────────┘
                       │
                ┌──────▼──────────────┐
                │ UserService         │
                │ .login()            │
                │                     │
                │ 1. Busca user       │
                │ 2. Valida senha     │
                │ 3. Gera JWT         │
                └──────┬──────────────┘
                       │
                ┌──────▼──────────────┐
                │ JwtTokenProvider    │
                │ .generateToken()    │
                │                     │
                │ Cria token com:     │
                │ - user_id (sub)     │
                │ - email             │
                │ - iat (agora)       │
                │ - exp (+ 3 dias)    │
                │                     │
                │ Assina com:         │
                │ - chave secreta     │
                │ - algoritmo HS256   │
                └──────┬──────────────┘
                       │
                       ▼
    ✅ Token gerado com sucesso
    Exemplo:
    eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

────────────────────────────────────────────────────────────────

STEP 3: Cliente armazena token
┌─────────────────────────────────────────────────────────────┐
│ LocalStorage, SharedPreferences, Cookies, etc.              │
│                                                             │
│ token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."           │
└─────────────────────────────────────────────────────────────┘

────────────────────────────────────────────────────────────────

STEP 4: Cliente faz requisição protegida
┌─────────────────────────────────────────────────────────────┐
│ GET /api/todos                                              │
│ Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...│
│                        │                                    │
│                        └─── Token aqui                      │
└──────────────────────┬────────────────────────────────────┘
                       │
                ┌──────▼───────────────────────┐
                │ JwtAuthenticationFilter      │
                │                              │
                │ 1. Extrai token do header    │
                │ 2. Valida assinatura         │
                │ 3. Valida expiração          │
                │ 4. Extrai user_id            │
                │ 5. Adiciona ao contexto      │
                └──────┬───────────────────────┘
                       │
                    ✅ Se válido
                       │
                ┌──────▼──────────────┐
                │ SecurityContext     │
                │ agora tem user_id   │
                └──────┬──────────────┘
                       │
                ┌──────▼──────────────┐
                │ Controller          │
                │ .getTodos()         │
                │                     │
                │ Acessa user_id do   │
                │ contexto de         │
                │ segurança           │
                └──────┬──────────────┘
                       │
                       ▼
    ✅ Retorna todos do usuário autenticado
```

---

## 🛠️ Componentes Principais

### 1. LoginRequest (DTO)

```java
public class LoginRequest {
    private String email;      // Email do usuário
    private String password;   // Senha em texto plano
}
```

**Recebe:** JSON do cliente
**Exemplo:**
```json
{
  "email": "user@example.com",
  "password": "123456"
}
```

### 2. LoginResponse (DTO)

```java
public class LoginResponse {
    private UUID id;           // ID do usuário
    private String email;      // Email do usuário
    private String name;       // Nome do usuário
    private String token;      // JWT token
    private long expiresIn;    // Expiração em segundos
}
```

**Retorna:** JSON com token
**Exemplo:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 259200
}
```

### 3. JwtTokenProvider (Serviço)

```java
@Component
public class JwtTokenProvider {

    // Gera novo token
    public String generateToken(UUID userId, String email) { ... }

    // Extrai user_id do token
    public UUID getUserIdFromToken(String token) { ... }

    // Valida assinatura e expiração
    public boolean validateToken(String token) { ... }

    // Retorna tempo de expiração
    public long getExpirationSeconds() { ... }
}
```

**Responsabilidades:**
- ✅ Criar JWT com user_id e email
- ✅ Assinar com chave secreta
- ✅ Validar assinatura
- ✅ Validar expiração
- ✅ Extrair dados do token

### 4. JwtAuthenticationFilter (Filtro)

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) { ... }
}
```

**O que faz:**
1. Intercepta TODA requisição HTTP
2. Extrai JWT do header `Authorization: Bearer TOKEN`
3. Valida com JwtTokenProvider
4. Adiciona ao SecurityContext
5. Passa para o controller

**Execução:** UMA VEZ por requisição (OncePerRequestFilter)

### 5. SecurityConfig (Configuração)

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    // Define endpoints públicos/privados
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) { ... }

    // Configura CORS
    @Bean
    public CorsConfigurationSource corsConfigurationSource() { ... }

    // BCrypt para criptografia
    @Bean
    public PasswordEncoder passwordEncoder() { ... }
}
```

**Configurações:**
- ✅ POST /auth/** - Público (sem JWT)
- ✅ GET /api/** - Privado (requer JWT)
- ✅ POST /auth/login retorna token
- ✅ Reqs com token válido → SecurityContext preenchido
- ✅ Reqs sem token → 401 Unauthorized
- ✅ CORS habilitado

---

## 📝 Implementação Passo-a-Passo

### Passo 1: Usuário Faz Login

**Requisição:**
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "123456"
  }'
```

**Código no AuthController:**
```java
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest request) {
    // UserService valida credenciais
    LoginResponse response = userService.login(request);

    // Retorna token
    return ResponseEntity.ok(response);
}
```

### Passo 2: UserService Valida Credenciais

**Código:**
```java
public LoginResponse login(LoginRequest request) {
    // 1. Valida email/senha não vazios
    if (request.getEmail() == null || request.getPassword() == null) {
        throw new IllegalArgumentException("Email e senha são obrigatórios");
    }

    // 2. Busca usuário no banco
    Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
    if (userOpt.isEmpty()) {
        throw new IllegalArgumentException("Email ou senha inválidos");
    }

    // 3. Valida senha
    User user = userOpt.get();
    if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
        throw new IllegalArgumentException("Email ou senha inválidos");
    }

    // 4. Gera JWT token
    String token = jwtTokenProvider.generateToken(user.getId(), user.getEmail());

    // 5. Retorna response com token
    return new LoginResponse(
        user.getId(),
        user.getEmail(),
        user.getName(),
        token,
        jwtTokenProvider.getExpirationSeconds()
    );
}
```

**Por que "Email ou senha inválidos" para ambos?**
- Segurança! Não revelamos se email existe ou não
- Previne ataques de força bruta
- Ambigüidade intencional

### Passo 3: JwtTokenProvider Gera Token

**Código:**
```java
public String generateToken(UUID userId, String email) {
    // 1. Calcula expiração
    Date now = new Date();
    Date expiryDate = new Date(now.getTime() + (jwtExpirationSeconds * 1000));

    // 2. Cria token com claims (dados)
    return Jwts.builder()
        .subject(userId.toString())              // user_id
        .claim("email", email)                   // email
        .issuedAt(now)                           // iat
        .expiration(expiryDate)                  // exp
        .signWith(
            Keys.hmacShaKeyFor(jwtSecret.getBytes()),
            SignatureAlgorithm.HS256
        )
        .compact();
}
```

**Resultado:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJpYXQiOjE2NDMyNzc3MzEsImV4cCI6MTY0MzU2NjUzMX0
.dXrb0ZO1OY8B9V8Z7X6K5L4M3N2P1Q0R9S8T7U6V5W4X3Y2Z1A
```

### Passo 4: Cliente Armazena Token

**Frontend (Flutter/React/etc):**
```javascript
// Armazena o token
localStorage.setItem('jwt_token', response.token);

// Usa token em requisições futuras
fetch('/api/todos', {
    headers: {
        'Authorization': `Bearer ${token}`
    }
});
```

### Passo 5: JwtAuthenticationFilter Valida Token

**Fluxo:**
```
Requisição chega com:
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
                   │
                   └── Token aqui

JwtAuthenticationFilter:
1. Extrai token do header
   token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

2. Valida assinatura e expiração
   jwtTokenProvider.validateToken(token) → true/false

3. Se válido → Extrai user_id
   UUID userId = jwtTokenProvider.getUserIdFromToken(token)

4. Cria autenticação
   authentication = new UsernamePasswordAuthenticationToken(
       userId,           // quem é
       null,             // credenciais
       []                // roles
   )

5. Adiciona ao contexto
   SecurityContextHolder.getContext().setAuthentication(authentication)

6. Passa para próximo filtro
   filterChain.doFilter(request, response)
```

### Passo 6: Controller Acessa Contexto de Segurança

**Código:**
```java
@GetMapping("/api/todos")
public ResponseEntity<?> getTodos(
    @AuthenticationPrincipal UserDetails userDetails
) {
    // userDetails contém o user_id do token
    String userId = userDetails.getUsername();

    // Busca todos do usuário
    List<Todo> todos = todoService.getTodosByUser(UUID.fromString(userId));

    return ResponseEntity.ok(todos);
}
```

**Alternativa (obtém do SecurityContext):**
```java
@GetMapping("/api/todos")
public ResponseEntity<?> getTodos() {
    // Obtém a autenticação do contexto
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();

    // Extrai user_id
    String userId = auth.getPrincipal().toString();

    // Usa user_id para filtrar dados
    List<Todo> todos = todoService.getTodosByUser(UUID.fromString(userId));

    return ResponseEntity.ok(todos);
}
```

---

## 🧪 Testando Login + JWT

### Com cURL

#### 1️⃣ Registre um usuário
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123",
    "name": "Teste User"
  }'

# Resposta (201 CREATED):
# {
#   "id": "550e8400-e29b-41d4-a716-446655440000",
#   "email": "teste@example.com",
#   "name": "Teste User"
# }
```

#### 2️⃣ Faça login
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123"
  }'

# Resposta (200 OK):
# {
#   "id": "550e8400-e29b-41d4-a716-446655440000",
#   "email": "teste@example.com",
#   "name": "Teste User",
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "expiresIn": 259200
# }
```

#### 3️⃣ Salve o token
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 4️⃣ Teste requisição protegida
```bash
curl -X GET http://localhost:8080/api/todos \
  -H "Authorization: Bearer $TOKEN"

# Resposta (200 OK):
# [ { "id": 1, "title": "Todo 1", "completed": false }, ... ]
```

#### 5️⃣ Teste com token inválido
```bash
curl -X GET http://localhost:8080/api/todos \
  -H "Authorization: Bearer token-invalido"

# Resposta (401 UNAUTHORIZED):
# {"error": "Não autenticado"}
```

#### 6️⃣ Teste sem token
```bash
curl -X GET http://localhost:8080/api/todos

# Resposta (401 UNAUTHORIZED):
# {"error": "Não autenticado"}
```

### Com Postman

**1. POST /auth/login**
- URL: `http://localhost:8080/auth/login`
- Body (JSON):
```json
{
  "email": "user@example.com",
  "password": "123456"
}
```
- Envie!
- Copie o token da resposta

**2. GET /api/todos**
- URL: `http://localhost:8080/api/todos`
- Headers:
  - Key: `Authorization`
  - Value: `Bearer <seu-token>`
- Envie!

### Com HTTPie
```bash
# Login
http POST http://localhost:8080/auth/login \
  email=user@example.com password=123456

# Salve o token
TOKEN=$(...)

# Teste protegido
http GET http://localhost:8080/api/todos \
  "Authorization: Bearer $TOKEN"
```

---

## 🔑 Configuração de JWT_SECRET

O `JWT_SECRET` deve ser uma chave forte e segura!

**application.properties:**
```properties
jwt.secret=sua-chave-super-secreta-com-minimo-32-caracteres-aleatorios
jwt.expiration=259200
```

**Gerar chave segura (OpenSSL):**
```bash
openssl rand -base64 32
# Resultado: exemplo abaixo
# K7+8j9x0pL3qZ5vF2bD1eN6mO4iP9uR8sT7wQ2xY5zC9vB3dG6hK1lJ8oM2nP5q
```

**Ou usar variáveis de ambiente:**
```bash
export JWT_SECRET=sua-chave-aqui
export JWT_EXPIRATION=259200
```

**Em application.properties:**
```properties
jwt.secret=${JWT_SECRET:chave-padrao-dev}
jwt.expiration=${JWT_EXPIRATION:259200}
```

---

## 🚨 Segurança: Boas Práticas

### ✅ O Que Fazer

1. **Use HTTPS em produção**
   - JWT em HTTP é inseguro

2. **Armazene token com segurança**
   - LocalStorage (web) - ok para apps simples
   - SessionStorage (web) - mais seguro
   - Keychain (iOS)
   - Keystore (Android)
   - SharedPreferences (Android) - com cuidado

3. **Renovação de token**
   - Token expira? Implemente "refresh token"
   - Permite renovar sem novo login

4. **Chave secreta forte**
   - Mínimo 32 caracteres
   - Aleatória
   - Rotacione periodicamente

5. **Validações no servidor**
   - Nunca confie no cliente
   - Sempre valide token
   - Sempre valide assinatura

### ❌ O Que Evitar

1. **Não use HTTP**
   - Token pode ser interceptado

2. **Não armazene token em JavaScript global**
   - Vulnerável a XSS

3. **Não use chave secreta fraca**
   - Fácil descobrir por força bruta

4. **Não coloque dados sensíveis no payload**
   - Token é apenas base64 encoded, NÃO criptografado

5. **Não ignore expiração**
   - Token antigo = acesso revogado

---

## 📊 Comparação: JWT vs Sessions

| Aspecto | JWT | Sessions |
|--------|-----|----------|
| **Armazenamento** | Cliente | Servidor |
| **Stateless** | ✅ Sim | ❌ Não |
| **Escalabilidade** | ✅ Excelente | ⚠️ Difícil |
| **Revogação** | ⚠️ Difícil | ✅ Imediata |
| **Payload** | Pode ser grande | Apenas ID |
| **Cross-domain** | ✅ Fácil | ❌ Difícil (CORS) |
| **Mobile** | ✅ Ideal | ⚠️ Cookies |

---

## 🎓 Conceitos Aprendidos

| Conceito | O Que É |
|----------|---------|
| **JWT** | Token seguro e assinado |
| **Token** | Prova de identidade do usuário |
| **Claims** | Dados dentro do token (user_id, email, etc) |
| **Assinatura** | Hash que valida integridade do token |
| **Expiração** | Token vira inválido após X segundos |
| **Bearer** | Tipo de autenticação HTTP |
| **Authentication** | Validação de identidade |
| **Authorization** | Validação de permissões |
| **SecurityContext** | Contexto com dados do usuário autenticado |
| **Filter** | Intercepta requisições HTTP |

---

## 🚀 Próximos Passos

```
✅ User Registration              [COMPLETO]
✅ User Login + JWT               [COMPLETO]
🔄 Todo CRUD (próximo)            [PRÓXIMO]
   ├── Criar todo
   ├── Listar todos do usuário
   ├── Atualizar todo
   └── Deletar todo (soft delete)

🔄 Filtering e Pagination         [FUTURO]
🔄 Authorization (roles)          [FUTURO]
🔄 Tests                          [FUTURO]
🔄 Swagger/OpenAPI               [FUTURO]
```

---

## 💡 Dicas para Sucesso

1. **Entenda o fluxo completo**
   - Login → Token gerado → Token validado → Acesso

2. **Teste frequentemente**
   - Use cURL entre cada passo
   - Veja os erros na prática

3. **Debug com logs**
   - System.out.println na classe
   - Veja tokens sendo processados

4. **Compare com Go Fiber**
   - Veja a mesma lógica em outra linguagem
   - Padrões universais

5. **Estude o código comentado**
   - Cada arquivo tem explicações
   - Leia os comentários!

---

## 🔗 Referências

- [RFC 7519 - JWT](https://tools.ietf.org/html/rfc7519)
- [Spring Security Docs](https://spring.io/projects/spring-security)
- [JWT.io - Playground](https://jwt.io) - Teste tokens aqui!
- [OWASP - Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

---

## 📁 Arquivos Relacionados

| Arquivo | Função |
|---------|--------|
| `JwtTokenProvider.java` | Gera e valida tokens |
| `JwtAuthenticationFilter.java` | Intercepta e valida JWT |
| `LoginRequest.java` | DTO entrada |
| `LoginResponse.java` | DTO saída com token |
| `UserService.login()` | Lógica de autenticação |
| `AuthController.login()` | Rota HTTP |
| `SecurityConfig.java` | Configuração de segurança |

---

**Criado:** 9 de janeiro de 2026
**Status:** ✅ Pronto para aprender
**Próximo:** Implemente Todo CRUD
**Tempo estimado:** 2-3 horas para dominar
