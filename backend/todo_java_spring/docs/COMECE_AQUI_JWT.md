# 🎓 Aprenda User Login + JWT em Spring Boot

## Olá! Bem-vindo ao seu Roteiro de Aprendizado 👋

Você está começando a estudar **Spring Boot** e quer aprender sobre **User Login com JWT**.

Este é o melhor momento! Você tem:
- ✅ Código pronto e funcionando
- ✅ Documentação super detalhada
- ✅ Exemplos práticos com cURL
- ✅ Explicações em português
- ✅ Comparação com Go Fiber

**Tempo total:** 6-9 horas para dominar completamente

---

## 📋 Antes de Começar

### Pré-requisitos
```
✅ Java 17+ instalado
✅ Maven instalado (./mvnw pronto)
✅ PostgreSQL rodando (docker-compose)
✅ Noções básicas de Spring Boot (User Registration já feito)
✅ Terminal/Command Line confortável
```

### Ferramentas Úteis
```
✅ cURL (para testar endpoints)
✅ Postman (interface visual, opcional)
✅ Visual Studio Code
✅ https://jwt.io (para inspecionar tokens)
```

---

## 🎯 Roteiro Semana a Semana

### Segunda-feira: Fundamentos (2-3 horas)

**Manhã (1 hora):**
```
[ ] QUICK_START_JWT.md
    └─ Execute 10 testes rápidos
       ├─ Registre usuário
       ├─ Faça login
       ├─ Obtenha token
       └─ Use token em requisição protegida
```

**Tarde (2-3 horas):**
```
[ ] JWT_AND_LOGIN_GUIDE.md - Parte 1
    ├─ Leia: O Que é JWT? (30 min)
    ├─ Leia: Fluxo de Login (45 min)
    └─ Leia: 5 Componentes Principais (45 min)
```

**Exercício:**
```
[ ] Inicie servidor localmente
[ ] Faça login com suas credenciais
[ ] Inspecione token em https://jwt.io
[ ] Veja seu user_id no payload
```

---

### Terça-feira: Componentes (3-4 horas)

**Manhã (1-2 horas):**
```
[ ] Estude código Java comentado
    ├─ JwtTokenProvider.java (30 min)
    │  └─ Entenda generateToken()
    ├─ JwtAuthenticationFilter.java (30 min)
    │  └─ Entenda doFilterInternal()
    └─ SecurityConfig.java (30 min)
       └─ Entenda filterChain()
```

**Tarde (2-2 horas):**
```
[ ] JWT_AND_LOGIN_GUIDE.md - Parte 2
    ├─ Leia: Implementação Passo-a-Passo (60 min)
    └─ Leia: Testando Login + JWT (60 min)
```

**Exercício:**
```
[ ] Abra cada arquivo Java
[ ] Leia os comentários com atenção
[ ] Entenda o que cada método faz
[ ] Trace o fluxo: login() → generateToken() → filter
```

---

### Quarta-feira: Testes Práticos (2-3 horas)

**Manhã (1 hora):**
```
[ ] Setup para testes
    ├─ Inicie servidor
    ├─ Registre 3 usuários diferentes
    └─ Prepare tokens para usar
```

**Tarde (1-2 horas):**
```
[ ] TESTING_LOGIN_JWT.md - Todos os 12 Testes
    ├─ Teste 1-3: Registrar e login
    ├─ Teste 4-6: Token válido, inválido, sem token
    ├─ Teste 7-10: Casos de erro
    └─ Teste 11-12: Fluxo completo
```

**Exercício:**
```
[ ] Execute CADA teste passo a passo
[ ] Veja a resposta completa
[ ] Entenda por que funcionou ou não
[ ] Modifique parâmetros para ver o que muda
```

---

### Quinta-feira: Comparação & Consolidação (2 horas)

**Manhã (1 hora):**
```
[ ] GO_VS_JAVA_COMPARISON.md
    ├─ Leia cada comparação
    │  ├─ DTOs (Go vs Java)
    │  ├─ Buscar usuário (Go vs Java)
    │  ├─ Validar senha (Go vs Java)
    │  ├─ Gerar token (Go vs Java)
    │  └─ Validação de token (Go vs Java)
    └─ Entenda padrões universais
```

**Tarde (1 hora):**
```
[ ] Consolidação
    ├─ Revise conceitos-chave
    ├─ Refaça testes que teve dúvida
    └─ Implemente small feature nova
       ├─ Ex: Adicionar email no JWT payload
       ├─ Ex: Mudar tempo de expiração
       └─ Ex: Alterar mensagem de erro
```

