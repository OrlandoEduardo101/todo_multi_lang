# Routes and Navigation System - Todo Swift

## Objetivo

Espelhar o comportamento do Routefly do Flutter com uma abordagem nativa SwiftUI.

## Rotas esperadas

- `splash`
- `auth/login`
- `auth/register`
- `home`

## Estrategia

Usar `NavigationStack` com um `AppRouter` central:

- `setRoot(route)` para substituir stack inteira (equivalente ao navigate)
- `push(route)` para empilhar
- `pop()` para voltar

## Modelo de rota

Criar enum:

- `AppRoute.splash`
- `AppRoute.login`
- `AppRoute.register`
- `AppRoute.home`

## Regras de navegacao

- Splash decide rota inicial conforme sessao
- Login/Register em sucesso vao para Home por substituicao de stack
- Logout limpa sessao e retorna para Login por substituicao de stack
- Navegacao deve ser acionada pela camada de orquestracao (View principal/Coordinator), nao por componentes de baixo nivel

## Argumentos

Se houver dados de rota, preferir `enum` com associated values tipados em vez de dicionario generico.

## Testes

- Testar decisao da rota inicial
- Testar transicao apos login
- Testar retorno ao login apos 401/logout
