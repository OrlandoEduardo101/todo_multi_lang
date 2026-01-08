# AI Development Rules

**Development guidelines for AI-assisted coding in the TODO Flutter project**

> 📋 **Reference**: For detailed architecture patterns, see [ARCHITECTURE.md](./ARCHITECTURE.md)
> 📋 **Implementation**: For state management implementation details, see [state-management.md](./state-management.md)
> 📋 **Theme Usage**: For complete theme usage guide, see [theme-usage-guide.md](./theme-usage-guide.md)

## Project Context

**TODO Flutter** is a telemedicine platform connecting patients, doctors, and administrators through fast consultations with configurable pricing, Mercado Pago payments with automatic split, and complete administrative control with Firebase backend.

### User Types
- **Patients**: Book and attend consultations
- **Doctors**: Provide consultations (require admin approval)
- **Administrators**: Manage platform, validate doctors, control pricing, generate reports

## 🚫 Prohibited Patterns

### Architecture Violations
- **NEVER** use GetX - completely migrated to result_command + Routefly + AutoInjector
- **NEVER** use Firebase directly in screens, widgets, or stores
- **NEVER** create .route.dart files - Routefly auto-generates routes
- **NEVER** use direct instantiation of services/repositories in widgets
- **NEVER** use Controller pattern - use Stores instead
- **NEVER** create Commands outside Stores

### Code Violations
- **NEVER** use `print()` - use `log()` from `dart:developer`
- **NEVER** use comments in code
- **NEVER** use methods to build layouts - create custom widgets
- **NEVER** use `withOpacity()` - use `withValues(alpha:)`
- **NEVER** use hardcoded colors/styles - use theme
- **NEVER** use `CircularProgressIndicator` for loading states - use shimmer effects

### UI State Listening Violations
- **NEVER** use `ListenableBuilder` to listen to entire Stores
- **NEVER** listen to Store objects directly in UI
- **ALWAYS** use `ValueListenableBuilder` to listen to specific Commands only
- **ALWAYS** listen to individual Commands (e.g., `store.loadDataCommand`, `store.saveCommand`)
- **NEVER** rebuild entire UI when only one command state changes

### Temporary files and scratch artefacts

- **NEVER** keep temporary or scratch files in the repository long-term (for example: files named with suffixes like `_refactored.dart`, `_new.dart`, `_tmp.dart`, or similar). These files are allowed only as short-lived working artifacts while refactoring or experimenting.
- **ALWAYS** follow this workflow for temporary files:
  - Create temporary files only on a feature branch for experimentation.
  - Use them to iterate quickly, then copy or merge the final changes into the official file following the project's naming conventions (see Code Style Rules).
  - Delete all temporary/scratch files before merging the branch or creating a pull request so the repository only contains the canonical file(s).
- **ALWAYS** prefer branches and commits to preserve history instead of leaving multiple variant files in the tree.
- **ALWAYS** run a quick check before committing (or configure CI) to detect and reject files matching common temporary patterns (e.g. `*_refactored.dart`, `*_new.dart`, `*_tmp.dart`, `*.bak`, `*.old`).
- Rationale: temporary files clutter the codebase, confuse reviewers, and break the single-source-of-truth rule; keeping only the official file names preserves consistency with `ai-notes` naming rules.

### Theme and Style Violations
- **NEVER** use `AppColors.*` directly - use `theme.colorScheme.*`
- **NEVER** use `AppTextStyles.*` directly - use `theme.textTheme.*`
- **NEVER** use `Colors.*` directly - use theme colors
- **NEVER** use hardcoded `Color(0xFF...)` values
- **NEVER** use multiple `Theme.of(context)` calls in same widget - cache it
- **NEVER** mix AppColors with theme colors in same widget

## ✅ Required Patterns

### State Management Rules
- **ALWAYS** use `result_command` Commands for business logic
- **ALWAYS** create Commands inside Stores (not separate bindings)
- **ALWAYS** use Stores to replace Controllers
- **ALWAYS** return `Success()` or `Failure()` from Commands for UI state handling
- **ALWAYS** declare Commands with `late final` and assign immediately:
  ```dart
  late final Command0<OutputType> myCommand = Command0<OutputType>(_onMyAction);
  ```
- **ALWAYS** create private methods for Command execution:
  ```dart
  Future<OutputType> _onMyAction() async {
    // Implementation here
  }
  ```