**Exercício:**
```
[ ] Escreva resumo do que aprendeu (seu próprio documento)
[ ] Desenhe fluxo de login à mão
[ ] Liste componentes e responsabilidades
[ ] Aponte diferenças Java vs Go
```

---

## 🎓 Mapa Mental do Que Você Aprenderá

```
┌─────────────────────────────────────────────────────────┐
│              USER LOGIN + JWT                           │
└──────────────┬──────────────────────────────────────────┘
               │
    ┌──────────┼──────────┬────────────┬─────────────┐
    │          │          │            │             │
    ▼          ▼          ▼            ▼             ▼
   JWT     COMPONENTES  FLUXO        SEGURANÇA    TESTES
   │       │            │            │             │
   ├─ O que é?   ├─ Tokens     ├─ Cliente envia  ├─ BCrypt
   ├─ Header     ├─ Filters    ├─ Service        ├─ HMAC
   ├─ Payload    ├─ Config     ├─ Provider       ├─ Validação
   ├─ Signature  ├─ Service    ├─ Filter         ├─ Expiração
   └─ Claims     └─ Controller └─ Response       └─ Ambigu.
```

---

## 🧠 Conceitos que Vai Dominar

### JWT (Token Seguro)
- ✅ O que é e por que usar
- ✅ 3 partes: Header, Payload, Signature
- ✅ Como assinar com HMAC-SHA256
- ✅ Como validar assinatura
- ✅ Expiração de token

### Spring Boot (Framework)
- ✅ @Component, @Service, @Autowired
- ✅ DTOs (Data Transfer Objects)
- ✅ Injeção de Dependência
- ✅ ResponseEntity e Status HTTP
- ✅ Filters e Interceptors

### Autenticação (Fluxo)
- ✅ Registrar usuário
- ✅ Fazer login
- ✅ Gerar token
- ✅ Usar token em requisições
- ✅ Validar token

### Segurança (Best Practices)
- ✅ BCrypt para senhas
- ✅ Mensagens de erro ambíguas
- ✅ CORS (Cross-origin)
- ✅ Bearer token no header
- ✅ Endpoints públicos vs privados

---

## 🚀 Como Começar Agora

### Opção 1: 10 Minutos (Quick Test)
```bash
# Terminal 1: Inicie servidor
cd backend/todo_java_spring
./mvnw spring-boot:run

# Terminal 2: Execute quick start
cat QUICK_START_JWT.md
# Siga os testes!
```

### Opção 2: 3 Horas (Aprendizado Prático)
```bash
1. QUICK_START_JWT.md (10 min) - teste rápido
2. JWT_AND_LOGIN_GUIDE.md (2h) - leia fundamental
3. Código comentado (30 min) - estude
4. Execute testes (30 min) - pratique
```

### Opção 3: 8 Horas (Domínio Completo)
```bash
1. Dia 1: Fundamentos + Quick Start
2. Dia 2: Componentes + Código
3. Dia 3: Testes Práticos + Go vs Java
4. Dia 4: Revisão + Implementar Feature Nova
```

---

## 📚 Qual Documento Ler Quando?

| Situação | Arquivo | Tempo |
|----------|---------|-------|
| Quer começar JÁ! | QUICK_START_JWT.md | 10 min |
| Quer entender tudo | JWT_AND_LOGIN_GUIDE.md | 2-3h |
| Quer testar | TESTING_LOGIN_JWT.md | 1-2h |
| Quer comparar | GO_VS_JAVA_COMPARISON.md | 30 min |
| Está perdido | LEARNING_INDEX.md | 5 min |

---

## 💡 Dicas para Sucesso

### 1. Não Pule Etapas
```
❌ ERRADO: Pular para testes sem entender JWT
✅ CERTO: JWT → Fluxo → Componentes → Testes
```

### 2. Teste Frequentemente
```
Após cada seção:
[ ] Execute um teste
[ ] Veja funcionando
[ ] Mude parâmetros
[ ] Quebre e conserte
```

### 3. Leia Código Comentado
```
Cada arquivo Java tem comentários detalhados
Não pule os comentários!
Eles explicam o "por quê"
```

### 4. Use https://jwt.io
```
Cole seu token para inspecionar
Veja header, payload, signature
Entenda a estrutura
```

### 5. Mantenha Analogias
```
JWT é como uma "carteirinha de identificação"
Bearer token é como "mostrar a carteirinha"
Expiração é como "carteirinha vencer"
```

---

## ❓ Dúvidas Comuns

