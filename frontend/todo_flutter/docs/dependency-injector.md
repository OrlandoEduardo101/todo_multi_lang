Aqui está um guia completo que se integra ao padrão que você já está usando (com `presentation/`, `data/`, `bindings/`, `repositories/`).

---

# 📦 Injeção de Dependência com `auto_injector` em Projetos Flutter

Este guia descreve como configurar e utilizar o [`auto_injector`](https://pub.dev/packages/auto_injector) para gerenciar dependências em aplicativos Flutter organizados em módulos.

---

## 📂 Estrutura de Diretórios

Cada módulo deve seguir a mesma convenção de organização:

```
module_name/
├── presentation/    # (pages, widgets, stores)
├── data/            # (models)
├── repositories/    # (data access)
└── bindings/        # (dependency injection)
```

---

## ⚙️ Configuração

Adicione a dependência no `pubspec.yaml`:

```yaml
dependencies:
  auto_injector: ^1.0.2
```

Ou use:

```sh
dart pub add auto_injector
```

---

## 🧩 Definindo um Módulo

Cada módulo terá seu próprio **AutoInjector** para organizar dependências.

### Exemplo: `home_bindings.dart`

```dart
import 'package:auto_injector/auto_injector.dart';
import '../repositories/greeting_repository.dart';

final homeModule = AutoInjector(
  tag: 'HomeModule',
  on: (i) {
    i.addSingleton(GreetingRepository.new);
    i.commit();
  },
);
```

---

## 🗂️ Repositório (Exemplo)

### `greeting_repository.dart`

```dart
class GreetingRepository {
  String fetchGreeting() {
    return "Olá, Flutter com AutoInjector 🚀";
  }
}
```

---

## 🎯 Uso na Camada de Apresentação

### `home_page.dart`

```dart
import 'package:flutter/material.dart';
import '../bindings/home_bindings.dart';
import '../repositories/greeting_repository.dart';

class HomePage extends StatelessWidget {
  final repo = homeModule.get<GreetingRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AutoInjector Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final message = repo.fetchGreeting();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          child: const Text("Executar Repositório"),
        ),
      ),
    );
  }
}
```

---

## 🧹 Descarte de Dependências

Caso use **singletons** que precisam liberar recursos (ex: `Bloc`, `Controller`, `Store`), utilize `disposeSingleton`:

```dart
final disposed = homeModule.disposeSingleton<GreetingRepository>();
// se a classe tiver dispose/close, chamar aqui
```

Ou descarte todos os singletons de um módulo:

```dart
homeModule.disposeSingletonsByTag('HomeModule', (instance) {
  if (instance is SomeBloc) instance.close();
});
```

---

## 📌 Modularização

Você pode **unir múltiplos módulos** em um container principal:

```dart
import 'package:auto_injector/auto_injector.dart';
import 'home_bindings.dart';
import 'user_bindings.dart';

final appModule = AutoInjector(
  tag: 'AppModule',
  on: (i) {
    i.addInjector(homeModule);
    i.addInjector(userModule);
    i.commit();
  },
);
```

Agora, no **app inteiro**:

```dart
final homeRepo = appModule.get<GreetingRepository>();
```

---

## 🛡️ Boas Práticas de Tipagem e Instanciação

- **SEMPRE** tipar explicitamente todas as injeções de dependência no setup do DI (ex: `injector.addSingleton<PatientHomeStore>(PatientHomeStore.new);`).
- **SEMPRE** preferir o construtor `.new` ao registrar singletons (ex: `injector.addSingleton<MyStore>(MyStore.new);`).
- **NUNCA** usar tipos inferidos ou omitir o tipo na declaração de injeção.
- **Justificativa**: Tipagem explícita e uso do `.new` aumentam a clareza, facilitam manutenção e garantem instância correta dos singletons.

---

## ✅ Vantagens do `auto_injector`

* **Sem build\_runner**: não depende de geração de código.
* **Flexível**: suporta `factory`, `singleton`, `lazySingleton`, `instance`.
* **Modular**: fácil organizar dependências por módulo.
* **Testável**: substitua dependências com `transform` em testes.
* **Gerenciamento de ciclo de vida**: descarte controlado de instâncias.

---

## 🚀 Exemplo Completo de Início

```dart
void main() {
  runApp(const MyApp());
}

// app.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}
```

Com `homeModule` gerenciando as dependências.

---

👉 Agora você tem uma **documentação AI Ready** para usar `auto_injector` em uma arquitetura modular.
