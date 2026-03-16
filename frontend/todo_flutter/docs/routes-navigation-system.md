

# 🚦 Navegação com `Routefly` em Flutter

O **[Routefly](https://pub.dev/packages/routefly)** é um gerenciador de rotas baseado em pastas, inspirado no **Next.js**.
Ele cria rotas automaticamente a partir da estrutura de diretórios, eliminando a necessidade de definir rotas manualmente.

---

## 📦 Instalação

No terminal:

```sh
flutter pub add routefly
```

---

## 🏗️ Estrutura de Diretórios

O `Routefly` utiliza a pasta `lib/app` como base para criação de rotas.
Cada arquivo terminado em **`_page.dart`** dentro dessa pasta se torna uma rota.

```
lib/
└── app/
    ├── home/
    │   └── home_page.dart
    ├── product/
    │   └── product_page.dart
    └── user/
        └── user_page.dart
```

Gerará automaticamente as rotas:

* `/home`
* `/product`
* `/user`

---

## ⚙️ Configuração Inicial

### `my_app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

import 'my_app.route.dart'; // <- GERADO
part 'my_app.g.dart';       // <- GERADO

@Main('lib/app') // <- base da estrutura
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: Routefly.routerConfig(
        routes: routes, // GERADO
      ),
    );
  }
}
```

---

## ▶️ Gerando Rotas

Sempre que adicionar uma nova página em `app/`, rode:

```sh
dart run routefly
```

Ou use o modo **watch** para regenerar automaticamente:

```sh
dart run routefly --watch
```

---

## 🔀 Métodos de Navegação

* `Routefly.navigate('path')` → Substitui toda a pilha
* `Routefly.push('path')` → Empilha rota
* `Routefly.pushNavigate('path')` → Navega e mantém stack
* `Routefly.pop()` → Fecha rota atual
* `Routefly.replace('path')` → Substitui a última rota

### Exemplo

### Com `routePaths` (seguro e tipado)

```dart
Routefly.navigate(routePaths.user);
```

---

## 🔑 Rotas Dinâmicas

Crie páginas com parâmetros dinâmicos:

```
lib/app/users/[id]/user_page.dart
```

Gerará `/users/[id]`.

### Navegação com parâmetro

```dart
// Object notation
Routefly.push(routePaths.users.changes({'id': '42'}));
```

### Recuperando o parâmetro

```dart
final userId = Routefly.query['id'];
```

---

## 🧭 Layouts (Nested Navigation)

Layouts permitem rotas aninhadas.

```
lib/app/dashboard/
├── dashboard_layout.dart
├── users/
│   └── users_page.dart
└── products/
    └── products_page.dart
```

### `dashboard_layout.dart`

```dart
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';

class DashboardLayout extends StatelessWidget {
  const DashboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people), label: Text('Users')),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag), label: Text('Products')),
            ],
            onDestinationSelected: (index) {
              if (index == 0) {
                Routefly.navigate(routePaths.dashboard.users);
              } else {
                Routefly.navigate(routePaths.dashboard.products);
              }
            },
          ),
          const Expanded(child: RouterOutlet()), // <- Rotas filhas
        ],
      ),
    );
  }
}
```

---

## ⚡ Middleware

Intercepte e modifique rotas antes de carregar:

```dart
FutureOr<RouteInformation> guardRoute(RouteInformation route) {
  if (route.uri.path == '/private') {
    return route.redirect(Uri.parse('/login'));
  }
  return route;
}

MaterialApp.router(
  routerConfig: Routefly.routerConfig(
    routes: routes,
    middlewares: [guardRoute],
  ),
);
```

---

## ❌ Página 404

Adicione um `404_page.dart` em `app/`, ou configure manualmente:

```dart
MaterialApp.router(
  routerConfig: Routefly.routerConfig(
    routes: routes,
    notFoundPath: '/not-found',
  ),
);
```

---

## 🎨 Transições Personalizadas

Em uma página específica:

```dart
Route routeBuilder(BuildContext context, RouteSettings settings) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, __, ___) => const UserPage(),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
```

Ou globalmente:

```dart
MaterialApp.router(
  routerConfig: Routefly.routerConfig(
    routes: routes,
    routeBuilder: (context, settings, child) {
      return CupertinoPageRoute(
        settings: settings,
        builder: (_) => child,
      );
    },
  ),
);
```

---

## ✅ Benefícios do Routefly

* Estrutura **modular e escalável**
* Rotas **geradas automaticamente**
* Suporte a **rotas dinâmicas**
* Layouts com **RouterOutlet** para navegação aninhada
* Suporte a **middlewares** e **404 customizado**
* **Menos boilerplate** que Navigator 2.0 puro

---

👉 Agora você tem uma documentação **AI Ready** para implementar o **Routefly** em projetos Flutter.
