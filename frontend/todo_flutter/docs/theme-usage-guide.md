# Flutter Theme Usage Guide

**Como usar corretamente o Theme no projeto Pronto Doutor App**

## 📚 Conceitos Fundamentais

O projeto utiliza um sistema de tema centralizado que deve ser acessado via `Theme.of(context)` para garantir consistência visual e facilitar manutenção.

### ❌ PROIBIDO (Estilo Antigo)
```dart
// NUNCA faça isso:
color: AppColors.primary                    // ❌ Cor hardcoded
textStyle: AppTextStyles.bodyMedium         // ❌ Estilo hardcoded
backgroundColor: Colors.blue                // ❌ Cor do Material Design
```

### ✅ CORRETO (Estilo Moderno)
```dart
// SEMPRE faça isso:
color: theme.colorScheme.primary           // ✅ Cor do tema
textStyle: theme.textTheme.bodyMedium      // ✅ Estilo do tema
backgroundColor: theme.colorScheme.surface // ✅ Cor semântica
```

## 🎨 Sistema de Cores

### Cores Principais
```dart
final theme = Theme.of(context);

// Cores primárias
theme.colorScheme.primary           // Cor principal do app
theme.colorScheme.onPrimary         // Texto sobre cor primária
theme.colorScheme.primaryContainer  // Versão mais clara da primária
theme.colorScheme.onPrimaryContainer // Texto sobre container primário

// Cores secundárias
theme.colorScheme.secondary         // Cor secundária
theme.colorScheme.onSecondary       // Texto sobre cor secundária
theme.colorScheme.secondaryContainer // Container secundário
theme.colorScheme.onSecondaryContainer // Texto sobre container secundário

// Superfícies
theme.colorScheme.surface           // Fundo de cards, dialogs
theme.colorScheme.onSurface         // Texto sobre superfície
theme.colorScheme.surfaceContainer  // Container de superfície
theme.colorScheme.onSurfaceVariant  // Texto secundário

// Estados
theme.colorScheme.error             // Cor de erro
theme.colorScheme.onError           // Texto sobre erro
theme.colorScheme.tertiary          // Cor de sucesso (mapeada)
theme.colorScheme.onTertiary        // Texto sobre sucesso

// Bordas e divisores
theme.colorScheme.outline           // Bordas principais
theme.colorScheme.outlineVariant    // Divisores sutis
```

### Mapeamento de Cores AppColors → Theme
```dart
// Conversão das cores antigas para o tema:
AppColors.primary          → theme.colorScheme.primary
AppColors.primaryLight     → theme.colorScheme.primaryContainer
AppColors.secondary        → theme.colorScheme.secondary
AppColors.success          → theme.colorScheme.tertiary
AppColors.error            → theme.colorScheme.error
AppColors.textPrimary      → theme.colorScheme.onSurface
AppColors.textSecondary    → theme.colorScheme.onSurfaceVariant
AppColors.textTertiary     → theme.colorScheme.outline
AppColors.surface          → theme.colorScheme.surface
AppColors.background       → theme.scaffoldBackgroundColor
AppColors.border           → theme.colorScheme.outline
AppColors.divider          → theme.colorScheme.outlineVariant
```

## 📝 Sistema de Textos

### Hierarquia de Textos
```dart
final theme = Theme.of(context);

// Cabeçalhos
theme.textTheme.displayLarge       // Títulos muito grandes
theme.textTheme.displayMedium      // Títulos grandes
theme.textTheme.displaySmall       // Títulos médios

theme.textTheme.headlineLarge      // Cabeçalhos grandes
theme.textTheme.headlineMedium     // Cabeçalhos médios
theme.textTheme.headlineSmall      // Cabeçalhos pequenos

// Títulos
theme.textTheme.titleLarge         // Títulos de seção
theme.textTheme.titleMedium        // Títulos de card
theme.textTheme.titleSmall         // Títulos pequenos

// Corpo do texto
theme.textTheme.bodyLarge          // Texto principal grande
theme.textTheme.bodyMedium         // Texto principal
theme.textTheme.bodySmall          // Texto secundário

// Labels e botões
theme.textTheme.labelLarge         // Labels grandes
theme.textTheme.labelMedium        // Labels médios
theme.textTheme.labelSmall         // Labels pequenos (caption)
```

### Mapeamento de Estilos AppTextStyles → Theme
```dart
// Conversão dos estilos antigos para o tema:
AppTextStyles.displayLarge     → theme.textTheme.displayLarge
AppTextStyles.headlineLarge    → theme.textTheme.headlineLarge
AppTextStyles.headlineMedium   → theme.textTheme.headlineMedium
AppTextStyles.headlineSmall    → theme.textTheme.headlineSmall
AppTextStyles.titleLarge       → theme.textTheme.titleLarge
AppTextStyles.titleMedium      → theme.textTheme.titleMedium
AppTextStyles.titleSmall       → theme.textTheme.titleSmall
AppTextStyles.bodyLarge        → theme.textTheme.bodyLarge
AppTextStyles.bodyMedium       → theme.textTheme.bodyMedium
AppTextStyles.bodySmall        → theme.textTheme.bodySmall
AppTextStyles.labelLarge       → theme.textTheme.labelLarge
AppTextStyles.labelMedium      → theme.textTheme.labelMedium
AppTextStyles.caption          → theme.textTheme.labelSmall
AppTextStyles.button           → theme.textTheme.labelLarge
```

## 🧩 Componentes Temáticos

