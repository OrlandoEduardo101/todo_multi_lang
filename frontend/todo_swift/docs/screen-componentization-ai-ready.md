# Screen Componentization - Todo Swift

## Objetivo

Definir granularidade de componentes para manter manutencao simples e previsivel.

## Onde colocar cada coisa

- Componente exclusivo de uma tela:
  - `Features/<Feature>/Presentation/Components/`
- Componente reutilizavel entre features:
  - `Shared/UI/Components/`

## Regra de 3 camadas na tela

1. Screen Orchestrator (`*_screen.swift`):
- conecta store
- define listeners
- dispara comandos
- coordena navegacao

2. Screen Layout (`*_layout.swift`):
- estrutura visual principal
- escolhe variacao compact/regular

3. Visual Components:
- componentes focados em UI
- sem regra de negocio

## API de componentes

- Inputs simples e explicitos
- Evitar passar store inteiro para componente visual
- Preferir callbacks (`onTap`, `onSubmit`) e view models pequenos

## Quando extrair componente

Extrair se qualquer condicao for verdadeira:

- Mais de ~60 linhas de UI em bloco unico
- Repeticao em 2+ telas
- Necessidade de teste visual isolado
- Complexidade de estilo que polui a tela principal

## Naming

- `auth_login_form_view.swift`
- `todo_sync_badge_view.swift`
- `primary_action_button.swift`

## Testes

- Snapshot para componentes criticos
- Testes de interacao para formularios
- Testes de acessibilidade (labels e traits)
