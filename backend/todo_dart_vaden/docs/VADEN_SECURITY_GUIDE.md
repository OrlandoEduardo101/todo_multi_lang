# 🔐 Guia: Usando VadenSecurity no TODO Backend

## Overview

VadenSecurity fornece componentes prontos para autenticação JWT e criptografia de senhas (BCrypt). Este guia mostra como usá-los no contexto do TODO Backend.

## Componentes VadenSecurity

### 1. PasswordEncoder (BCrypt)

**Onde obter:**
```dart
// Em AppModule
final passwordEncoder = SecurityConfiguration.getPasswordEncoder();
```

**Como usar:**

```dart
// Hash password
final hashedPassword = passwordEncoder.encode(plainPassword);

// Verify password
final isValid = passwordEncoder.matches(plainPassword, hashedPassword);
```

**Exemplo em AuthController:**
```dart
@override
Future<Response> register(Request request) async {
  final hashedPassword = passwordEncoder.encode(data.password);
  final createRequest = CreateUserRequest(
    // ... outros campos ...
    password: hashedPassword,
  );
}
```

### 2. JwtService (Token Generation & Validation)

**Onde obter:**
```dart
// Em AppModule (após configurar VadenSecurity)
final jwtService = appModule.getJwtService();
```

**Como usar:**

```dart
// Generate token
final token = jwtService.generateToken(
  subject: userId.toString(),
  additionalClaims: {
    'email': email,
    'roles': roles,
  },
);

// Verify token
try {
  final payload = jwtService.verifyToken(token);
  final userId = payload['sub'];
} catch (e) {
  // Invalid or expired token
}
```

**Exemplo em AuthService:**
```dart
String generateToken({
  required int userId,
  required String email,
  required List<String> roles,
}) {
  return _jwtService.generateToken(
    subject: userId.toString(),
    additionalClaims: {
      'email': email,
      'roles': roles,
    },
  );
}
```

### 3. AuthMiddleware (Validação de Token)

**Como funciona:**

1. Extrai o token do header `Authorization: Bearer <token>`
2. Valida o token usando `AuthService`
3. Extrai userId do token
4. Adiciona ao contexto da requisição

**Exemplo:**
```dart
// Ao aplicar middleware em bin/server.dart
final authMiddleware = AuthMiddleware(authService: authService);
final handler = Pipeline()
    .addMiddleware(authMiddleware.middleware)
    .addHandler(router.call);
```

**Como acessar dados de autenticação nos controllers:**
```dart
import 'package:shelf/shelf.dart';
import '../config/middleware/auth_middleware.dart';

// Em um controller
Future<Response> listTodos(Request request) async {
  final userId = getUserIdFromContext(request);
  final token = getTokenFromContext(request);

  // ... usar userId ...
}
```

---

## Fluxo de Autenticação

### 1. Register
```
POST /auth/register
  ↓
Request.body: { firstName, lastName, email, password }
  ↓
AuthController.register()
  ↓
1. Validate input
2. Check if email exists
3. Hash password with BCrypt (PasswordEncoder)
4. Create user in database
5. Return UserProfile (without password)
```

### 2. Login
```
POST /auth/login
  ↓
Request.body: { email, password }
  ↓
AuthController.login()
  ↓
1. Find user by email
2. Verify password (PasswordEncoder.matches)
3. Generate JWT token (JwtService)
4. Return AuthResponse with token
```

### 3. Access Protected Route
```
GET /api/todos
Header: Authorization: Bearer <token>
  ↓
AuthMiddleware
  ↓
1. Extract token from header
2. Validate token (JwtService)
3. Extract userId from token
4. Add to request context
5. Pass to controller
```

---

## Configuração de VadenSecurity

### Em `lib/config/security/security_configuration.dart`:

```dart
class SecurityConfiguration {
  // JWT
  static const String jwtSecret = 'your-secret-key-change-in-production';
  static const int jwtExpirationHours = 72;

  // BCrypt
  static const int bcryptRounds = 10;

  static PasswordEncoder getPasswordEncoder() {
    return BcryptPasswordEncoder(rounds: bcryptRounds);
  }
}
```