### Botões
```dart
// ElevatedButton - já configurado automaticamente
ElevatedButton(
  onPressed: () {},
  child: Text('Botão Primário'), // Usa theme.textTheme.labelLarge
)

// OutlinedButton - já configurado automaticamente
OutlinedButton(
  onPressed: () {},
  child: Text('Botão Secundário'),
)

// TextButton - já configurado automaticamente
TextButton(
  onPressed: () {},
  child: Text('Botão Texto'),
)
```

### Cards
```dart
// Card - já configurado automaticamente
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text(
      'Conteúdo do card',
      style: theme.textTheme.bodyMedium, // Cor automática
    ),
  ),
)
```

### Campos de Texto
```dart
// TextField - já configurado automaticamente
TextField(
  decoration: InputDecoration(
    labelText: 'Label',  // Usa theme automaticamente
    hintText: 'Hint',    // Usa theme automaticamente
  ),
)
```

## 🛠️ Padrões de Uso

### 1. Widgets com Fundo
```dart
Container(
  color: theme.colorScheme.surface,           // Fundo de superfície
  child: Text(
    'Texto',
    style: theme.textTheme.bodyMedium,        // Texto se adapta automaticamente
  ),
)
```

### 2. Badges e Status
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: theme.colorScheme.tertiary.withValues(alpha: 0.1), // ✅ CORRETO
    border: Border.all(
      color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Sucesso',
    style: theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.tertiary,
    ),
  ),
)
```

### 3. AppBars Customizados
```dart
AppBar(
  backgroundColor: theme.colorScheme.primary,     // Cor primária
  foregroundColor: theme.colorScheme.onPrimary,  // Cor do texto/ícones
  title: Text(
    'Título',
    style: theme.textTheme.headlineMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
    ),
  ),
)
```

### 4. Ícones Temáticos
```dart
Icon(
  Icons.check_circle,
  color: theme.colorScheme.tertiary, // Sucesso
  size: 24,
)

Icon(
  Icons.error_outline,
  color: theme.colorScheme.error,    // Erro
  size: 24,
)
```

## 🔄 Adaptação para Diferentes Estados

### Estados de Loading
```dart
if (isLoading) {
  CircularProgressIndicator(
    color: theme.colorScheme.primary, // Cor automática via tema
  )
}
```

### Estados de Erro
```dart
if (hasError) {
  Column(
    children: [
      Icon(
        Icons.error_outline,
        color: theme.colorScheme.error,
        size: 64,
      ),
      Text(
        'Erro',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    ],
  )
}
```

### Estados Vazios
```dart
if (isEmpty) {
  Column(
    children: [
      Icon(
        Icons.inbox_outlined,
        color: theme.colorScheme.outline,    // Cor neutra
        size: 64,
      ),
      Text(
        'Nenhum item encontrado',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ],
  )
}
```

## 📱 Responsividade com Theme

### Breakpoints e Adaptação
```dart
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final screenWidth = MediaQuery.of(context).size.width;
  
  // Adaptar estilo baseado no tamanho da tela
  final titleStyle = screenWidth > 600 
    ? theme.textTheme.headlineLarge 
    : theme.textTheme.headlineMedium;
    
  return Text('Título', style: titleStyle);
}
```

## ⚡ Otimizações de Performance

### Cache do Theme
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // ✅ Uma única chamada por build
    
    return Column(
      children: [
        Text('Título', style: theme.textTheme.titleMedium),
        Text('Subtítulo', style: theme.textTheme.bodyMedium),
        // Usar a variável 'theme' em vez de chamar Theme.of(context) novamente
      ],
    );
  }
}
```

## 🚫 Erros Comuns a Evitar

### 1. Não Usar withValues()
```dart
// ❌ ERRADO (Deprecated)
color: AppColors.primary.withOpacity(0.1)

// ✅ CORRETO
color: theme.colorScheme.primary.withValues(alpha: 0.1)
```

### 2. Hardcoding de Cores
```dart
// ❌ ERRADO
Container(color: Colors.blue)
Container(color: Color(0xFF123456))

// ✅ CORRETO
Container(color: theme.colorScheme.primary)
Container(color: theme.colorScheme.surface)
```

### 3. Misturar AppColors com Theme
```dart
// ❌ ERRADO (Inconsistente)
color: AppColors.primary
textStyle: theme.textTheme.bodyMedium

// ✅ CORRETO (Consistente)
color: theme.colorScheme.primary
textStyle: theme.textTheme.bodyMedium
```

## 🎯 Benefícios do Theme

1. **Consistência Visual**: Todas as telas seguem o mesmo padrão
2. **Manutenibilidade**: Mudanças centralizadas no AppTheme
3. **Acessibilidade**: Suporte automático a modo escuro e alto contraste
4. **Performance**: Cache automático de estilos
5. **Flexibilidade**: Fácil customização por contexto

## 📋 Checklist de Migração

- [ ] Substituir `AppColors.*` por `theme.colorScheme.*`
- [ ] Substituir `AppTextStyles.*` por `theme.textTheme.*`
- [ ] Usar `theme.colorScheme.*.withValues(alpha: value)` em vez de `withOpacity()`
- [ ] Garantir uma única chamada `Theme.of(context)` por widget
- [ ] Testar em diferentes tamanhos de tela
- [ ] Verificar contraste e acessibilidade

---

*Esta documentação deve ser seguida por todos os desenvolvedores para manter a consistência visual do app.*
