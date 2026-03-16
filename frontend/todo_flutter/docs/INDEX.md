# Documentation Index — Todo Flutter

This folder contains all developer and AI documentation for the `todo_flutter` app.

---

## Quick Navigation

| Goal | Start here |
|---|---|
| Understand the full architecture | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Get coding/AI development rules | [ai-notes.md](./ai-notes.md) |
| Understand navigation/routing | [routes-navigation-system.md](./routes-navigation-system.md) |
| Understand dependency injection | [dependency-injector.md](./dependency-injector.md) |
| Build responsive layouts | [responsive-layout.md](./responsive-layout.md) |
| Split a screen into components | [screen-componentization-ai-ready.md](./screen-componentization-ai-ready.md) |
| Use the theme correctly | [theme-usage-guide.md](./theme-usage-guide.md) |

---

## All Documents

### [ARCHITECTURE.md](./ARCHITECTURE.md)
**Full architecture reference.** Covers folder structure, layer responsibilities (Presentation, Store, Domain, Data, Infrastructure), state management with `RxCommand`/`StreamRxCommand`, dependency injection wiring, navigation routes, offline-first sync flow, error handling with `Either`, data models (`TodoModel`, `UserModel`), and sequence diagrams for Login and Offline Todo Create.

*Start here if you are joining the project.*

---

### [ai-notes.md](./ai-notes.md)
**Coding rules and prohibited/required patterns.** Lists what to never do (GetX, direct Firebase, hardcoded colors, etc.) and what is always required (RxCommand usage, listener lifecycle, theme tokens, file naming convention, DI registration style). Includes project structure, development workflow for adding pages/features/commands, and testing guidelines.

*Read this before writing any code.*

---

### [dependency-injector.md](./dependency-injector.md)
**`auto_injector` guide.** Explains how to define feature modules, register singletons and lazy singletons, commit the container, and resolve dependencies in pages. Shows concrete examples matching the actual module structure of this project.

---

### [routes-navigation-system.md](./routes-navigation-system.md)
**`routefly` navigation guide.** Explains file-based route generation, how to add routes, how to navigate (`Routefly.navigate`, `Routefly.push`, `Routefly.pop`), how to pass arguments, and how to run `dart run routefly` to regenerate route files.

---

### [responsive-layout.md](./responsive-layout.md)
**Responsive and adaptive layout standard.** Defines the hybrid Mobile-First + breakpoint strategy, the mandatory screen structure (orchestration → layout → visual components), global breakpoint constants (`kTabletBreakpoint = 768`, `kDesktopBreakpoint = 1200`), adaptive component patterns (BottomNavigationBar / NavigationRail / NavigationDrawer), and prohibited patterns (fixed widths, duplicated logic per breakpoint).

---

### [screen-componentization-ai-ready.md](./screen-componentization-ai-ready.md)
**Widget componentization rules.** Defines where to place components (`lib/app/<module>/widgets/` vs `lib/src/shared/widgets/`), the three-layer screen pattern (orchestration / layout / visual), granularity rules for when to create a shared vs local widget, API design rules, Dart Doc standards, and naming conventions.

---

### [theme-usage-guide.md](./theme-usage-guide.md)
**Theme and color system reference.** Shows the full `ColorScheme` and `TextTheme` token map, the mapping from legacy `AppColors`/`AppTextStyles` to theme tokens, correct usage of `withValues(alpha:)` for transparency, and a cheatsheet for the most common UI cases.

---

## Recommended Reading Order

**For a new developer:**
1. [README.md](../README.md) — project overview and setup
2. [ARCHITECTURE.md](./ARCHITECTURE.md) — understand the system design
3. [ai-notes.md](./ai-notes.md) — learn the coding rules before writing code
4. [dependency-injector.md](./dependency-injector.md) — understand how DI works
5. [routes-navigation-system.md](./routes-navigation-system.md) — understand routing

**For a new AI agent:**
1. [ai-notes.md](./ai-notes.md) — mandatory rules (read fully)
2. [ARCHITECTURE.md](./ARCHITECTURE.md) — full context
3. [screen-componentization-ai-ready.md](./screen-componentization-ai-ready.md) — component placement rules
4. [theme-usage-guide.md](./theme-usage-guide.md) — styling rules
5. [responsive-layout.md](./responsive-layout.md) — layout rules
