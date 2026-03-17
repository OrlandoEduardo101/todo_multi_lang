# Theme Usage Guide - Todo Swift

## Objetivo

Preservar coerencia visual e evitar estilos hardcoded espalhados.

## Estrategia

Criar tokens semanticos em `Shared/UI/Theme/`.

Exemplo de grupos:

- `AppColors`
- `AppTypography`
- `AppSpacing`
- `AppRadius`

## Regras

- Nao usar cor literal na view quando houver token
- Nao duplicar tipografia em cada tela
- Usar opacidade de forma padronizada
- Definir contraste para estados de erro, sucesso e aviso

## Mapeamento visual do Flutter

O Flutter atual usa gradientes e superficies com destaque em autenticacao e splash.

No iOS:

- manter fundo gradiente nas telas de auth
- manter hierarquia de destaque (titulo forte, subtitulo suave)
- manter badges de status de sync com cores semanticamente equivalentes:
  - synced -> sucesso
  - pending -> secundario/aviso
  - erro -> erro

## Dark/Light

Mesmo que o Flutter esteja com foco em dark theme, no iOS recomenda-se suportar ambos:

- tokens com variantes light/dark
- validacao de contraste por modo

## Tipografia recomendada

- Headline: SF Pro Display
- Body: SF Pro Text
- Monospace tecnico: SF Mono (apenas quando necessario)

## Checklist rapido

- Todas as views usam tokens?
- Estados de botoes estao padronizados?
- Campos de formulario seguem o mesmo estilo?
- Badge de sync tem cor e label consistentes?
