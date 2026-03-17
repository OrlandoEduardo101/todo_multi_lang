# Flutter Project Analysis (Fonte para o Refactor iOS)

Este documento resume o que foi identificado no projeto Flutter real e serve como referencia de paridade funcional.

## Funcionalidades identificadas

- Splash com decisao de rota por estado de autenticacao
- Login e cadastro com validacao de formulario
- Persistencia local de sessao JWT
- Home com:
  - listagem de tarefas observada em tempo real
  - criar tarefa
  - marcar concluida/pendente
  - excluir tarefa
  - sincronizacao manual
- Sincronizacao automatica em background de tarefas pendentes

## Estrategia de estado

- Padrao command reativo proprio (`RxCommand`, `StreamRxCommand`)
- Cada acao relevante possui comando separado
- Views escutam comando especifico, nao store inteiro
- Estados observados por comando: executando, concluido, erro, valor

## Estrategia de dados

- Persistencia local via Drift/SQLite
- `todos` com metadados de sync (`syncStatus`, `remoteId`, `lastSyncedAt`, `deletedAt`)
- Repositorio de todo opera em offline-first:
  - grava local primeiro
  - sync posterior
- Reconciliacao de inconsistencias legado (`synced` sem `remoteId`)

## Estrategia de rede

- `HttpClient` abstrato com implementacao Dio
- Interceptor de auth injeta bearer token
- Em 401, sessao local e limpa

## Estrategia de arquitetura

- Modulos `Auth` e `Todo`
- DI centralizada em um unico root injector
- Contratos de repositorio no dominio
- Retornos de repositorio com `Either<AppException, T>`

## Navegacao

- Routefly com geracao automatica de rotas a partir de `lib/app`
- Rotas principais: `/splash`, `/auth/login`, `/auth/register`, `/home`
- `navigate` para trocar stack completa; `push` para empilhar

## Design e UI

- Material 3
- Tema dark com gradientes fortes em splash/auth
- Home usa componentes padrao e feedback de sync por cor + label
- Responsividade por largura:
  - mobile
  - tablet
  - desktop
- Breakpoints observados: 768 e 1200

## Regras de implementacao relevantes para iOS

- Manter tela como orquestradora, sem regra de negocio interna
- Manter componente visual desacoplado de store
- Manter listeners e ciclo de vida explicitamente controlados
- Preservar labels e semantica de estado de sync

## Arquivos Flutter chave analisados

- `lib/main.dart`
- `lib/app/app_widget.dart`
- `lib/app/splash_page.dart`
- `lib/app/auth/login/login_page.dart`
- `lib/app/auth/register/register_page.dart`
- `lib/app/home/home_page.dart`
- `lib/src/root_biding.dart`
- `lib/src/shared/reactive_ui/rx_command.dart`
- `lib/src/modules/auth/stores/auth_store.dart`
- `lib/src/modules/auth/stores/auth_session_store.dart`
- `lib/src/modules/auth/repositories/auth_repository.dart`
- `lib/src/modules/todo/stores/todo_store.dart`
- `lib/src/modules/todo/repositories/todo_repository.dart`
- `lib/src/modules/todo/services/todo_sync_service.dart`
- `lib/src/shared/database/app_database.dart`
- `lib/src/shared/database/tables/todos_table.dart`
- `lib/src/shared/database/tables/auth_table.dart`
- `lib/src/shared/http/dio_http_client.dart`
- `lib/src/shared/http/interceptors/auth_interceptor.dart`
- `lib/src/shared/widgets/responsive_layout_widget.dart`
