# Responsive Layout - Todo Swift

## Objetivo

Manter a intencao do Flutter para layouts adaptativos entre celular e tablet.

## Breakpoints

Padrao recomendado:

- Compact: largura < 768
- Regular: largura >= 768

Obs: no iOS nativo, desktop nao e alvo principal deste diretório. Se houver Catalyst, pode-se adicionar breakpoint >= 1200.

## Estrutura obrigatoria por tela

Toda tela deve seguir 3 niveis:

1. Orquestracao: store listeners, navegacao, side effects
2. Layout: composicao para compact/regular
3. Componentes visuais: widgets puros reutilizaveis

## Padrões por tela atual

- Login/Register:
  - Compact: branding + form em coluna
  - Regular: painel lateral de marca + formulario central
- Home:
  - Lista principal em iPhone
  - iPad pode usar split/rail quando houver crescimento funcional

## Regras

- Evitar duplicar logica de negocio por breakpoint
- Variar apenas composicao visual
- Evitar largura fixa rigida sem `maxWidth`
- Priorizar legibilidade e densidade adequada em iPad

## Tecnicas recomendadas

- `horizontalSizeClass` e `verticalSizeClass`
- `GeometryReader` para limites de largura
- wrappers internos como `ResponsiveContainer`
