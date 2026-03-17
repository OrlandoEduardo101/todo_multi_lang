# Architecture - Todo Swift

Version: 1.0
Status: Blueprint definido a partir do Flutter em producao no repositorio

## Visao geral

O app iOS nativo deve manter os mesmos principios do Flutter:

- Arquitetura modular por feature
- Separacao por camadas (Presentation, Domain, Data, Infrastructure)
- Tratamento explicito de erro com `Either` (ou Result + erro tipado)
- Fluxo offline-first com banco local como fonte primaria
- Sincronizacao assicrona e resiliente com backend REST

## Estrutura de pastas alvo

```
TodoNative/
├── App/
│   └── Root/
├── Features/
│   ├── Auth/
│   │   ├── Domain/
│   │   │   ├── Models/
│   │   │   ├── Repositories/
│   │   │   └── UseCases/
│   │   ├── Data/
│   │   │   ├── DTOs/
│   │   │   ├── Mappers/
│   │   │   └── Repositories/
│   │   └── Presentation/
│   │       ├── Stores/
│   │       ├── Views/
│   │       └── Components/
│   └── Todo/
│       ├── Domain/
│       ├── Data/
│       └── Presentation/
├── Shared/
│   ├── Core/
│   │   ├── Either/
│   │   ├── Errors/
│   │   └── Reactive/
│   ├── Data/
│   │   ├── Database/
│   │   │   ├── Models/
│   │   │   └── Migrations/
│   │   └── Network/
│   │       ├── Client/
│   │       └── Interceptors/
│   └── UI/
│       ├── Theme/
│       ├── Components/
│       └── Responsive/
├── Resources/
│   ├── Assets.xcassets/
│   └── Localization/
└── Tests/
    ├── Unit/
    ├── Integration/
    └── Snapshot/
```

## Camadas e responsabilidades

### Presentation

- SwiftUI Views e componentes
- Stores (`ObservableObject`) com comandos assincronos
- Nenhuma regra de negocio complexa dentro de View
- Escuta granular de estado por comando

### Domain

- Modelos de dominio (`Todo`, `User`, `AuthSession`)
- Protocolos de repositorio
- Use cases puros

### Data

- Implementacoes de repositorio
- Mappers DTO <-> dominio <-> persistencia
- Orquestracao entre local e remoto

### Infrastructure (Shared/Data)

- Cliente HTTP
- Interceptor de autenticacao
- Persistencia local
- Engine de sync

## Fluxos principais

### 1. App start / Splash

1. Inicializa container de DI
2. Inicia observacao de sessao local
3. Define rota raiz:
- Sessao valida -> Home
- Sessao invalida -> Login

### 2. Login / Register

1. View dispara comando no `AuthStore`
2. Repositorio chama endpoint REST
3. Em sucesso, persiste sessao local
4. `AuthSessionStore` publica atualizacao
5. Roteador move para Home

### 3. Todos offline-first

1. Acao do usuario grava primeiro no banco local
2. Registro recebe `syncStatus` pendente
3. `TodoSyncService` observa pendencias
4. Servico tenta sincronizar com backend
5. Marca como `synced` ou `syncError`

## Contrato de dados

### Todo (dominio)

Campos minimos necessarios:

- `localId: Int?`
- `remoteId: String?`
- `userId: String`
- `title: String`
- `description: String?`
- `completed: Bool`
- `createdAt: Date`
- `updatedAt: Date`
- `syncState: TodoSyncState`

### Session

Sessao local unica (equivalente ao Flutter):

- `token`
- `tokenType`
- `expiresIn`
- `expiresAt`
- `userId`, `userEmail`, `userName`

## Sync engine

Regras do `TodoSyncService` no iOS:

- `pendingCreate` -> POST `/api/todos`
- `pendingUpdate` -> PUT `/api/todos/{id}`
- `pendingDelete` -> DELETE `/api/todos/{id}`
- `syncError` -> reprocessar conforme contexto
- sem `remoteId` em update -> tratar como create

Garantias:

- Execucao serial (um sync por vez)
- Idempotencia onde possivel
- Nao marcar synced se parse de resposta falhar

## Tratamento de erro

Padrao recomendado:

- Repositorios retornam `Either<AppError, Value>`
- Stores convertem erro para estado de comando
- Views mostram feedback local (alert/snackbar equivalente)

## Testabilidade

- Protocolo para todo boundary externo
- Injeção de dependencias em Store e Repository
- Mock simples para HTTP e persistencia
- Testes de:
  - comandos de store
  - reconciliacao de sync
  - transicao de rotas no bootstrap
