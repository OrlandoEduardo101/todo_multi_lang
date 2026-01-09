# 🎯 START HERE - User Registration em Spring Boot

## 📌 Você Quer Aprender Spring Boot?

Se respondeu **SIM**, você está no lugar certo! ��

Este é um **projeto educacional** onde implementamos **User Registration** em Spring Boot.

---

## 📚 Roteiro de Leitura (Obrigatório)

### 1️⃣ **PRIMEIRO** - Este arquivo (5 min)
👉 Você está aqui agora ✓

### 2️⃣ **SEGUNDO** - README_SPRING.md (10 min)
```bash
cat README_SPRING.md
```
- Setup rápido
- Overview do projeto
- Como testar

### 3️⃣ **TERCEIRO** - STRUCTURE.md (10 min)
```bash
cat STRUCTURE.md
```
- Árvore de diretórios
- Quais arquivos fazer o quê
- Fluxo de requisição

### 4️⃣ **QUARTO** - IMPLEMENTATION_SUMMARY.md (15 min)
```bash
cat IMPLEMENTATION_SUMMARY.md
```
- Visão geral da feature
- Diagramas
- O que foi criado

### 5️⃣ **QUINTO** - USER_REGISTRATION_GUIDE.md (60 min) ⭐ PRINCIPAL
```bash
cat USER_REGISTRATION_GUIDE.md
```
- Explicação completa
- Cada componente em detalhe
- Conceitos Spring Boot
- Exemplos de código

### 6️⃣ **SEXTO** - SPRING_PATTERNS_REFERENCE.md (30 min)
```bash
cat SPRING_PATTERNS_REFERENCE.md
```
- Padrões reutilizáveis
- Código pronto para copiar
- Exemplos de CRUD

---

## ✅ Checklist Rápido

```
[ ] Setup (5 min)
    ├── Leu START_HERE.md
    ├── Compilou: ./mvnw clean compile
    └── Entendeu a estrutura

[ ] Aprendizado (2 horas)
    ├── Leu todos os .md
    ├── Estudou o código fonte
    └── Entendeu o fluxo

[ ] Prática (1 hora)
    ├── Executou: ./mvnw spring-boot:run
    ├── Testou com cURL
    └── Experimentou com Postman

[ ] Domínio (2+ horas)
    ├── Leu USER_REGISTRATION_GUIDE.md completo
    ├── Estudou SPRING_PATTERNS_REFERENCE.md
    └── Pronto para User Login
```

---

## 🚀 Quick Start (3 minutos)

### 1. Compile
```bash
cd backend/todo_java_spring
./mvnw clean compile -DskipTests
```

### 2. Execute
```bash
./mvnw spring-boot:run
# Aguarde: "Started TodoApplication in..."
```

### 3. Teste
```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu@email.com",
    "password": "senha123",
    "name": "Seu Nome"
  }'

# Resposta esperada (201):
# {"id": "uuid-aqui", "email": "seu@email.com", "name": "Seu Nome"}
```

---

## 📊 O Que Você Aprenderá

### Conceitos Spring Boot
- ✅ `@RestController` - Controllers REST
- ✅ `@Service` - Lógica de negócio
- ✅ `@Repository` - Acesso a dados
- ✅ `@Autowired` - Injeção de dependência
- ✅ `@PostMapping` - HTTP POST handlers
- ✅ `ResponseEntity` - Controlar HTTP status

### Padrões de Arquitetura
- ✅ **MVC Pattern** (Model-View-Controller)
- ✅ **Layered Architecture** (Camadas)
- ✅ **DTO Pattern** (Data Transfer Objects)
- ✅ **Repository Pattern** (Data access)
- ✅ **Dependency Injection** (IoC)

### Segurança
- ✅ **BCrypt** - Hash de password
- ✅ **Password Encoding** - Spring Security
- ✅ **Validações** - Input validation

### Database
- ✅ **JPA/Hibernate** - ORM
- ✅ **PostgreSQL** - Database
- ✅ **Entity Mapping** - @Entity, @Column

---

## 🏗️ Arquitetura Visual

```
┌──────────────────────────────────────┐
│        HTTP Request (JSON)           │
│  POST /auth/register                 │
│  {email, password, name}             │
└──────────────┬───────────────────────┘
               │
        ┌──────▼──────┐
        │  Controller  │  ← Recebe HTTP
        │   (HTTP)     │
        └──────┬───────┘
               │
        ┌──────▼──────┐
        │   Service    │  ← Lógica de Negócio
        │  (Business)  │
        └──────┬───────┘
               │
        ┌──────▼──────┐
        │ Repository   │  ← Acesso a Dados
        │   (Data)     │
        └──────┬───────┘
               │
        ┌──────▼──────┐
        │  Database    │  ← PostgreSQL
        │   (SQL)      │
        └──────┬───────┘
               │
        ┌──────▼──────┐
        │  Response    │  ← JSON (sem password!)
        │   (201)      │
        └──────────────┘
```

---

## 🔐 Fluxo de Segurança

```
1. Cliente envia: {"password": "123456"}

2. Controller recebe e desserializa

3. Service valida email

4. BCryptPasswordEncoder.encode("123456")
   ↓
   Hash: "$2a$10$..." (NUNCA reversível!)

5. Repository salva hash no banco

6. Retorna UserResponse (SEM password)

7. Cliente recebe: {"id": "...", "email": "..."}
```

