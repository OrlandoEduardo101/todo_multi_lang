# 🚀 JWT Login - Quick Reference Card

## 📌 Endpoints

### POST /auth/register
Registra novo usuário

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "senha123",
    "name": "João Silva"
  }'
```

**Response (201):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva"
}
```

---

### POST /auth/login
Autentica usuário e retorna JWT token

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "senha123"
  }'
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "name": "João Silva",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJlbWFpbCI6InVzZXJAZXhhbXBsZS5jb20iLCJpYXQiOjE3MDMyNzk0MjksImV4cCI6MTcwMzUzODYyOX0.abc123def456...",
  "expiresIn": 259200
}
```

**Errors:**
- `401`: Email ou senha inválidos
- `500`: Erro do servidor

---

### GET /api/protected
Endpoint protegido (requer JWT token)

```bash
curl -X GET http://localhost:8080/api/protected \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "message": "Acesso permitido",
  "userId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Errors:**
- `401`: Token inválido, expirado ou ausente
- `403`: Acesso negado

---

## 🔑 JWT Token Format

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9 . eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJpYXQiOjE3MDMyNzk0MjksImV4cCI6MTcwMzUzODYyOX0 . abc123def456...
         HEADER                               PAYLOAD                                                   SIGNATURE
```

### Decodificar em https://jwt.io

**Header:**
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload:**
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "iat": 1703279429,
  "exp": 1703538629
}
```

---

## 🔐 Authorization Header

Sempre incluir o token no header:

```
Authorization: Bearer <token>
```

Exemplo completo:
```bash
curl -X GET http://localhost:8080/api/protected \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJpYXQiOjE3MDMyNzk0MjksImV4cCI6MTcwMzUzODYyOX0.abc123def456..."
```

---

## ⚙️ Configuration

### application.properties
```properties
# JWT Secret (mínimo 32 caracteres)
jwt.secret=${JWT_SECRET:dev-secret-key-que-deve-ser-alterado-em-producao-com-32-caracteres}

# JWT Expiration (em SEGUNDOS)
jwt.expiration=${JWT_EXPIRATION:259200}  # 3 dias = 259200 segundos
```

### Environment Variables (Produção)
```bash
export JWT_SECRET="sua-chave-super-secreta-aleatoria-com-minimo-32-caracteres"
export JWT_EXPIRATION=259200
```

---

## 📝 Arquivos Principais

| Arquivo | Responsabilidade |
|---------|------------------|
| [JwtTokenProvider.java](../src/main/java/com/todo/security/JwtTokenProvider.java) | Gera e valida tokens |
| [JwtAuthenticationFilter.java](../src/main/java/com/todo/security/JwtAuthenticationFilter.java) | Intercepta requisições com token |
| [UserService.java](../src/main/java/com/todo/service/UserService.java) | Lógica de login |
| [AuthController.java](../src/main/java/com/todo/controller/AuthController.java) | Endpoints /auth/login |
| [SecurityConfig.java](../src/main/java/com/todo/config/SecurityConfig.java) | Configuração de segurança |
| [LoginRequest.java](../src/main/java/com/todo/dto/LoginRequest.java) | DTO de entrada |
| [LoginResponse.java](../src/main/java/com/todo/dto/LoginResponse.java) | DTO de saída |

---

## 🧪 Testes Rápidos

### 1. Registrar
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456","name":"Test"}'
```

### 2. Login (obter token)
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}' | jq -r '.token')

echo "Token: $TOKEN"
```

### 3. Usar token
```bash
curl -X GET http://localhost:8080/api/protected \
  -H "Authorization: Bearer $TOKEN"
```

---

## ❌ Erros Comuns

### 401 Unauthorized
- Token não enviado
- Token inválido
- Token expirado
- Assinatura inválida

**Solução:** Fazer login novamente

### 403 Forbidden
- Endpoints sem permissão
- Rota não configurada como pública

**Solução:** Verificar SecurityConfig

### 500 Internal Server Error
- Erro no servidor
- Banco de dados não conectado
- JWT_SECRET não configurado

**Solução:** Verificar logs do servidor

---

## 💡 Dicas

1. **Token Expires In:** Está em SEGUNDOS, não milissegundos
   - 259200 = 3 dias
   - 86400 = 1 dia
   - 3600 = 1 hora

2. **JWT_SECRET:** Deve ter mínimo 32 caracteres
   - Use um gerador: https://www.random.org/strings/
   - Nunca commit em Git
   - Use variáveis de ambiente

3. **Bearer Format:** Sempre `Bearer <token>`, não `Token <token>`

4. **CORS:** Configurado para aceitar todos (em desenvolvimento)
   - Em produção: Restringir origens

5. **Tokens Expirados:** Não há refresh token
   - Usuário faz login novamente
   - Ou implemente refresh tokens (próxima feature)

---

## 📚 Leitura Adicional

- [JWT_AND_LOGIN_GUIDE.md](JWT_AND_LOGIN_GUIDE.md) - Guia detalhado
- [TESTING_LOGIN_JWT.md](TESTING_LOGIN_JWT.md) - Testes completos
- [RFC 7519 - JWT](https://tools.ietf.org/html/rfc7519)
- [Spring Security JWT](https://spring.io/guides/tutorials/spring-boot-oauth2)

---

**Status:** ✅ Implementado e Testado
**Data:** January 9, 2026
**Próximo:** Todo CRUD
