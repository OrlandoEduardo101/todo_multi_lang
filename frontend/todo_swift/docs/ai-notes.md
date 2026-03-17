# AI Development Rules - Todo Swift

Regras para manter equivalencia com o projeto Flutter e evitar regressao arquitetural.

## Proibido

- Nao colocar logica de negocio diretamente em SwiftUI View
- Nao acoplar View a `URLSession` ou persistencia diretamente
- Nao usar singletons globais sem protocolo e sem DI
- Nao propagar erro cru para UI (sempre mapear para erro de dominio)
- Nao usar estado monolitico unico para toda tela quando comandos separados bastam
- Nao quebrar o contrato offline-first (nunca depender de sucesso remoto para salvar local)

## Obrigatorio

- Usar store por feature (`AuthStore`, `TodoStore`) com comandos separados
- Usar interfaces/protocolos de repositorio no dominio
- Repositorios devem retornar `Either<AppError, T>` (ou equivalente padronizado)
- Manter `syncStatus` persistido para cada Todo
- Escutar sessao autenticada de forma reativa e global
- Limpar sessao em 401
- Manter componentes visuais pequenos e reutilizaveis

## Padrao de comando

Cada acao assincrona deve ter estado proprio:

- `isExecuting`
- `completed`
- `errorMessage`
- `value`

Exemplos de comandos esperados:

- Auth:
  - `loginCommand`
  - `registerCommand`
  - `logoutCommand`
  - `watchAuthCommand`
- Todo:
  - `todoListCommand` (stream)
  - `createTodoCommand`
  - `updateTodoCommand`
  - `deleteTodoCommand`
  - `syncTodosCommand`

## Convencoes de naming

- Arquivos: `snake_case.swift`
- Tipos: `PascalCase`
- Metodos/variaveis: `camelCase`
- Protocolos: sufixo `Protocol` opcional, mas consistente

## Workflow ao criar nova feature

1. Criar pasta em `Features/<Feature>/`
2. Definir modelos e protocolos no Domain
3. Implementar Data (DTO, mapper, repository)
4. Criar Store com comandos
5. Criar Views e Components
6. Registrar dependencias no composition root
7. Adicionar testes unitarios/integracao

## Checklist de PR

- Mantem separacao Presentation/Domain/Data?
- Sem dependencia direta de UI para infraestrutura?
- Fluxo offline-first preservado?
- Todos os comandos possuem tratamento de erro?
- Navegacao e DI consistentes com docs?
