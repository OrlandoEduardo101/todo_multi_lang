# TODO Vaden Backend

API REST para gerenciamento de tarefas usando **Vaden Framework** em Dart com arquitetura hexagonal.

## 🚀 Rápido Início

### Pré-requisitos
- Dart >= 3.0.0
- PostgreSQL >= 12
- Docker (opcional)

### Setup Local

```bash
# 1. Clonar e instalar dependências
cd backend/todo_dart_vaden
dart pub get

# 2. Configurar banco de dados
# Criar arquivo .env (copiar de .env.example)
cp .env.example .env

# 3. Executar migrações do BD
dart run lib/config/migration/migration.dart

# 4. Rodar servidor
dart run bin/server.dart
```

O servidor estará em `http://localhost:8080`

### Docker

```bash
docker-compose up -d
```

## 📚 Documentação

- **[Arquitetura](docs/ARCHITECTURE.md)** - Visão geral da arquitetura hexagonal
- **[Guia de Desenvolvimento](docs/DEVELOPMENT_GUIDE.md)** - Como adicionar novas features
- **[API Docs](http://localhost:8080/docs/swagger)** - Swagger interativo

## 🔐 Autenticação

### Endpoints Públicos
- `POST /auth/register` - Registrar usuário
- `POST /auth/login` - Login (retorna JWT)

### Usar Token
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:8080/api/todos
```

## 📦 Stack Tecnológico

| Tecnologia | Versão | Propósito |
|-----------|--------|-----------|
| Vaden | ^3.0.0 | Framework web |
| Dart | >=3.0.0 | Linguagem |
| PostgreSQL | ^12 | Banco de dados |
| Result Dart | ^1.2.0 | Tratamento de erros |

## 🏗️ Estrutura do Projeto

```
todo_dart_vaden/
├── bin/
│   └── server.dart           # Entrypoint
├── lib/
│   ├── src/
│   │   ├── domain/           # Lógica de negócio
│   │   │   ├── entities/
│   │   │   ├── dto/
│   │   │   ├── repositories/
│   │   │   ├── usecases/
│   │   │   └── enums/
│   │   ├── data/             # Implementações
│   │   │   └── repositories/
│   │   └── controllers/      # HTTP endpoints
│   └── config/               # Setup e configurações
├── migrations/               # SQL migrations
├── test/                     # Testes
├── docs/                     # Documentação
└── pubspec.yaml             # Dependências
```

## 🛣️ Roadmap

- [x] Setup projeto inicial
- [ ] Implementar features de TODO (CRUD)
- [ ] Autenticação JWT
- [ ] Testes unitários
- [ ] Documentação Swagger
- [ ] Docker support
- [ ] CI/CD pipeline

## 📝 Features

### ✅ Implementadas
- Arquitetura hexagonal
- Setup base Vaden
- Configurações de BD

### 🔄 Em Desenvolvimento
- CRUD de TODO
- Autenticação

### 📋 Planejadas
- Comentários em TODOs
- Compartilhamento de tarefas
- Filtros avançados
- Webhooks
- Rate limiting

## 🤝 Contribuindo

Veja [DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md) para mais detalhes.

## 📄 Licença

MIT

## 🆘 Suporte

Dúvidas? Abra uma issue ou veja a documentação do [Vaden](https://doc.vaden.dev).
