# 14-Day Learning Plan - Reimplementar Todo Flutter em iOS Nativo

Este plano foi desenhado para alguem com boa bagagem em Flutter e pouca experiencia em iOS nativo, com foco em aprender fazendo e manter paridade funcional com o app Flutter existente.

## Regra do jogo

Objetivo de cada dia:

- aprender 1 ou 2 conceitos nativos relevantes
- entregar algo que roda
- preservar equivalencia arquitetural com o Flutter

Carga sugerida por dia:

- 1h a 3h de implementacao
- 20 a 30 min de leitura pontual
- 10 min de anotacoes de aprendizado

## Dia 1 - Preparar ambiente e criar o app shell

### Objetivo

Criar o projeto iOS nativo base e entender o ciclo de vida minimo de um app SwiftUI.

### Aprender

- estrutura basica de um projeto SwiftUI
- `@main`, `App`, `WindowGroup`
- diferenca entre SwiftUI App e AppDelegate legado

### Entrega

- criar `TodoNative.xcodeproj` ou `TodoNative.xcworkspace`
- configurar target iOS
- criar `TodoApp`
- criar `RootView` placeholder
- garantir que compila e abre no simulador

### Arquivos-alvo

- `TodoNative/App/Root/todo_app.swift`
- `TodoNative/App/Root/root_view.swift`

### Criterio de pronto

- app abre no simulador com tela inicial simples

## Dia 2 - Montar composition root e DI container

### Objetivo

Reproduzir no iOS o papel do `rootModule` do Flutter.

### Aprender

- injecao por construtor em Swift
- composition root
- quando usar singleton vs factory

### Entrega

- criar `AppContainer`
- registrar dependencias base vazias/mocks
- injetar dependencias da root view

### Arquivos-alvo

- `TodoNative/App/Root/app_container.swift`
- `TodoNative/Shared/Core/Errors/app_error.swift`
- `TodoNative/Shared/Core/Either/either.swift`

### Criterio de pronto

- `RootView` recebe dependencias do container, sem instanciar nada diretamente

## Dia 3 - Criar router nativo e fluxo de rotas principal

### Objetivo

Mapear o comportamento do Routefly para uma abordagem iOS simples.

### Aprender

- `NavigationStack`
- `NavigationPath`
- roteamento orientado a estado

### Entrega

- criar `AppRoute`
- criar `AppRouter`
- suportar `setRoot`, `push` e `pop`
- registrar rotas `splash`, `login`, `register`, `home`

### Arquivos-alvo

- `TodoNative/App/Root/app_route.swift`
- `TodoNative/App/Root/app_router.swift`

### Criterio de pronto

- navegacao entre placeholders das quatro telas

## Dia 4 - Modelos de dominio e command state

### Objetivo

Criar a espinha dorsal do dominio e do padrao de estado equivalente ao `RxCommand`.

### Aprender

- `ObservableObject`
- `@Published`
- modelagem de estado assincrono em Swift

### Entrega

- criar `CommandState<Value>`
- criar modelos de dominio de auth e todo
- criar enum `TodoSyncState`

### Arquivos-alvo

- `TodoNative/Shared/Core/Reactive/command_state.swift`
- `TodoNative/Features/Auth/Domain/Models/auth_session.swift`
- `TodoNative/Features/Auth/Domain/Models/user.swift`
- `TodoNative/Features/Todo/Domain/Models/todo.swift`

### Criterio de pronto

- tipos de dominio compilam e podem ser usados pelas stores

## Dia 5 - Persistencia local de sessao

### Objetivo

Implementar a parte mais simples e valiosa da persistencia primeiro: sessao autenticada.

### Aprender

- UserDefaults vs Keychain vs persistencia estruturada
- quando usar Keychain para token

### Entrega

- criar `SessionStore` persistente
- armazenar token, expiracao e dados do usuario
- expor estado autenticado reativo

### Arquivos-alvo

- `TodoNative/Shared/Data/Database/Models/session_entity.swift`
- `TodoNative/Features/Auth/Presentation/Stores/auth_session_store.swift`
- `TodoNative/Features/Auth/Data/Repositories/local_session_repository.swift`

### Criterio de pronto

- sessao pode ser salva, lida e limpa localmente

## Dia 6 - Splash e auth guard

### Objetivo

Reimplementar o comportamento da `SplashPage` do Flutter.

### Aprender

- side effects em `onAppear`
- decisao de rota baseada em estado observado

### Entrega

- criar `SplashView`
- decidir rota conforme sessao local valida/invalida
- animacao simples opcional

### Arquivos-alvo

- `TodoNative/Features/Auth/Presentation/Views/splash_view.swift`
- `TodoNative/App/Root/root_view.swift`

### Criterio de pronto

- splash encaminha corretamente para login ou home

## Dia 7 - Camada HTTP e auth repository

### Objetivo

Preparar rede e autenticação remota.

### Aprender

- `URLSession`
- `Codable`
- request/response mapping

### Entrega

- criar protocolo `HTTPClient`
- implementar `URLSessionHTTPClient`
- criar DTOs de auth
- criar `AuthRepository`

### Arquivos-alvo

- `TodoNative/Shared/Data/Network/Client/http_client.swift`
- `TodoNative/Shared/Data/Network/Client/url_session_http_client.swift`
- `TodoNative/Features/Auth/Data/DTOs/login_request_dto.swift`
- `TodoNative/Features/Auth/Data/DTOs/auth_response_dto.swift`
- `TodoNative/Features/Auth/Data/Repositories/auth_repository_impl.swift`

### Criterio de pronto

- login/register conseguem falar com o backend

## Dia 8 - Login screen completa

### Objetivo

Entregar a primeira tela funcional fim a fim.

### Aprender

