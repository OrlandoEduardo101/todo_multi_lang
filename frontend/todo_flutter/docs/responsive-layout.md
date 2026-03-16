
## **Padrão de Desenvolvimento para Interfaces Responsivas e Adaptativas em Flutter**

**Versão:** 1.0
**Data:** 11/10/2025
**Autor:** Orlando Eduardo Pereira
**Status:** `ATIVO`

### 1\. Introdução

#### 1.1. Objetivo

Este documento estabelece as diretrizes e regras mandatórias para a criação de interfaces de usuário (UI) que sejam simultaneamente **responsivas** e **adaptativas**. O objetivo é garantir uma experiência de usuário (UX) consistente, de alta qualidade e otimizada em todas as plataformas-alvo do nosso projeto: **celular (mobile), tablet e desktop**. A adesão a este padrão é fundamental para garantir a manutenibilidade, escalabilidade e consistência do código-fonte, servindo como a única fonte de verdade para o desenvolvimento de UI.

#### 1.2. Escopo

As regras aqui contidas aplicam-se a todo o desenvolvimento de UI, desde a criação de widgets individuais até a arquitetura de telas complexas. Agentes de IA e desenvolvedores devem seguir estas diretrizes sem exceção.

#### 1.3. Definições Chave

  * **Design Responsivo:** A capacidade da UI de se ajustar fluidamente a qualquer tamanho de tela, reorganizando e redimensionando seus elementos existentes. O layout é um só, porém líquido.
  * **Design Adaptativo:** A prática de criar layouts distintos para conjuntos específicos de tamanhos de tela (breakpoints) ou plataformas. O aplicativo **detecta** o contexto e **seleciona** o layout mais apropriado.

Nossa estratégia oficial é uma **abordagem híbrida**, utilizando princípios responsivos como base e aplicando lógicas adaptativas em pontos estratégicos para otimizar a UX em cada dispositivo.

### 2\. Princípios Fundamentais

1.  **Mobile-First:** O desenvolvimento de novas telas **deve** começar pela menor dimensão de tela (celular). Isso força a priorização do conteúdo essencial. Funcionalidades e elementos adicionais são introduzidos progressivamente para telas maiores.
2.  **Desacoplamento UI-Lógica:** A lógica de negócios e o gerenciamento de estado (BLoC/Cubit) **devem** ser completamente independentes da UI. A mesma lógica alimentará todos os layouts (`mobile`, `tablet`, `desktop`) sem qualquer modificação.
3.  **Consistência vs. Otimização:** A otimização da experiência em uma plataforma específica tem precedência sobre a consistência total. A navegação em desktop, por exemplo, **deve** seguir os padrões de desktop (menu lateral), mesmo que seja diferente da navegação mobile (barra inferior).

### 3\. Diretrizes de Implementação

#### 3.1. Arquitetura de Telas (Screen Layout Pattern)

Toda nova tela (feature) **deve** seguir a estrutura de arquivos abaixo para separar os layouts. A tela principal atuará como um "switcher" de layout.

**Estrutura de Diretório Mandatória:**

```
lib/
└── features/
    └── minha_feature/
        ├── view/
        │   ├── minha_feature_screen.dart     // Widget principal (Stateless) que contém a lógica do switcher.
        │   └── layouts/
        │       ├── mobile_layout.dart      // Layout para telas pequenas.
        │       ├── tablet_layout.dart      // Layout para telas médias.
        │       └── desktop_layout.dart     // Layout para telas grandes.
        ├── widgets/                        // Widgets compartilhados entre os layouts.
        └── bloc/                           // Lógica de negócios e estado.
```

**Implementação Padrão do Switcher (`minha_feature_screen.dart`):**
O widget principal **deve** usar `LayoutBuilder` para ler as restrições de tamanho e renderizar o layout apropriado, conforme o exemplo abaixo.

```dart
import 'package:flutter/material.dart';
import 'package:meu_projeto/core/ui/breakpoints.dart'; // Arquivo com as constantes de breakpoints
import 'layouts/mobile_layout.dart';
import 'layouts/tablet_layout.dart';
import 'layouts/desktop_layout.dart';

class MinhaFeatureScreen extends StatelessWidget {
  const MinhaFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A injeção de dependência e chamada inicial da lógica (BLoC/Cubit)
    // deve ocorrer em um nível superior ou aqui, antes do Scaffold.

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kTabletBreakpoint) {
            return const MobileLayout();
          }
          if (constraints.maxWidth < kDesktopBreakpoint) {
            return const TabletLayout();
          }
          return const DesktopLayout();
        },
      ),
    );
  }
}
```

#### 3.2. Definição de Breakpoints Globais

Para manter a consistência em todo o projeto, os seguintes breakpoints **devem** ser utilizados.

**Arquivo `lib/core/ui/breakpoints.dart`:**

```dart
/// Ponto de interrupção para layouts de tablet.
const double kTabletBreakpoint = 768.0;

/// Ponto de interrupção para layouts de desktop.
const double kDesktopBreakpoint = 1200.0;
```

#### 3.3. Uso de Widgets Responsivos