### "Por que JWT e não Session?"
```
JWT:
- Cliente armazena token
- Não precisa consultar banco toda vez
- Perfeito para REST API
- Funciona cross-domain
- Stateless (servidor não guarda nada)

Session:
- Servidor guarda dados da sessão
- Cookie no cliente
- Tradicional, mas mais custoso
- Pior para REST API
```

### "Por que BCrypt e não encrypt?"
```
BCrypt:
- NÃO reversível (não pode descriptografar)
- Com salt (mais seguro contra dicionário)
- Mais lento propositalmente (contra força bruta)
- Padrão da indústria

Encrypt:
- Reversível (pode descriptografar)
- Se alguém roubar a chave, tudo vaza
- Não deve usar para senhas
```

### "Token nunca expira? Pode roubá-lo!"
```
Por isso tem expiração:
- Token válido por 3 dias
- Após expiração, precisa fazer login novamente
- Se token for roubado, acesso é temporário
- Implementar refresh token para renovar
```

### "Como autenticar se token expirou?"
```
Cliente recebe 401 Unauthorized
Cliente faz login novamente (credenciais)
Recebe novo token
Continua usando novo token

Ou (futuro):
- Implementar refresh token
- Renovar sem fazer login novamente
```

---

## 📊 Seu Progresso

Acompanhe seu aprendizado:

```
Semana 1:
  [ ] Entendi o que é JWT
  [ ] Entendi fluxo de login
  [ ] Consegui fazer login
  [ ] Consegui usar token

Semana 2:
  [ ] Entendi cada componente
  [ ] Consegui ler código
  [ ] Consegui rastrear fluxo
  [ ] Consegui testar tudo

Semana 3:
  [ ] Entendo segurança
  [ ] Consigo comparar Go vs Java
  [ ] Consegui modificar código
  [ ] Posso explicar para alguém
```

---

## 🎁 Bonus: Próximos Passos

Após dominar User Login + JWT, você pode aprender:

```
1. Todo CRUD (usando JWT)
   ├─ Criar todo
   ├─ Listar todos do usuário autenticado
   ├─ Atualizar todo
   └─ Deletar todo (soft delete)

2. Filtering & Pagination
   ├─ Filtrar por search, completed
   ├─ Paginar resultados
   └─ Ordenar por campo

3. Authorization (Roles)
   ├─ Admin vs User
   ├─ Diferentes permissões
   └─ Proteger endpoints por role

4. Testes Automatizados
   ├─ Unit tests (JUnit)
   ├─ Integration tests
   └─ E2E tests
```

---

## 🎯 Objetivo Final

Após 8 horas de estudo, você será capaz de:

```
✅ Explicar JWT sem olhar anotação
✅ Desenhar fluxo de login manualmente
✅ Implementar novo endpoint protegido
✅ Debugar problema de autenticação
✅ Testar segurança de API
✅ Comparar diferentes abordagens
✅ Ensinar alguém sobre JWT
✅ Modificar configuração de segurança
✅ Lidar com tokens expirados
✅ Implementar refresh tokens (futuro)
```

---

## 🏁 Está Pronto?

```
[ ] Java 17+ instalado
[ ] PostgreSQL rodando
[ ] Projeto clonado
[ ] Maven funcionando
[ ] Terminal aberto

SIM? Então:

👉 cd backend/todo_java_spring
👉 cat QUICK_START_JWT.md
👉 COMECE AGORA! 🚀
```

---

## 📞 Precisa de Ajuda?

### Se não sabe por onde começar
→ Leia LEARNING_INDEX.md

### Se quer teste rápido
→ Leia QUICK_START_JWT.md

### Se quer aprender tudo
→ Leia JWT_AND_LOGIN_GUIDE.md

### Se quer testar na prática
→ Leia TESTING_LOGIN_JWT.md

### Se quer comparar linguagens
→ Leia GO_VS_JAVA_COMPARISON.md

---

## 🎓 Feliz Aprendizado!

```
╔════════════════════════════════════════════════════╗
║  Você está prestes a dominar JWT em Spring Boot!  ║
║                                                    ║
║  Tempo: 6-9 horas                                 ║
║  Qualidade: ⭐⭐⭐⭐⭐                              ║
║  Resultado: Production-ready code + Educacional   ║
║                                                    ║
║  Bom estudo! 📚                                    ║
╚════════════════════════════════════════════════════╝
```

---

**Criado:** 9 de janeiro de 2026  
**Status:** ✅ Pronto para começar  
**Próximo passo:** QUICK_START_JWT.md  
**Tempo:** 10 minutos
