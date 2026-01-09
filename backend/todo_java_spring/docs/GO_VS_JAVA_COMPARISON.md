# 🔄 Comparação: Go Fiber vs Java Spring - Login + JWT

## Objetivo

Ver a **mesma lógica** implementada em **duas linguagens diferentes**.
Isso ajuda a entender padrões universais vs. características específicas da linguagem.

---

## 🎯 Fluxo Lógico (Idêntico em Ambas)

```
1. Cliente envia: POST /auth/login { email, password }
   ↓
2. Handler/Controller recebe requisição
   ↓
3. Service busca usuário no banco
   ↓
4. Service valida senha com BCrypt
   ↓
5. Se válido → Service gera JWT token
   ↓
6. Handler/Controller retorna token
   ↓
7. Cliente recebe: { token, expiresIn, userInfo }
```

Este fluxo é **igual** em Go e Java!

---

## 📊 Comparação Lado-a-Lado

### 1️⃣ REQUISIÇÃO (Mesmo DTO)

#### Go Fiber
```go
type LoginInput struct {
    Email    string `json:"email"`
    Password string `json:"password"`
}
```

#### Java Spring
```java
public class LoginRequest {
    private String email;
    private String password;
    // getters/setters
}
```

**Diferenças:**
- Go usa tags JSON: `` `json:"email"` ``
- Java usa getters/setters
- **Lógica:** Ambas recebem email e senha ✅

---

### 2️⃣ BUSCAR USUÁRIO

#### Go Fiber
```go
var user models.User
if err := database.DB.Where("email = ?", input.Email).First(&user).Error; err != nil {
    return c.Status(401).JSON(fiber.Map{"error": "Usuário ou senha inválidos"})
}
```

#### Java Spring
```java
Optional<User> userOpt = userRepository.findByEmail(request.getEmail());

if (userOpt.isEmpty()) {
    throw new IllegalArgumentException("Email ou senha inválidos");
}

User user = userOpt.get();
```

**Diferenças:**
- Go retorna erro diretamente
- Java retorna Optional (pode estar vazio)
- **Lógica:** Ambas buscam usuário no banco ✅

---

### 3️⃣ VALIDAR SENHA

#### Go Fiber
```go
if err := bcrypt.CompareHashAndPassword(
    []byte(user.Password),
    []byte(input.Password),
); err != nil {
    return c.Status(401).JSON(fiber.Map{"error": "Usuário ou senha inválidos"})
}
```

#### Java Spring
```java
if (!passwordEncoder.matches(
    request.getPassword(),
    user.getPassword()
)) {
    throw new IllegalArgumentException("Email ou senha inválidos");
}
```

**Diferenças:**
- Go: `CompareHashAndPassword(hash, senha)` - ordem importa!
- Java: `matches(senha, hash)` - mais intuitivo
- **Lógica:** Ambas validam com BCrypt ✅

---

### 4️⃣ GERAR JWT TOKEN

#### Go Fiber
```go
token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
    "user_id": user.ID,
    "exp":     time.Now().Add(time.Hour * 72).Unix(), // 3 dias
})

secret := os.Getenv("JWT_SECRET")
tokenString, err := token.SignedString([]byte(secret))

if err != nil {
    return c.Status(500).JSON(fiber.Map{"error": "Erro ao gerar token"})
}
```

#### Java Spring
```java
Date now = new Date();
Date expiryDate = new Date(now.getTime() + (jwtExpirationSeconds * 1000));

String token = Jwts.builder()
    .subject(user.getId().toString())
    .claim("user_id", user.getId())
    .issuedAt(now)
    .expiration(expiryDate)
    .signWith(
        Keys.hmacShaKeyFor(jwtSecret.getBytes()),
        SignatureAlgorithm.HS256
    )
    .compact();
```

**Diferenças:**
- Go: API procedural, calcula expiração com `time.Hour * 72`
- Java: API fluente (.builder()), calcula expiração em ms
- **Lógica:** Ambas geram token HS256 com expiração ✅

---

### 5️⃣ RETORNAR RESPOSTA

#### Go Fiber
```go
return c.JSON(fiber.Map{
    "message": "Login realizado com sucesso",
    "token":   tokenString,
})
```

#### Java Spring
```java
return ResponseEntity
    .status(HttpStatus.OK)
    .body(new LoginResponse(
        user.getId(),
        user.getEmail(),
        user.getName(),
        token,
        expiresIn
    ));
```

**Diferenças:**
- Go: Retorna map anônimo
- Java: Retorna objeto tipado (LoginResponse)
- **Lógica:** Ambas retornam token ✅

---

## 🔐 Validação de Token

### Go Fiber: Middleware
```go
// middleware/auth.go
func Protected() fiber.Handler {
    return func(c *fiber.Ctx) error {
        // Extrai token do header
        token := c.Get("Authorization")

        if token == "" {
            return c.Status(401).JSON(fiber.Map{"error": "Token não fornecido"})
        }

        // Remove "Bearer "
        tokenString := token[7:]

        // Valida token
        claims := &jwt.MapClaims{}
        jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
            return []byte(os.Getenv("JWT_SECRET")), nil
        })

        // Continua
        return c.Next()
    }
}
```

### Java Spring: Filter
```java
// JwtAuthenticationFilter.java
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {

        // Extrai token do header
        String jwt = extractTokenFromRequest(request);

        if (jwt != null && jwtTokenProvider.validateToken(jwt)) {
            // Extrai user_id
            UUID userId = jwtTokenProvider.getUserIdFromToken(jwt);

            // Adiciona ao contexto de segurança
            UsernamePasswordAuthenticationToken auth =
                new UsernamePasswordAuthenticationToken(
                    userId.toString(),
                    null,
                    new ArrayList<>()
                );

            SecurityContextHolder.getContext().setAuthentication(auth);
        }

        filterChain.doFilter(request, response);
    }
}
```