**Nunca enviamos/armazenamos a senha em texto plano!**

---

## 📁 Arquivos Principais

| Arquivo | Função | Status |
|---------|--------|--------|
| `AuthController.java` | HTTP endpoints | ✅ Pronto |
| `UserService.java` | Lógica | ✅ Pronto |
| `UserRepository.java` | Banco de dados | ✅ Pronto |
| `User.java` | Entidade JPA | ✅ Pronto |
| `RegisterRequest.java` | DTO entrada | ✅ Pronto |
| `UserResponse.java` | DTO saída | ✅ Pronto |
| `SecurityConfig.java` | Configuração | ✅ Pronto |

---

## 🧪 Testando

### Com cURL (Linux/Mac)
```bash
# Registre um usuário
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123","name":"Test"}'

# Teste email duplicado (erro)
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"456","name":"Outro"}'
```

### Com Postman (GUI)
1. POST → `http://localhost:8080/auth/register`
2. Body → Raw → JSON
3. Envie!

### Com HTTPie
```bash
http POST http://localhost:8080/auth/register \
  email=test@test.com password=123 name=Test
```

---

## 📖 Documentação Completa

```
START_HERE.md                    ← Você está aqui
README_SPRING.md                 ← Setup e overview
STRUCTURE.md                     ← Estrutura de arquivos
IMPLEMENTATION_SUMMARY.md        ← Resumo da implementação
USER_REGISTRATION_GUIDE.md       ← GUIA COMPLETO (LEIA!)
SPRING_PATTERNS_REFERENCE.md     ← Padrões reutilizáveis
LEARNING_SUMMARY.md              ← Sumário de aprendizado
```

---

## 🎯 Próximos Passos

```
Fase 1: User Registration ✅ CONCLUÍDO
└── Entender: AuthController → UserService → Repository

Fase 2: User Login (PRÓXIMO)
├── Implementar JWT
├── Criar JwtTokenProvider
└── Criar LoginController

Fase 3: Todo CRUD
├── TodoController
├── TodoService
├── TodoRepository
└── Todo Entity

Fase 4: Advanced
├── Filtering
├── Pagination
├── Authorization
└── Tests
```

---

## 💡 Dicas para Sucesso

1. **Leia na ordem**
   - Não pule etapas
   - Cada arquivo prepara para o próximo

2. **Entenda o fluxo**
   - Controller → Service → Repository → Database

3. **Teste frequentemente**
   - Use cURL entre cada seção

4. **Estude o código**
   - Leia os comentários
   - Entenda cada linha

5. **Compare com Go Fiber**
   - Veja a mesma lógica em outra linguagem
   - Aprenda padrões universais

---

## 🆘 Problemas Comuns

### "Port 8080 already in use"
```bash
lsof -ti:8080 | xargs kill -9
./mvnw spring-boot:run
```

### "Connection refused - PostgreSQL"
```bash
# Volte para docker/
cd ../..
docker-compose up -d db
# Espere 30 segundos
cd backend/todo_java_spring
./mvnw spring-boot:run
```

### "Compilation error"
```bash
./mvnw clean compile
# Se persistir: remova target/
rm -rf target/
./mvnw clean compile
```

---

## 🎓 Avaliação de Aprendizado

Após estudar, você deve conseguir:

```
[ ] Explicar o fluxo: Controller → Service → Repository
[ ] Entender injeção de dependência (@Autowired)
[ ] Usar DTOs para entrada/saída
[ ] Explicar por que criptografar senhas
[ ] Testar API com cURL
[ ] Entender ResponseEntity e status codes
[ ] Adicionar uma nova validação no Service
[ ] Implementar User Login (próximo passo)
```

Se consegue fazer tudo, **parabéns!** 🎉

---

## 📞 Precisa de Ajuda?

1. **O que fazer?** → Leia README_SPRING.md
2. **Como funciona?** → Leia USER_REGISTRATION_GUIDE.md
3. **Que padrão usar?** → Veja SPRING_PATTERNS_REFERENCE.md
4. **Qual arquivo?** → Consulte STRUCTURE.md

---

## 🚀 Começar Agora!

```bash
# 1. Entre no diretório
cd backend/todo_java_spring

# 2. Compile
./mvnw clean compile -DskipTests

# 3. Execute
./mvnw spring-boot:run

# 4. Em outro terminal, teste
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"seu@email.com","password":"senha","name":"Seu Nome"}'

# 5. Leia a documentação
cat README_SPRING.md
```

---

## 📊 Resumo Executivo

| O Quê | Status | Tempo | Próximo |
|-------|--------|-------|---------|
| User Registration | ✅ Pronto | 2-3h | User Login |
| Code Examples | ✅ Pronto | - | - |
| Documentation | ✅ Completo | - | - |
| Tests | 🔄 Planejado | - | Fase 4 |

---

## ✨ Feliz Aprendizado!

```
🎓 Você está aprendendo Spring Boot
🚀 Com um projeto real
📚 Com documentação completa
💻 Pronto para evoluir

Boa sorte! 🍀
```

---

**Criado:** 9 de janeiro de 2026  
**Status:** ✅ Pronto para começar  
**Próximo:** Leia README_SPRING.md  
**Tempo estimado:** 3-5 horas (completo)

**👉 Próximo passo: `cat README_SPRING.md`**