### Navigation Rules
- **ALWAYS** use `Routefly.navigate()` or `Routefly.push()` for navigation
- **ALWAYS** place pages in `lib/app/` folder structure ending with `_page.dart`
- **ALWAYS** run `dart run routefly` after adding/removing pages
- **ALWAYS** create parameter classes for pages needing arguments (Routefly doesn't accept constructor arguments)
- **ALWAYS** get arguments via: `final args = Routefly.of(context).query.arguments;`
- **ALWAYS** implement role-based navigation (patient/doctor/admin routes)
- **ALWAYS** protect admin routes with proper middleware

### Data Layer Rules (Simplified)
- **ALWAYS** create repository interfaces in `domain/repositories/`
- **ALWAYS** implement repositories in `data/repositories/` using Firebase directly
- **ALWAYS** use entities with Firebase adapters (`fromFirestore`, `toFirestore`)
- **ALWAYS** return entities from repository methods
- **ALWAYS** handle Firebase exceptions in repository implementations
- **ALWAYS** convert Firebase exceptions to domain exceptions
- **NEVER** create unnecessary datasources or DTOs (use entities with adapters)

### Domain Layer Rules
- **ALWAYS** place business entities in `domain/entities/`
- **ALWAYS** add Firebase adapters to entities (`fromFirestore`, `toFirestore`)
- **ALWAYS** place repository interfaces in `domain/repositories/`
- **ALWAYS** place domain exceptions in `domain/errors/`
- **ALWAYS** place enums in `domain/enums/`
- **ALWAYS** place typedefs in `domain/typedefs/`
- **ALWAYS** keep domain layer clean (Firebase adapters are acceptable)
- **NEVER** import from presentation or config layers

### Presentation Layer Rules
- **ALWAYS** use entities from domain layer in stores
- **ALWAYS** inject repository interfaces (not implementations)
- **ALWAYS** place Commands inside Stores (not separate bindings)
- **ALWAYS** handle entity-to-UI conversion in stores or widgets
- **NEVER** import repository implementations
- **NEVER** access Firebase directly from stores or widgets

### Dependency Injection Rules
- **ALWAYS** use `AppInjector.get<T>()` to resolve dependencies
- **ALWAYS** define modules in `core/injector/` for each feature
- **ALWAYS** inject dependencies via constructor parameters

## Dependency Injection Typing Rule

- **ALWAYS** type all dependency injections explicitly in the DI setup (e.g., `injector.addSingleton<PatientHomeStore>(PatientHomeStore.new);`).
- **ALWAYS** prefer using the `.new` constructor for singleton registrations (e.g., `injector.addSingleton<MyStore>(MyStore.new);`).
- **NEVER** use untyped or inferred types in dependency injection registration.
- **Rationale**: Explicit typing and `.new` usage improves code clarity, maintainability, and ensures correct singleton instantiation.

### UI and Design Rules
- **ALWAYS** use Theme system via `Theme.of(context)` for all colors and styles
- **ALWAYS** cache theme in widget: `final theme = Theme.of(context);`
- **ALWAYS** use semantic theme colors:
  ```dart
  // ✅ CORRECT - Theme colors
  color: theme.colorScheme.primary
  backgroundColor: theme.colorScheme.surface
  textStyle: theme.textTheme.bodyMedium

  // ❌ AVOID - Direct colors/styles
  color: AppColors.primary
  color: Colors.blue
  textStyle: AppTextStyles.bodyMedium
  textStyle: TextStyle(fontSize: 14)
  ```
- **ALWAYS** use `withValues(alpha:)` instead of `withOpacity()`:
  ```dart
  // ✅ CORRECT
  color: theme.colorScheme.primary.withValues(alpha: 0.1)

  // ❌ AVOID
  color: AppColors.primary.withOpacity(0.1)
  ```
- **ALWAYS** componentize interface with small, reusable widgets
- **ALWAYS** prefer custom widgets over `_build...()` methods
- **ALWAYS** use shimmer effects for loading states instead of CircularProgressIndicator:
  ```dart
  // ✅ CORRECT - Shimmer loading for content
  return Shimmer.fromColors(
    baseColor: theme.colorScheme.surface,
    highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
    child: Container(
      height: 20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  // ❌ AVOID - CircularProgressIndicator for content loading
  const CircularProgressIndicator()
  ```
- **ALWAYS** use shimmer for card/list loading states to maintain layout structure
- **ALWAYS** use small CircularProgressIndicator only for button loading states (20x20px max)

### Theme Usage Rules
- **ALWAYS** access theme once per widget and cache it
- **ALWAYS** use semantic color names (primary, surface, error, etc.)
- **ALWAYS** prefer theme colors over AppColors for consistency:
  ```dart
  // Color mapping AppColors → Theme
  AppColors.primary          → theme.colorScheme.primary
  AppColors.success          → theme.colorScheme.tertiary
  AppColors.error            → theme.colorScheme.error
  AppColors.textPrimary      → theme.colorScheme.onSurface
  AppColors.textSecondary    → theme.colorScheme.onSurfaceVariant
  AppColors.surface          → theme.colorScheme.surface
  AppColors.background       → theme.scaffoldBackgroundColor
  AppColors.border           → theme.colorScheme.outline
  ```
- **ALWAYS** use theme text styles:
  ```dart
  // Style mapping AppTextStyles → Theme
  AppTextStyles.headlineMedium → theme.textTheme.headlineMedium
  AppTextStyles.bodyMedium     → theme.textTheme.bodyMedium
  AppTextStyles.bodySmall      → theme.textTheme.bodySmall
  AppTextStyles.labelLarge     → theme.textTheme.labelLarge
  ```

### Lifecycle Rules
- **ALWAYS** use `initState()` for: initial calls, add listeners, configure controllers
- **ALWAYS** use `dispose()` for: remove listeners, clean controllers, cancel timers
- **ALWAYS** dispose Stores properly to prevent memory leaks

### Constructor vs initState (important rule)
- **NEVER** execute commands, async methods, or perform side-effectful initialization in a class constructor (State, Store or other). Constructors must stay synchronous and lightweight.
- **ALWAYS** run commands, start listeners, call async initialization methods or execute side-effect code inside `initState()` of a `StatefulWidget` (or in a Store initialization method explicitly invoked from `initState()`), so lifecycle and context are correctly available.

### Store Management
- **ALWAYS** use `AutoInjector.get<StoreType>()` to obtain stores
- **ALWAYS** configure Command listeners in the `initState` of pages
- **ALWAYS** have Stores implement an `init()` method to configure/trigger initial commands
- **ALWAYS** prefer calling `store.init()` in `initState` instead of individual commands
- **ALWAYS** remember Stores are singleton and maintain state during application lifecycle

### File Organization and Cleanup
- **NEVER** keep empty or temporary files like `_refactored.dart`, `_new.dart`, `_temp.dart`, etc.
- **ALWAYS** remove temporary files as soon as refactoring is finalized
- **ALWAYS** keep only functional and necessary files in the project
- **ALWAYS** use descriptive and permanent names for files
- **ALWAYS** follow proper workflow for temporary files:
  - Create temporary files only on feature branches for experimentation
  - Use them to iterate quickly, then merge final changes into official files
  - Delete all temporary/scratch files before merging or creating pull requests
- **ALWAYS** run checks to detect files matching temporary patterns (`*_refactored.dart`, `*_new.dart`, `*_tmp.dart`, etc.)


### Code Style Rules
**ALWAYS** use English for file names, classes, variables, and methods
**ALWAYS** use Brazilian Portuguese for displayed texts in app
**ALWAYS** use snake_case for files
**ALWAYS** use snake_case for all folders (directories)
**ALWAYS** name files as [feature]_[type].dart (e.g., user_page.dart, user_store.dart, user_repository.dart)
**EXCEPTION:** Ignore these naming rules for generated files such as `*.g.dart`, `*.freezed.dart`, `*.route.dart` and similar auto-generated files.
**ALWAYS** use PascalCase for classes
**ALWAYS** use camelCase for variables and methods
**ALWAYS** use `log()` from `dart:developer` for debugging:
  ```dart
  import 'dart:developer';

  log('Debug message: $value');
  log('[DEBUG] Context info', name: 'ClassName');
  ```

## 📁 Required Project Structure

```
lib/
├── app/                     # Routefly routes (auto-generated)
├── core/
│   ├── injector/           # Global AutoInjector setup
│   ├── theme/              # AppColors, AppTextStyles
│   ├── utils/
│   └── widgets/
├── modules/
│   ├── shared/             # Common functionality (auth, etc.)
│   ├── patient/            # Patient-specific features
│   ├── doctor/             # Doctor-specific features
│   └── admin/              # Administrative features
│       ├── domain/         # Domain layer (Simplified Clean Architecture)
│       │   ├── entities/   # Business entities with Firebase adapters
│       │   ├── repositories/ # Repository interfaces
│       │   ├── errors/     # Domain exceptions
│       │   ├── enums/      # Domain enumerations
│       │   └── typedefs/   # Type definitions
│       ├── data/           # Data layer (Simplified)
│       │   └── repositories/ # Repository implementations (Firebase direct)
│       ├── presentation/   # Presentation layer
│       │   ├── pages/      # UI pages
│       │   ├── widgets/    # UI components
│       │   └── stores/     # Business logic (Commands)
│       └── config/         # Configuration layer
│           └── injector/   # Module DI configuration
├── firebase_options.dart
└── main.dart
```

#### **Simplified Clean Architecture Layer Rules**

#### **Domain Layer (Core Business Logic)**
- **ALWAYS** place entities in `domain/entities/` with Firebase adapters
- **ALWAYS** place repository interfaces in `domain/repositories/`
- **ALWAYS** place domain exceptions in `domain/errors/`
- **ALWAYS** place enums in `domain/enums/`
- **ALWAYS** place typedefs in `domain/typedefs/`
- **NEVER** import anything from presentation or config layers
- **ALWAYS** keep domain layer focused on business logic

#### **Data Layer (Simplified)**
- **ALWAYS** place repository implementations in `data/repositories/`
- **ALWAYS** use Firebase services directly in repositories
- **ALWAYS** implement domain repository interfaces
- **ALWAYS** use entities with Firebase adapters (no DTOs needed)
- **NEVER** create unnecessary datasources or models

#### **Presentation Layer (UI)**
- **ALWAYS** place stores in `presentation/stores/`
- **ALWAYS** place UI pages in `presentation/pages/`
- **ALWAYS** place widgets in `presentation/widgets/`
- **ALWAYS** depend only on domain layer (entities, repository interfaces)
- **NEVER** import from data layer directly

#### **Config Layer (DI Setup)**
- **ALWAYS** place dependency injection in `config/injector/`
- **ALWAYS** inject Firebase services directly into repositories
- **ALWAYS** inject repository interfaces, not implementations

## 🔄 Development Workflow

### Adding New Functionality (Simplified Clean Architecture)
1. **Domain Layer**:
   - Create business entities in `domain/entities/` with Firebase adapters
   - Create repository interfaces in `domain/repositories/`
   - Create domain exceptions in `domain/errors/`
   - Define typedefs in `domain/typedefs/`

2. **Data Layer**:
   - Implement repositories in `data/repositories/` using Firebase directly
   - Use entity Firebase adapters for data conversion

3. **Presentation Layer**:
   - Create Stores with Commands in `presentation/stores/`
   - Create UI pages in `presentation/pages/`
   - Create widgets in `presentation/widgets/`

4. **Config Layer**:
   - Configure dependencies in `config/injector/`
   - Wire repository interfaces to implementations with Firebase services

5. **Navigation & Routes**:
   - Create pages in `lib/app/` structure
   - Run `dart run routefly` to generate routes

### Entity with Firebase Adapters Pattern
```dart
// 1. Domain Entity with Firebase integration
// domain/entities/patient_entity.dart
class PatientEntity {
  final String id;
  final String name;
  final String email;

  const PatientEntity({required this.id, required this.name, required this.email});

  // Business logic
  bool get hasValidName => name.isNotEmpty;

  // Firebase adapters in entity
  factory PatientEntity.fromFirestore(Map<String, dynamic> data, String id) {
    return PatientEntity(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
    };
  }
}

// 2. Repository Implementation (Data Layer)
// data/repositories/patient_repository_impl.dart
class PatientRepositoryImpl implements PatientRepository {
  final FirebaseFirestore _firestore;

  PatientRepositoryImpl(this._firestore);

  @override
  Future<Result<PatientEntity>> getPatient(String id) async {
    try {
      final doc = await _firestore.collection('patients').doc(id).get();
      if (doc.exists) {
        final patient = PatientEntity.fromFirestore(doc.data()!, doc.id);
        return Success(patient);
      } else {
        return Failure(PatientNotFoundException());
      }
    } catch (e) {
      return Failure(PatientException(e.toString()));
    }
  }

  @override
  Future<Result<void>> savePatient(PatientEntity patient) async {
    try {
      await _firestore.collection('patients').doc(patient.id).set(patient.toFirestore());
      return Success(unit);
    } catch (e) {
      return Failure(PatientException('Failed to save patient: $e'));
    }
  }
}
```

### Page Creation Pattern
1. Create `_page.dart` file in `lib/app/` folder structure
2. Get Store via `AppInjector.get<Store>()`
3. Use `ValueListenableBuilder` to react to Command states
4. Handle all states with pattern matching
5. Implement proper lifecycle (initState/dispose)

### Command Pattern Implementation
1. Create Command inside Store with `late final`
2. Implement private method for Command execution
3. Handle `AsyncResult` from repository with `.fold()`
4. Return `Success()` or `Failure()` for UI state management
5. Dispose Commands in Store's dispose method

## 🧪 Testing Requirements

- **Unit Tests**: Commands business logic with mocked repositories
- **Widget Tests**: UI components with mocked Stores
- **Integration Tests**: Complete flows with Firebase Emulator
- **Always** mock dependencies properly
- **Always** test all Command states


## AI Attention Points

### Known Issues
1. **Kotlin Compatibility**: Stripe package requires Kotlin 1.9+
2. **Firebase Setup**: Verify correct configuration
3. **Stripe Webhooks**: Configure endpoints correctly
4. **Responsive Design**: Test on different sizes

### Frequent Tasks
1. **Add new screen**: Create `_page.dart` in `lib/app/` folder structure
2. **Implement functionality**: Use Commands pattern inside Stores with result_command
3. **Styling**: Use AppColors and AppTextStyles from theme
4. **Navigation**: Use Routefly navigation methods
5. **Dependencies**: Configure in AutoInjector modules
6. **State management**: Create Stores with Commands for business logic

### Development and Testing
- Use Firebase Emulator for local development
- Test responsiveness in Chrome DevTools
- Validate payment flows with Stripe test keys
- Test authentication with test accounts
- Run `dart run routefly` to generate routes after adding pages
- Follow existing module patterns for consistency
- Implement proper error handling and loading states

## 📱 Responsive Design Requirements

### Breakpoints
- **Mobile**: < 600px (single column, bottom navigation)
- **Tablet**: 600px - 1024px (adaptive layout)
- **Desktop**: > 1024px (two-column, persistent navigation)

### Layout Patterns
- **Mobile**: Single column, bottom navigation
- **Tablet**: Adaptive layout, optional side navigation
- **Desktop**: Two-column layout, persistent navigation

### Implementation
- Use responsive widgets and layouts
- Test on Chrome DevTools for different sizes
- Ensure touch targets are appropriate for each platform

## 🔐 Security Requirements

### Firebase Access
- **Only** access Firebase through repository layer
- **Never** use Firebase instances directly in UI or Stores
- Handle all Firebase exceptions in repositories

### Frontend Validation
- Validate input data
- Sanitize inputs
- Verify authentication before sensitive actions

### Backend Security (Firebase Rules)
```javascript
// Appointments - only patient can create, doctor can read
allow create: if isPatient() && resource.data.patientId == request.auth.uid;
allow read: if isDoctor() || isOwner();
```

## 🚀 Deploy and CI/CD

### Environments
- **Development**: Firebase Emulator
- **Staging**: Firebase Project (staging)
- **Production**: Firebase Project (prod)

### Deploy Commands
```bash
# Functions
firebase deploy --only functions

# Hosting (Web)
firebase deploy --only hosting

# Firestore Rules
firebase deploy --only firestore:rules
```

## 🔍 Useful Resources

### Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [result_command Documentation](https://pub.dev/packages/result_command)
- [Routefly Documentation](https://pub.dev/packages/routefly)
- [auto_injector Documentation](https://pub.dev/packages/auto_injector)
- [Firebase Docs](https://firebase.google.com/docs)
- [Stripe Flutter](https://docs.stripe.com/mobile/flutter)
- [Shimmer Documentation](https://pub.dev/packages/shimmer)

### Design Resources
- [Material Design 3](https://m3.material.io/)
- [Flutter Widget Catalog](https://docs.flutter.dev/ui/widgets)

## 🤖 Prompt Templates for AI

### To add new functionality:
```
"Implement a [DESCRIPTION] functionality following TODO Flutter App simplified patterns:
- Use Commands pattern inside Stores for state management
- Use Routefly for navigation (create _page.dart in lib/app/)
- Use AutoInjector for dependency injection
- Follow simplified modular structure: domain/entities (with Firebase adapters), data/repositories (Firebase direct), presentation/stores
- Use entities with Firebase adapters instead of DTOs
- Repositories use Firebase services directly (no datasources)
- Use Theme system for all styling
- Implement proper lifecycle (initState/dispose)
- Handle all Command states (Running/Success/Failure)
- Run 'dart run routefly' to generate routes"
```

### For architecture work:
```
"Implement [FEATURE] following simplified Clean Architecture:
- Domain entities with Firebase adapters (fromFirestore/toFirestore)
- Repository interfaces in domain, implementations in data using Firebase directly
- Stores with Commands in presentation layer
- Modular dependency injection with Firebase services
- No unnecessary datasources or DTOs - keep it simple but maintainable"
```

### For bug fixes:
```
"Analyze the error [ERROR] in TODO Flutter project considering:
- Commands pattern structure inside Stores
- Routefly navigation setup
- AutoInjector configuration
- Firebase configuration
- Stripe integration
- Responsive design patterns
- Proper error handling"
```

### For optimization:
```
"Optimize [COMPONENT] of TODO Flutter App considering:
- Flutter performance best practices
- Commands pattern lifecycle management
- AutoInjector singleton management
- Firebase best practices
- User experience and loading states"
```

## 🚀 Performance Requirements

- Use lazy loading for Commands and dependencies
- Implement proper caching with SharedPreferences
- Optimize images with CachedNetworkImage
- Use AutoInjector singletons for shared state
- Implement proper Command disposal to prevent memory leaks

## 🔍 Common Patterns to Follow

### Error Handling
```dart
// Repository level
try {
  final data = await _firestore.collection('items').get();
  return Success(data);
} catch (e) {
  return Failure(Exception('Failed to load: $e'));
}

// Command level
final result = await _repository.getData();
return result.fold(
  (data) => Success(data),
  (error) => Failure(error),
);

// UI level
return switch (state) {
  RunningCommand() => const ShimmerLoading(),
  SuccessCommand(:final value) => DataWidget(value),
  FailureCommand(:final error) => ErrorWidget(error),
  _ => const SizedBox.shrink(),
};
```

### Navigation with Arguments
```dart
// Define parameter class
class BookingParams {
  final String doctorId;
  final DateTime dateTime;
  BookingParams({required this.doctorId, required this.dateTime});
}

// Navigate with arguments
Routefly.push('/patient/booking', arguments: bookingParams);

// Receive arguments
final args = Routefly.of(context).query.arguments as BookingParams?;
```

### Loading Patterns
```dart
// ✅ CORRECT - Shimmer for content loading (cards, lists, etc.)
Widget buildShimmerCard() {
  final theme = Theme.of(context);
  return Shimmer.fromColors(
    baseColor: theme.colorScheme.surface,
    highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ✅ CORRECT - Small CircularProgressIndicator for button actions only
ElevatedButton(
  onPressed: isLoading ? null : () => command.execute(),
  child: isLoading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Text('Save'),
)

// ❌ AVOID - CircularProgressIndicator for content areas
Widget build(BuildContext context) {
  return isLoading
      ? const CircularProgressIndicator() // ❌ Bad UX
      : const DataList();
}
```

## 🎯 AI Assistant Instructions

When implementing features:
1. **Always** reference this document for development rules
2. **Always** check [ARCHITECTURE.md](./ARCHITECTURE.md) for architecture patterns
3. **Always** follow the exact patterns shown in examples
4. **Always** use [theme-usage-guide.md](./theme-usage-guide.md) for styling
5. **Always** implement proper error handling and loading states
6. **Always** ensure responsiveness across all platforms
7. **Always** test the implementation thoroughly

### For New Features
- Start with repository interface and implementation
- Create Store with Commands inside
- Build UI with proper state handling using Theme system
- Configure dependency injection
- Test all paths and edge cases

### For UI Development
- Cache Theme once per widget: `final theme = Theme.of(context);`
- Use semantic colors: `theme.colorScheme.primary`, `theme.colorScheme.surface`
- Use theme text styles: `theme.textTheme.bodyMedium`, `theme.textTheme.headlineLarge`
- Use `withValues(alpha:)` instead of `withOpacity()`
- Avoid AppColors and AppTextStyles - migrate to Theme system

### For Bug Fixes
- Check if issue is in repository, store, or UI layer
- Verify proper error handling is implemented
- Ensure all Command states are handled in UI
- Verify theme usage is consistent
- Test fix doesn't break existing functionality

## 🎨 Theme System Quick Reference

### Essential Theme Patterns
```dart
// ✅ CORRECT Theme Usage
Widget build(BuildContext context) {
  final theme = Theme.of(context); // Cache theme once

  return Container(
    color: theme.colorScheme.surface,           // Semantic color
    child: Text(
      'Hello World',
      style: theme.textTheme.bodyMedium,        // Theme text style
    ),
  );
}

// ✅ CORRECT Transparency
color: theme.colorScheme.primary.withValues(alpha: 0.1)

// ❌ AVOID These Patterns
color: AppColors.primary                      // Use theme.colorScheme.primary
style: AppTextStyles.bodyMedium              // Use theme.textTheme.bodyMedium
color: Colors.blue                           // Use semantic theme colors
color: Color(0xFF123456)                     // Use theme colors
color: theme.colorScheme.primary.withOpacity(0.1) // Use withValues(alpha:)
```

### Color Migration Map
```dart
// Old AppColors → New Theme Colors
AppColors.primary         → theme.colorScheme.primary
AppColors.success         → theme.colorScheme.tertiary
AppColors.error           → theme.colorScheme.error
AppColors.textPrimary     → theme.colorScheme.onSurface
AppColors.textSecondary   → theme.colorScheme.onSurfaceVariant
AppColors.surface         → theme.colorScheme.surface
AppColors.background      → theme.scaffoldBackgroundColor
AppColors.border          → theme.colorScheme.outline
```

### Text Style Migration Map
```dart
// Old AppTextStyles → New Theme Styles
AppTextStyles.headlineLarge   → theme.textTheme.headlineLarge
AppTextStyles.headlineMedium  → theme.textTheme.headlineMedium
AppTextStyles.bodyLarge       → theme.textTheme.bodyLarge
AppTextStyles.bodyMedium      → theme.textTheme.bodyMedium
AppTextStyles.bodySmall       → theme.textTheme.bodySmall
AppTextStyles.labelLarge      → theme.textTheme.labelLarge
```

---

*This document serves as the primary reference for AI-assisted development in the TODO Flutter project. Always consult this before implementing new features or making changes.*

## 🚨 TODOs Críticos Identificados

### 📊 Status Atual - 28 TODOs Pendentes

#### 🏥 Patient Module (25 TODOs - ALTA PRIORIDADE)

**Sistema de Agendamento (2 TODOs)**
- `patient_booking_page.dart`: Implementar lógica de agendamento
- `patient_booking_page.dart`: Verificar disponibilidade real de horários

**Navegação de Médicos (4 TODOs)**
- `doctor_card.dart`: Navegação para detalhes do médico
- `recent_doctors_card.dart`: Navegação para detalhes do médico
- `patient_doctors_page.dart`: Visualizar perfil do médico
- `patient_doctors_page.dart`: Agendar consulta

**Sistema de Pagamentos (2 TODOs)**
- `patient_payment_store.dart`: Completar confirmação de pagamento com cartão
- `pix_payment_page.dart`: Implementar listener de status de pagamento

**Histórico e Avaliações (5 TODOs)**
- `patient_history_page.dart`: Substituir dados mock por dados reais
- `patient_history_page.dart`: Navegação para detalhes da consulta
- `patient_history_page.dart`: Navegação para página de avaliação
- `patient_doctor_ratings_page.dart`: Obter dados do médico dos argumentos da rota
- `patient_doctor_ratings_page.dart`: Enviar avaliação para o store

**Perfil e Configurações (6 TODOs)**
- `patient_profile_page.dart`: Navegação para editar perfil (2x)
- `patient_profile_page.dart`: Navegação para alterar senha
- `patient_profile_page.dart`: Navegação para ajuda
- `patient_edit_profile_page.dart`: Implementar seleção de foto
- `patient_edit_profile_page.dart`: Implementar lógica de salvar
- `patient_change_password_page.dart`: Implementar lógica de alteração de senha

**Suporte e Ajuda (3 TODOs)**
- `patient_help_page.dart`: Implementar ligação telefônica
- `patient_help_page.dart`: Implementar envio de email
- `patient_help_page.dart`: Implementar WhatsApp

#### 🩺 Doctor Module (2 TODOs)
- `today_appointment_card.dart`: Navegação para prontuário médico
- `doctor_schedule_store.dart`: Implementar lógica de criação de consultas

#### 🔐 Shared Module (1 TODO)
- `login_page.dart`: Conectar ao AuthStore ou commands

### 📋 Páginas Críticas Ausentes (9 páginas)

#### Admin Module:
- `admin_refunds_page.dart` - Gestão de reembolsos
- `admin_settings_page.dart` - Configurações do sistema

#### Doctor Module:
- `doctor_appointment_details_page.dart` - Detalhes de consultas
- `doctor_history_page.dart` - Histórico médico
- `doctor_medical_record_page.dart` - Prontuário eletrônico
- `doctor_patient_details_page.dart` - Detalhes do paciente
- `doctor_personal_data_page.dart` - Dados pessoais
- `doctor_profile_page.dart` - Perfil do médico

#### Patient Module:
- `patient_appointment_details_page.dart` - Detalhes das consultas

## 🏗️ Simplified Clean Architecture Migration Status

### ✅ Completed Migration:
1. **Shared Module** - Fully migrated to simplified Clean Architecture
2. **Patient Module** - Fully migrated to simplified Clean Architecture
3. **Doctor Module** - Fully migrated to simplified Clean Architecture
4. **Admin Module** - Fully migrated to simplified Clean Architecture

### Architecture Simplifications Made:
- ❌ **Removed**: Datasources (unnecessary abstraction layer)
- ❌ **Removed**: DTOs/Models (adapters moved to entities)
- ✅ **Kept**: Repository pattern (interface + implementation)
- ✅ **Kept**: Entities with Firebase adapters (`fromFirestore`, `toFirestore`)
- ✅ **Kept**: Dependency injection modular structure
- ✅ **Kept**: Result pattern for error handling

### Key Implementation Details:
- **Entities**: Include Firebase adapters for direct data conversion
- **Repositories**: Use Firebase services directly (no datasource layer)
- **Dependency Injection**: Firebase services injected directly into repositories
- **Error Handling**: Firebase exceptions converted to domain exceptions in repositories

### Current Structure:
```
modules/
├── shared/domain/entities/user_entity.dart           # ✅ With Firebase adapters
├── shared/data/repositories/auth_repository_impl.dart # ✅ Uses Firebase directly
├── shared/config/injector/shared_injector.dart       # ✅ Injects Firebase services
├── patient/data/repositories/patient_repository_impl.dart # ✅ Simplified implementation
├── doctor/data/repositories/doctor_repository_impl.dart   # ✅ Simplified implementation
└── admin/data/repositories/admin_repository_impl.dart     # ✅ Simplified implementation
```

### Next Steps for Implementation:
- [ ] Implement real Firebase operations in repository methods
- [ ] Update stores to use new repository interfaces
- [ ] Add comprehensive error handling for all operations
- [ ] Update UI components to work with new entity types

## 🚀 Clean Architecture Migration Status

### ✅ Completed Modules:
1. **Patient Module** - Fully migrated to Clean Architecture
2. **Shared Module** - Fully migrated to Clean Architecture
3. **Doctor Module** - Fully migrated to Clean Architecture
4. **Admin Module** - Fully migrated to Clean Architecture

### Migration Summary:
- ✅ All domain entities created
- ✅ All repository interfaces moved to domain layer
- ✅ All DTOs created in data layer with conversion methods
- ✅ All error classes organized by module
- ✅ All enums moved to appropriate domain layers
- ✅ Typedefs created for Result types
- ✅ Modular injectors created for each module
- ✅ Main injector updated to use modular structure

### Architecture Compliance:
- ✅ Domain layer: Contains entities, repository interfaces, errors, enums, typedefs
- ✅ Data layer: Contains DTOs, datasource interfaces, repository implementations
- ✅ Presentation layer: Contains stores, pages, widgets
- ✅ Config layer: Contains dependency injection setup

### Next Steps:
- [ ] Create concrete DataSource implementations (Firebase/Firestore)
- [ ] Update stores to use new repository interfaces
- [ ] Add comprehensive unit tests for each layer
- [ ] Update UI components to use new entity types

### 🎯 Próximas Prioridades

1. **URGENTE**: Sistema de Agendamento - Implementar Commands e verificação
2. **ALTA**: Sistema de Pagamentos - Finalizar confirmação e listeners
3. **MÉDIA**: Páginas do Médico - Criar páginas ausentes
4. **BAIXA**: Finalizar Migração de Tema - Completar patient module