### Alterar em produção:
```dart
// NUNCA fazer isso em produção!
// Sempre usar variáveis de ambiente

static String jwtSecret = Platform.environment['JWT_SECRET'] ?? 'change-me';
static int bcryptRounds = int.parse(Platform.environment['BCRYPT_ROUNDS'] ?? '10');
```

---

## Adicionando Autenticação a Novos Endpoints

### 1. Endpoint sem autenticação (público)
```dart
router.post('/auth/login', authController.login);
```

### 2. Endpoint com autenticação (protegido)
```dart
router.get('/api/todos', todoController.listTodos);

// O middleware valida automaticamente antes de chegar ao controller
```

### 3. Acessar dados do usuário autenticado

```dart
Future<Response> listTodos(Request request) async {
  // Extrair userId do context adicionado pelo middleware
  final userId = getUserIdFromContext(request);

  if (userId == null) {
    return Response(401, body: '{"error": "Unauthorized"}');
  }

  // Use userId para filtrar dados do usuário
  final todos = await todoRepository.findByUserId(userId);

  return Response.ok(todos.toJson().toString());
}
```

---

## Adicionando Autorização por Roles

### 1. Adicionar validação no middleware

```dart
// Em auth_middleware.dart
Middleware get middleware {
  return (Handler innerHandler) {
    return (Request request) async {
      final userId = authService.getUserIdFromToken(token);
      final payload = authService.verifyToken(token);

      // Extrair roles do token
      final roles = List<String>.from(payload['roles'] ?? []);

      // Adicionar roles ao context
      return innerHandler(request.change(context: {
        'user_id': userId,
        'roles': roles,
      }));
    };
  };
}
```

### 2. Usar em controllers

```dart
Future<Response> deleteUser(Request request, String id) async {
  final roles = request.context['roles'] as List<String>?;

  // Verificar se é admin
  if (roles == null || !roles.contains('admin')) {
    return Response(403, body: '{"error": "Forbidden"}');
  }

  // Permitir deleção
  return await userRepository.delete(int.parse(id));
}
```

---

## Testes com VadenSecurity

### Mock PasswordEncoder

```dart
class MockPasswordEncoder extends Mock implements PasswordEncoder {
  @override
  String encode(String raw) => 'hashed_$raw';

  @override
  bool matches(String raw, String encoded) => encoded == 'hashed_$raw';
}
```

### Mock JwtService

```dart
class MockJwtService extends Mock implements JwtService {
  @override
  String generateToken({required String subject, Map<String, dynamic>? additionalClaims}) {
    return 'token_$subject';
  }

  @override
  Map<String, dynamic> verifyToken(String token) {
    return {'sub': token.replaceFirst('token_', '')};
  }
}
```

### Usar em testes

```dart
test('register should hash password', () async {
  final mockEncoder = MockPasswordEncoder();
  final controller = AuthController(
    userRepository: mockRepository,
    passwordEncoder: mockEncoder,
  );

  // Verificar que encode foi chamado
  verify(() => mockEncoder.encode('password123')).called(1);
});
```

---

## Troubleshooting

### ❌ Token inválido
- Verificar se o token foi gerado com a mesma secret
- Verificar se o token expirou
- Verificar formato: `Bearer <token>`

### ❌ Senha não bate
- Verificar se está usando `passwordEncoder.matches()` e não `==`
- Verificar se a senha foi hasheada antes de salvar

### ❌ Middleware não validando
- Verificar se o middleware está sendo aplicado antes do router
- Verificar se a rota não está na lista de públicas

---

## Próximas Melhorias

- [ ] Adicionar refresh tokens
- [ ] Implementar rate limiting
- [ ] Adicionar 2FA (two-factor authentication)
- [ ] Implementar OAuth2/OpenID Connect
- [ ] Adicionar audit logs
- [ ] Session management

---

## Referências

- [VadenSecurity Documentation](https://doc.vaden.dev/docs/addons/vaden-security/)
- [JWT Best Practices](https://tools.ietf.org/html/rfc7519)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

---

Criado em: 8 de Janeiro de 2026
