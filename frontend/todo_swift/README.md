# Todo Swift (Blueprint iOS Nativo)

Este diretório contém o blueprint para refazer o app `todo_flutter` em iOS nativo, preservando arquitetura, fluxo funcional, estratégia offline-first e regras de projeto.

## Objetivo

Reimplementar no iOS nativo (Swift + SwiftUI) as mesmas capacidades do app Flutter:

- Autenticação JWT (login/cadastro/logout)
- Persistência local de sessão
- CRUD de tarefas
- Offline-first com fila local de sincronização
- Sincronização manual e automática
- Layout responsivo/adaptativo para iPhone e iPad

## Estrutura criada

A pasta `TodoNative/` foi criada com camadas equivalentes ao Flutter:

- `App/` inicialização e composição raiz
- `Features/Auth` módulo de autenticação
- `Features/Todo` módulo de tarefas + sync
- `Shared/Core` tipos transversais (`Either`, erros, comandos reativos)
- `Shared/Data` banco local e cliente HTTP
- `Shared/UI` tema, componentes e responsividade
- `Resources/` assets e localização
- `Tests/` testes unitários, integração e snapshot

## Documentação

A documentação detalhada está em `docs/`:

- `INDEX.md`
- `ARCHITECTURE.md`
- `14-day-learning-plan.md`
- `ai-notes.md`
- `dependency-injector.md`
- `routes-navigation-system.md`
- `responsive-layout.md`
- `screen-componentization-ai-ready.md`
- `theme-usage-guide.md`
- `flutter-to-ios-mapping.md`

## Stack sugerida (equivalente ao Flutter atual)

- UI: SwiftUI
- Estado: `ObservableObject` + `@Published` (com padrão Command)
- Navegação: `NavigationStack` + coordenador leve
- DI: Factory/Container próprio (composition root)
- HTTP: `URLSession` + camada `HTTPClient`
- Persistência: SwiftData ou Core Data
- Sync: serviço de sincronização em background orientado a status

## Próximo passo

Com esse blueprint, o próximo passo natural é gerar um projeto Xcode (`TodoNative.xcodeproj`) e começar pela espinha dorsal:

1. Composition root + DI container
2. Modelos/contratos de domínio
3. Persistência local de sessão e todos
4. Auth + interceptor
5. Sync engine
6. Telas (Splash, Login, Register, Home)
