# 🚀 Quick Start: User Login + JWT em 10 Minutos

Guia rápido para testar a implementação de login + JWT.

---

## ⚡ 1 Minuto: Inicie o Servidor

```bash
cd /Users/orlandoeduardo101/Projects/study/todo_multi_lang/backend/todo_java_spring

# Compile (primeiro console)
./mvnw clean compile -DskipTests

# Execute (mesmo console)
./mvnw spring-boot:run

# Aguarde: "Started TodoApplication in..."
```

---

## ⚡ 2 Minutos: Registre um Usuário

Em outro terminal:

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123",
    "name": "Teste User"
  }'
```

**Resposta esperada (201):**
```json
{
  "id": "uuid...",
  "email": "teste@example.com",
  "name": "Teste User"
}
```

---

## ⚡ 3 Minutos: Faça Login

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha123"
  }'
```

**Resposta (200):**
```json
{
  "id": "uuid...",
  "email": "teste@example.com",
  "name": "Teste User",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 259200
}
```

---

## ⚡ 4 Minutos: Copie o Token

```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Verifique
echo $TOKEN
```

---

## ⚡ 5 Minutos: Use o Token

```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer $TOKEN"
```

**Resposta (200):**
```json
{
  "id": "uuid...",
  "email": "teste@example.com",
  "name": "Teste User"
}
```

---

## ⚡ 6 Minutos: Teste Sem Token

```bash
curl -X GET http://localhost:8080/api/me
```

**Resposta (401):**
```json
{
  "error": "Não autenticado"
}
```

---

## ⚡ 7 Minutos: Teste Token Inválido

```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer token-fake"
```

**Resposta (401):**
```json
{
  "error": "Não autenticado"
}
```

---

## ⚡ 8 Minutos: Teste Senha Errada

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "senha-errada"
  }'
```

**Resposta (401):**
```json
{
  "error": "Email ou senha inválidos"
}
```

---

## ⚡ 9 Minutos: Teste Email Duplicado

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teste@example.com",
    "password": "outra-senha",
    "name": "Outro User"
  }'
```

**Resposta (400):**
```json
{
  "error": "Email já registrado"
}
```

---

## ⚡ 10 Minutos: Inspeção do Token

Cole no [https://jwt.io](https://jwt.io) seu token para ver:

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
  "sub": "uuid-aqui",
  "email": "teste@example.com",
  "iat": 1643277731,
  "exp": 1643566531
}
```

---

## ✅ Conclusão

Você testou com sucesso:
- ✅ Registro de usuário
- ✅ Login com JWT
- ✅ Requisição protegida COM token
- ✅ Requisição protegida SEM token
- ✅ Token inválido rejeitado
- ✅ Senha errada rejeitada
- ✅ Email duplicado bloqueado

**Tudo funcionando!** 🎉

---

## 📚 Próximo Passo

```
Leia: JWT_AND_LOGIN_GUIDE.md (2-3 horas)
Para entender:
- Como funciona JWT
- Cada componente em detalhe
- Segurança implementada
- Comparação com Go Fiber
```

---

**Criado:** 9 de janeiro de 2026
