# 🧪 Testando User Login + JWT - Passo a Passo

Neste guia, vamos testar a implementação de Login + JWT de forma didática.

---

## 📋 Checklist Antes de Começar

```
[ ] Compilou projeto? → ./mvnw clean compile
[ ] PostgreSQL rodando? → docker-compose up -d db
[ ] Banco criado? → docker-compose exec db psql -U postgres -d todo_db -c "SELECT 1"
[ ] Servidor iniciado? → ./mvnw spring-boot:run
[ ] Esperou iniciar? → "Started TodoApplication in..."
```

---

## 🎯 Teste 1: Registrar Usuário

Este é o pré-requisito para fazer login!

### Requisição
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@example.com",
    "password": "senha123",
    "name": "User Um"
  }'
```

### Resposta Esperada (201 CREATED)
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user1@example.com",
  "name": "User Um"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 201
- [ ] Retorna ID do usuário
- [ ] Retorna email e name
- [ ] **NÃO retorna** a senha ✅ (Segurança!)
- [ ] ID é um UUID válido

---

## 🔐 Teste 2: Fazer Login

Agora vamos autenticar e obter um JWT token.

### Requisição
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@example.com",
    "password": "senha123"
  }'
```

### Resposta Esperada (200 OK)
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user1@example.com",
  "name": "User Um",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJlbWFpbCI6InVzZXIxQGV4YW1wbGUuY29tIiwiaWF0IjoxNjQzMjc3NzMxLCJleHAiOjE2NDM1NjY1MzF9.dXrb0ZO1OY8B9V8Z7X6K5L4M3N2P1Q0R9S8T7U6V5W4X3Y2Z1A",
  "expiresIn": 259200
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 200
- [ ] Retorna token (muito longo!)
- [ ] Retorna expiresIn (259200 = 3 dias em segundos)
- [ ] Token segue formato JWT (3 partes separadas por .)
- [ ] **Nunca retorna** a senha em texto plano

### 🔍 Inspecionar Token

Cole o token em [https://jwt.io](https://jwt.io)

**Você verá:**

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
  "email": "user1@example.com",
  "iat": 1643277731,
  "exp": 1643566531
}
```

**Signature:**
```
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), secret)
```

---

## 💾 Teste 3: Salvar Token para Próximos Testes

Vamos armazenar o token em uma variável de ambiente.

```bash
# Copie o token da resposta anterior e execute:
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Verifique se foi salvo
echo $TOKEN

# Deve imprimir o token completo
```

---

## ✅ Teste 4: Requisição Protegida com Token Válido

Agora vamos usar o token para acessar um endpoint protegido.

### Requisição
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer $TOKEN"
```

### Resposta Esperada (200 OK)
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user1@example.com",
  "name": "User Um"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 200
- [ ] Retorna dados do usuário autenticado
- [ ] Controller conseguiu extrair user_id do token
- [ ] Mesmo user_id do token

### 🔍 Como Funciona
1. Client envia: `Authorization: Bearer TOKEN`
2. JwtAuthenticationFilter intercepta
3. Extrai token do header
4. Valida assinatura e expiração
5. Extrai user_id do token
6. Adiciona ao SecurityContext
7. Controller acessa SecurityContext
8. Retorna dados do usuário

---

## ❌ Teste 5: Requisição Protegida SEM Token

Tentamos acessar endpoint protegido sem token.

### Requisição
```bash
curl -X GET http://localhost:8080/api/me
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Não autenticado"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401 (Unauthorized)
- [ ] Retorna erro claro
- [ ] **Não** permite acesso

---

## ❌ Teste 6: Requisição Protegida com Token INVÁLIDO

Token malformado ou assinado errado.

### Requisição
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer token-invalido-xyz"
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Não autenticado"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401
- [ ] Retorna erro
- [ ] **Não** permite acesso
- [ ] Segurança funcionando! ✅

---

## ❌ Teste 7: Requisição Protegida com Token EXPIRADO

Simulando token expirado (difícil testar, mas vou mostrar como).

### Para Testar Isso Localmente
1. Abra [JWT.io](https://jwt.io)
2. Crie um token com expiração no passado
3. Use `exp: 1516325422` (data passada)
4. Envie requisição

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Não autenticado"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401
- [ ] Token expirado é rejeitado
- [ ] Segurança funcionando! ✅

---

## ❌ Teste 8: Login com Senha ERRADA

Tentamos fazer login com senha incorreta.

### Requisição
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user1@example.com",
    "password": "senha-errada"
  }'
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Email ou senha inválidos"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401
- [ ] Mensagem não diferencia entre "email não existe" e "senha errada"
  - ✅ Segurança: Evita revelar quais emails existem
- [ ] **Não** retorna token

---

## ❌ Teste 9: Login com EMAIL INEXISTENTE

Tentamos fazer login com email que não existe.

### Requisição
```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "inexistente@example.com",
    "password": "qualquer-senha"
  }'
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Email ou senha inválidos"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401
- [ ] Mensagem é **idêntica** ao teste anterior
  - ✅ Segurança: Não revela se email existe ou não