A base de todo layout **deve** ser fluida.

  * **Sempre use:** `Expanded` e `Flexible` dentro de `Row` e `Column` para distribuir o espaço.
  * **Prefira:** `Wrap` em vez de `Row` para listas de itens que podem quebrar a linha (ex: tags, chips).
  * **Use:** `LayoutBuilder` para decisões de layout baseadas no espaço *disponível para o widget*. Use `MediaQuery` apenas para decisões globais (ex: `padding` superior devido à barra de status).
  * **É proibido:** Usar dimensões fixas (ex: `width: 300`). Use alinhamentos, preenchimentos (`padding`) e widgets flexíveis.

#### 3.4. Componentes Adaptativos

Componentes-chave **devem** se adaptar ao contexto do dispositivo.

  * **Navegação Principal:**
      * **Mobile:** Utilizar `BottomNavigationBar`.
      * **Tablet:** Utilizar `NavigationRail`.
      * **Desktop:** Utilizar `NavigationDrawer` (permanentemente visível).
  * **Entradas e Controles:**
      * Utilizar os construtores `.adaptive()` sempre que disponíveis (ex: `Switch.adaptive`, `Slider.adaptive`).
  * **Interação:**
      * Considerar densidade de toque em telas móveis (botões e alvos de toque maiores).
      * Para desktop, implementar interações com mouse, como `InkWell` com `onHover`, e atalhos de teclado quando aplicável.

### 4\. Ferramentas e Pacotes Obrigatórios

  * **`flutter_bloc`**: (OBRIGATÓRIO) Para gerenciamento de estado, garantindo o desacoplamento entre UI e lógica.
  * **`flutter_screenutil`**: (RECOMENDADO) Para adaptar tamanhos de fontes e widgets de forma proporcional. Se utilizado, a configuração inicial deve ser feita no `main.dart`.

### 5\. Regras de Ouro (Do's and Don'ts)

| ✅ FAZER (DO)                                                                                                | ❌ NÃO FAZER (DON'T)                                                                                                |
| ------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| Usar unidades relativas e flexíveis (`Expanded`, `FractionallySizedBox`).                                    | Definir larguras e alturas com valores fixos e "mágicos" (`width: 300`).                                          |
| Testar os layouts em diferentes tamanhos de tela e orientações (retrato e paisagem).                         | Assumir que o app será usado apenas no modo retrato.                                                                 |
| Separar a UI em layouts específicos (`mobile`, `tablet`, etc.) quando as mudanças forem significativas.      | Criar um layout único e complexo cheio de condicionais (`if/else`) baseadas no tamanho da tela.                       |
| Pensar nos diferentes métodos de entrada (toque, mouse, teclado).                                            | Criar um layout de desktop que seja apenas uma versão "esticada" do layout mobile.                                    |
| Compartilhar o máximo de widgets customizados entre os diferentes layouts para evitar duplicação de código.  | Duplicar lógica de negócios ou chamadas de API dentro dos arquivos de layout.                                       |
| Priorizar a legibilidade e a acessibilidade (fontes de bom tamanho, contraste, etc.) em todas as dimensões.  | Esquecer de testar o comportamento do teclado virtual em telas menores, que pode causar `overflow`. Use `SingleChildScrollView`. |

### 6\. Exemplo Prático: Tela de Lista/Grade

**Cenário:** Uma tela que exibe uma coleção de itens.

  * **Mobile:** Uma `ListView` vertical.
  * **Tablet/Desktop:** Uma `GridView` com um número de colunas que se adapta à largura.

**Implementação (`minha_feature_screen.dart`):**

```dart
class MinhaFeatureScreen extends StatelessWidget {
  const MinhaFeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider estaria em um nível superior.
    return Scaffold(
      appBar: AppBar(title: const Text('Itens')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < kTabletBreakpoint) {
            // Layout Mobile: ListView
            return MobileLayout(); // mobile_layout.dart contém o ListView.builder
          } else {
            // Layout Tablet/Desktop: GridView
            // A lógica para decidir o número de colunas estaria dentro do Tablet/Desktop Layout.
            return constraints.maxWidth < kDesktopBreakpoint
                   ? TabletLayout()
                   : DesktopLayout();
          }
        },
      ),
    );
  }
}

// Em tablet_layout.dart / desktop_layout.dart:
class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    // Lógica para determinar o número de colunas baseado no espaço
    final double width = MediaQuery.of(context).size.width;
    final int crossAxisCount = (width / 250).floor(); // Ex: cada item tem ~250px

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        // Use um widget compartilhado, ex: ItemCard(item: state.items[index])
        return Card(child: Center(child: Text('Item $index')));
      },
    );
  }
}
```

### 7\. Conclusão

A adoção estrita deste padrão é essencial para criar um processo de desenvolvimento de UI estruturado, previsível e eficiente. Ele promove a reutilização de código e garante que nossos usuários tenham a melhor experiência possível, independentemente do dispositivo que utilizem. Este é um documento vivo e poderá ser atualizado conforme novas práticas e ferramentas se tornem disponíveis.

-----
