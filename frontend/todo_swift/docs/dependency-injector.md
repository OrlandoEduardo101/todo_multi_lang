# Dependency Injection - Todo Swift

## Objetivo

Reproduzir o mesmo efeito do `AutoInjector` do Flutter: um composition root unico com modulos por feature.

## Estrategia

Usar um container simples de factories/singletons no app root.

### Composicao raiz

`AppContainer` deve registrar:

- Infraestrutura compartilhada:
  - `DatabaseClient`
  - `AuthSessionStore`
  - `HTTPClient`
- Feature Auth:
  - `AuthRepository`
  - `AuthStore`
- Feature Todo:
  - `TodoRepository`
  - `TodoSyncService`
  - `TodoStore`

## Tempo de vida recomendado

- Singleton:
  - `DatabaseClient`
  - `AuthSessionStore`
  - `HTTPClient`
  - `TodoSyncService`
- Lazy singleton:
  - stores e repositorios (se custo de criacao justificar)

## Regras

- View nunca instancia repositorio diretamente
- View recebe store por injeção
- Repositorio recebe dependencias por construtor
- Dependencia de feature em outra feature deve passar por protocolo

## Exemplo de fluxo de resolucao

1. `TodoApp` cria `AppContainer`
2. `RootView` resolve `AuthStore` para bootstrap
3. `HomeView` resolve `TodoStore`
4. Stores chamam protocolos de repositorio

## Testes com DI

- Substituir implementacoes por mocks no container de teste
- Evitar `if DEBUG` para trocar dependencia
- Fornecer initializer especifico para testes