- [ ] **Não** retorna token
- [ ] Atacker não consegue descobrir quais emails estão registrados

---

## ❌ Teste 10: Registrar Mesmo Email DUAS VEZES

Tentamos registrar usuário com email duplicado.

### Primeira Requisição (sucesso)
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "duplicado@example.com",
    "password": "senha123",
    "name": "User Duplicado"
  }'

# Resposta: 201 CREATED ✅
```

### Segunda Requisição (erro)
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "duplicado@example.com",
    "password": "outra-senha",
    "name": "Outro Usuário"
  }'
```

### Resposta Esperada (400 BAD REQUEST)
```json
{
  "error": "Email já registrado"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 400
- [ ] Mensagem clara sobre duplicação
- [ ] **Não** cria usuário duplicado
- [ ] **Não** retorna token
- [ ] Banco de dados protegido (unique constraint)

---

## 🔗 Teste 11: Header Authorization Formato ERRADO

Tentamos usar formato errado para o header.

### Requisição (Falta "Bearer ")
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: $TOKEN"  # ❌ Falta "Bearer"
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Não autenticado"
}
```

### Requisição (Espaço Errado)
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearertoken123"  # ❌ Sem espaço
```

### Resposta Esperada (401 UNAUTHORIZED)
```json
{
  "error": "Não autenticado"
}
```

### ✅ O Que Validar
- [ ] Status HTTP é 401
- [ ] Parser valida formato
- [ ] Segurança funcionando! ✅

---

## 📊 Teste 12: FLUXO COMPLETO

Combine todos os testes em sequência.

### Passo 1: Registre novo usuário
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "completo@example.com",
    "password": "senha123",
    "name": "User Completo"
  }'
# Resposta: 201 CREATED
```

### Passo 2: Faça login
```bash
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "completo@example.com",
    "password": "senha123"
  }' | jq -r '.token')

echo "Token: $TOKEN"
```

### Passo 3: Acesse endpoint protegido
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer $TOKEN"
# Resposta: 200 OK + dados do usuário
```

### Passo 4: Tente sem token
```bash
curl -X GET http://localhost:8080/api/me
# Resposta: 401 UNAUTHORIZED
```

### Passo 5: Tente com token inválido
```bash
curl -X GET http://localhost:8080/api/me \
  -H "Authorization: Bearer token-fake"
# Resposta: 401 UNAUTHORIZED
```

### ✅ O Que Validar
- [ ] Todos os passos funcionam conforme esperado
- [ ] Segurança em todos os pontos
- [ ] Fluxo completo pronto para produção

---

## 🐛 Troubleshooting

### Problema: "Connection refused"
```bash
# PostgreSQL não está rodando
docker-compose up -d db
docker-compose ps

# Aguarde 30 segundos e tente novamente
```

### Problema: "Banco de dados não existe"
```bash
# Crie o banco manualmente
docker-compose exec db psql -U postgres -c "CREATE DATABASE todo_db;"

# Ou re-execute docker-compose
docker-compose down
docker-compose up -d
```

### Problema: "Tabela users não existe"
```bash
# Execute script de inicialização
docker-compose exec db psql -U postgres -d todo_db -f /docker-entrypoint-initdb.d/init.sql

# Ou reinicie tudo
cd backend
docker-compose down
docker-compose up -d
sleep 30
```

### Problema: "Port 8080 already in use"
```bash
# Mate o processo
lsof -ti:8080 | xargs kill -9

# Ou use porta diferente
./mvnw spring-boot:run -Dserver.port=8081
```

### Problema: "Compilation error"
```bash
# Limpe cache
./mvnw clean
rm -rf target/
./mvnw compile
```

---

## 📝 Checklist Final

Após testar tudo, você deve ter aprendido:

```
Conceitos:
[ ] O que é JWT
[ ] Como funciona login
[ ] Diferença entre autenticação e autorização
[ ] Por que criptografar senhas
[ ] Por que usar Bearer token

Prática:
[ ] Testar registro de usuário
[ ] Testar login com credenciais válidas
[ ] Testar login com credenciais inválidas
[ ] Usar token em requisições protegidas
[ ] Validar erros de segurança

Segurança:
[ ] Senhas não são retornadas
[ ] Emails duplicados são bloqueados
[ ] Token inválido é rejeitado
[ ] Token expirado é rejeitado
[ ] Formato correto de header é validado
```

Se todos os boxes estão checked ✅, você domina Login + JWT!

---

## 🎓 Próximos Passos

```
✅ Login + JWT     [TESTADO]
🔄 Todo CRUD       [PRÓXIMO]
   ├── POST /api/todos
   ├── GET /api/todos
   ├── PUT /api/todos/:id
   └── DELETE /api/todos/:id

Todos usar JWT para:
- [ ] Validar autenticação
- [ ] Filtrar dados do usuário
- [ ] Controlar acesso
```

---

**Criado:** 9 de janeiro de 2026
**Status:** ✅ Testes Completos
**Próximo:** Implementar Todo CRUD