**Diferenças:**
- Go: Middleware explícito, executado quando chamado
- Java: Filter automático, intercepta TODAS requisições
- **Lógica:** Ambas validam e extraem user_id ✅

---

## 📝 Registro de Rotas

### Go Fiber
```go
// routes/auth.go
func AuthRoutes(app *fiber.App) {
    app.Post("/register", handlers.Register)
    app.Post("/login", handlers.Login)
}

// routes/routes.go
func SetupRoutes(app *fiber.App) {
    AuthRoutes(app)
    PublicRoutes(app)
    app.Use(middleware.Protected())  // Aplica middleware
    ProtectedRoutes(app)             // Rotas protegidas
}
```

### Java Spring
```java
// SecurityConfig.java
@Bean
public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    http
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/auth/**").permitAll()      // Público
            .requestMatchers("/api/**").authenticated()   // Protegido
        )
        .addFilterBefore(
            jwtAuthenticationFilter,
            UsernamePasswordAuthenticationFilter.class
        );

    return http.build();
}
```

**Diferenças:**
- Go: Rotas explícitas, middleware aplicado em ordem
- Java: Configuração declarativa, filtros aplicados automaticamente
- **Lógica:** Ambas separam rotas públicas de privadas ✅

---

## 🧪 Testando Ambas

### Registrar (Mesmo em ambas)
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "123456"
  }'
```

**Go Fiber: http://localhost:3000**
**Java Spring: http://localhost:8080**

### Resposta (Ligeiramente diferente)

**Go Fiber:**
```json
{
  "message": "Login realizado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Java Spring:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 259200
}
```

**Diferenças:**
- Go: Resposta minimalista
- Java: Resposta com info do usuário
- **Lógica:** Ambas retornam token ✅

### Usar Token

```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:3000/api/todos \
  -H "Authorization: Bearer $TOKEN"

curl -X GET http://localhost:8080/api/todos \
  -H "Authorization: Bearer $TOKEN"
```

**Ambas retornam:** Lista de todos do usuário ✅

---

## 🎓 Padrões Universais

### Padrão 1: DTOs para Entrada/Saída
```
✅ Go:   LoginInput struct
✅ Java: LoginRequest class
```

### Padrão 2: Validar Email/Senha
```
✅ Go:   if err != nil { ... }
✅ Java: if (!passwordEncoder.matches(...)) { ... }
```

### Padrão 3: BCrypt para Criptografia
```
✅ Go:   bcrypt.CompareHashAndPassword(...)
✅ Java: passwordEncoder.matches(...)
```

### Padrão 4: JWT com Expiração
```
✅ Go:   exp: time.Now().Add(time.Hour * 72)
✅ Java: expiration(expiryDate)
```

### Padrão 5: Bearer Token no Header
```
✅ Go:   Authorization: Bearer TOKEN
✅ Java: Authorization: Bearer TOKEN
```

### Padrão 6: Validação em Filter/Middleware
```
✅ Go:   middleware.Protected()
✅ Java: JwtAuthenticationFilter
```

---

## 📊 Comparação de Características

| Característica | Go Fiber | Java Spring |
|---|---|---|
| **Sintaxe** | Simples | Verbosa |
| **Type System** | Estática | Estática |
| **Performance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Setup** | Rápido | Lento (muitas anotações) |
| **Comunidade** | Pequena | Enorme |
| **Produção** | ✅ Pronto | ✅ Mais pronto |
| **Learning Curve** | Fácil | Médio |
| **Framework Opinionado** | ❌ Não | ✅ Sim |
| **Configuração** | Implícita | Explícita |

---

## 💡 Lições para Aprender

### De Go Fiber
- ✅ Simplicidade é poder
- ✅ Menos código = menos bugs
- ✅ Performance importa
- ✅ Middlewares simples e diretos

### De Java Spring
- ✅ Configuração explícita é melhor
- ✅ Type safety é importante
- ✅ Frameworks maduros têm vantagens
- ✅ Anotações podem simplificar código

### Ambos
- ✅ JWT é JWT, independente da linguagem
- ✅ BCrypt é universal
- ✅ DTOs são padrão REST
- ✅ Validação é critica
- ✅ Segurança não é negoziável

---

## 🚀 Próximos Passos em Ambos

```
✅ User Registration    [COMPLETO em ambos]
✅ User Login + JWT     [COMPLETO em ambos]
🔄 Todo CRUD            [PRÓXIMO em ambos]
   ├── POST /api/todos (create)
   ├── GET /api/todos (list)
   ├── PUT /api/todos/:id (update)
   └── DELETE /api/todos/:id (delete)

🔄 Filtering/Pagination [FUTURO]
🔄 Authorization        [FUTURO]
🔄 Tests                [FUTURO]
```

---

## 🔗 Ver Implementações

### Go Fiber
- Arquivo: `backend/todo_go_fiber/internal/handlers/user.go`
- Função: `Login()`
- Linhas: ~80-120

### Java Spring
- Arquivo: `backend/todo_java_spring/src/main/java/com/todo/service/UserService.java`
- Função: `login()`
- Arquivo: `backend/todo_java_spring/src/main/java/com/todo/security/JwtTokenProvider.java`
- Função: `generateToken()`

---

## 📚 Conclusão

**Ambas implementações seguem o mesmo padrão:**
1. Receber credenciais
2. Buscar usuário
3. Validar senha
4. Gerar JWT
5. Retornar token

A linguagem e framework mudam, mas a **lógica permanece igual**! 🎯

Isso é um padrão universal que você verá em qualquer linguagem/framework.

---

**Criado:** 9 de janeiro de 2026
**Status:** ✅ Comparação Completa