- formularios em SwiftUI
- `TextField`, `SecureField`, validacao simples
- binding de estado

### Entrega

- criar `AuthStore`
- implementar `loginCommand`
- criar `LoginView`
- mostrar loading e erro
- em sucesso, salvar sessao e navegar para home

### Arquivos-alvo

- `TodoNative/Features/Auth/Presentation/Stores/auth_store.swift`
- `TodoNative/Features/Auth/Presentation/Views/login_view.swift`
- `TodoNative/Features/Auth/Presentation/Components/auth_login_form_view.swift`

### Criterio de pronto

- login funcional com backend real

## Dia 9 - Register screen completa

### Objetivo

Replicar o segundo fluxo de autenticacao.

### Aprender

- validacao de confirmacao de senha
- navegacao entre login e cadastro

### Entrega

- implementar `registerCommand`
- criar `RegisterView`
- reaproveitar componentes visuais quando fizer sentido

### Arquivos-alvo

- `TodoNative/Features/Auth/Presentation/Views/register_view.swift`
- `TodoNative/Features/Auth/Presentation/Components/auth_register_form_view.swift`

### Criterio de pronto

- cadastro funcional com persistencia de sessao

## Dia 10 - Persistencia local de todos

### Objetivo

Construir a base offline-first antes do sync.

### Aprender

- SwiftData ou Core Data na pratica
- repositorio local observavel

### Entrega

- modelar entidade local de todo
- persistir lista de todos
- incluir campos de sync equivalentes ao Flutter
- criar repository local observavel

### Arquivos-alvo

- `TodoNative/Shared/Data/Database/Models/todo_entity.swift`
- `TodoNative/Features/Todo/Data/Mappers/todo_mapper.swift`
- `TodoNative/Features/Todo/Data/Repositories/local_todo_repository.swift`

### Criterio de pronto

- listar e salvar todos localmente sem rede

## Dia 11 - Home screen offline-first

### Objetivo

Entregar a tela principal com CRUD local funcional.

### Aprender

- listas em SwiftUI
- swipe actions / delete
- sheets ou alerts para criacao

### Entrega

- criar `TodoStore`
- implementar watch local da lista
- criar tarefa
- alternar concluido
- excluir tarefa
- refletir status de sync na UI

### Arquivos-alvo

- `TodoNative/Features/Todo/Presentation/Stores/todo_store.swift`
- `TodoNative/Features/Todo/Presentation/Views/home_view.swift`
- `TodoNative/Features/Todo/Presentation/Components/todo_row_view.swift`
- `TodoNative/Features/Todo/Presentation/Components/todo_sync_badge_view.swift`

### Criterio de pronto

- home completamente funcional offline

## Dia 12 - Sync engine

### Objetivo

Implementar o coracao do diferencial arquitetural do projeto.

### Aprender

- tarefas assincronas em sequencia
- reconciliacao local/remota
- retry simples

### Entrega

- criar `TodoSyncService`
- processar `pendingCreate`, `pendingUpdate`, `pendingDelete`, `syncError`
- adicionar sync manual

### Arquivos-alvo

- `TodoNative/Features/Todo/Data/Services/todo_sync_service.swift`
- `TodoNative/Features/Todo/Data/Repositories/todo_repository_impl.swift`

### Criterio de pronto

- todos criados offline sincronizam quando houver conectividade

## Dia 13 - Auth interceptor, 401 e polimento arquitetural

### Objetivo

Fechar as lacunas de infraestrutura e comportamento global.

### Aprender

- injecao de header bearer
- tratamento global de unauthorized

### Entrega

- adicionar middleware/interceptor de auth ao cliente HTTP
- limpar sessao em 401
- redirecionar para login
- revisar acoplamentos indevidos

### Arquivos-alvo

- `TodoNative/Shared/Data/Network/Interceptors/auth_interceptor.swift`
- `TodoNative/Shared/Data/Network/Client/url_session_http_client.swift`

### Criterio de pronto

- expirar token ou receber 401 leva o app de volta ao login

## Dia 14 - Responsividade, testes e fechamento

### Objetivo

Consolidar aprendizado e deixar a base pronta para evolucao.

### Aprender

- adaptacao iPhone/iPad
- testes unitarios simples em Swift
- estrategia de snapshot opcional

### Entrega

- ajustar login/register para compact e regular
- revisar tema/tokens
- criar testes unitarios minimos para stores e sync
- escrever notas finais do que voce aprendeu

### Arquivos-alvo

- `TodoNative/Shared/UI/Responsive/responsive_container.swift`
- `TodoNative/Shared/UI/Theme/app_colors.swift`
- `TodoNative/Shared/UI/Theme/app_typography.swift`
- `TodoNative/Tests/Unit/`

### Criterio de pronto

- app com paridade funcional essencial e base arquitetural saudavel

## Como estudar durante os 14 dias

Em cada dia, siga este mini-loop:

1. Ler so o necessario sobre o conceito nativo do dia
2. Implementar imediatamente no projeto
3. Comparar com o equivalente Flutter
4. Anotar diferencas de mentalidade entre Flutter e iOS

## Regra de comparacao com o Flutter

Ao final de cada dia, responda:

- que parte do Flutter isso corresponde?
- a regra de negocio ficou identica?
- a arquitetura ficou tao clara quanto no Flutter?
- o iOS esta idiomatico ou apenas imitando Flutter de forma artificial?

## Meta final

Ao fim dos 14 dias, voce deve ter:

- entendimento pratico de SwiftUI
- nocao real de navegacao nativa
- experiencia com persistencia local no iOS
- experiencia com client HTTP nativo
- um app real com offline-first e sync
- base suficiente para continuar aprendendo iOS em projeto serio, nao em exemplos artificiais
