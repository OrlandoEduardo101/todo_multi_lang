# Flutter to iOS Mapping

Este documento mapeia cada decisao tecnica do app Flutter para equivalentes iOS nativos.

## Mapeamento de arquitetura

- Flutter `lib/app` (paginas) -> iOS `Features/*/Presentation/Views`
- Flutter `stores` com `RxCommand` -> iOS `ObservableObject` com comandos assincronos e estado publicado
- Flutter `repositories` (interface + impl) -> iOS protocolos + implementacoes
- Flutter `shared/http/HttpClient` -> iOS protocolo `HTTPClient` com implementacao `URLSessionHTTPClient`
- Flutter Drift `AppDatabase` -> iOS `SwiftData` ou `CoreData` com repositorio local
- Flutter `TodoSyncService` -> iOS `TodoSyncService` com fila por `syncStatus`

## Mapeamento de estado (RxCommand)

Flutter atual usa `isExecuting`, `completed`, `error`, `value`.

Equivalente iOS sugerido:

- `CommandState<Value>`
- `isExecuting: Bool`
- `didComplete: Bool`
- `errorMessage: String?`
- `value: Value?`

Uso:

- Store publica comandos separados (`loginCommand`, `registerCommand`, `syncTodosCommand`, etc.)
- View observa apenas o comando necessario
- Evitar rebuild global de tela quando so um comando muda

## Mapeamento de dados offline-first

Tabela `todos` no Flutter possui:

- `id` local
- `remoteId`
- `title`, `description`, `done`
- `createdAt`, `updatedAt`
- `syncStatus`
- `lastSyncedAt`, `deletedAt`

No iOS, manter os mesmos campos (nomes podem adaptar para Swift style), preservando semantica de sincronizacao:

- `pendingCreate`
- `pendingUpdate`
- `pendingDelete`
- `synced`
- `syncError`

## Mapeamento de autenticacao

Flutter:

- `Sessions` table com linha unica (`id=1`)
- `AuthSessionStore` observa sessao e fornece header bearer
- Interceptor limpa sessao em 401

iOS equivalente:

- Entidade local `SessionEntity` unica
- `AuthSessionStore` com `@Published session`
- Injetar token em todas as requests privadas
- Em 401, limpar sessao e redirecionar para login

## Mapeamento de navegacao

Flutter:

- Routefly gera rotas por arquivo em `lib/app`
- `navigate` substitui stack, `push` empilha

iOS:

- `NavigationStack` + `NavigationPath`
- `AppRouter` centralizado com:
  - `setRoot(.splash | .auth | .home)`
  - `push(route)`
  - `pop()`

## Mapeamento de UI e responsividade

Flutter:

- Breakpoints: 768 tablet, 1200 desktop
- `ResponsiveLayoutWidget`

iOS:

- iPhone/iPad: classes de tamanho + largura disponivel
- Breakpoints sugeridos:
  - compact < 768
  - regular >= 768
- Reusar componentes e manter regra de 3 camadas por tela:
  - Orquestracao
  - Layout
  - Componentes visuais
