# Screen Componentization AI-Ready Guide

## Objective

This guide defines how to split Flutter screens into reusable widgets in this project while preserving architecture rules, theme consistency, and responsive behavior.

## Mandatory Principles

- Keep business logic inside Stores.
- Keep navigation in page-level widgets.
- Keep shared UI in `lib/src/shared/widgets`.
- Keep feature-specific UI near the feature page.
- Use Theme APIs for all visual tokens.
- Use `withValues(alpha:)` for transparency.
- Use Dart Doc (`///`) in every reusable shared widget.
- Prefer composition over inheritance.

## Where to Place Components

- `lib/src/shared/widgets`: cross-feature reusable widgets (e.g. `ResponsiveLayoutWidget`).
- `lib/app/<module>/widgets/`: widgets that are specific to a module and not reused elsewhere (e.g. auth brand widgets live in `lib/app/auth/widgets/`).
- `lib/app/<feature>/`: route entry pages (`*_page.dart`).
- `lib/src/modules/<feature>/pages`: feature pages with orchestration only.
- `lib/src/modules/<feature>/widgets`: feature-only components.

### Module-specific vs shared

- Place a widget in `lib/app/<module>/widgets/` when it belongs conceptually to one module and is not reused by other modules.
- Place a widget in `lib/src/shared/widgets/` only when it is already used — or clearly intended to be used — by two or more unrelated modules.
- Do not pre-emptively promote module widgets to shared; wait for actual reuse to emerge.

## Screen Composition Pattern

A screen should be split into three layers:

1. Orchestration layer
- Owns lifecycle (`initState`, `dispose`).
- Binds store commands and listeners.
- Performs route transitions.

2. Layout layer
- Switches by breakpoints.
- Chooses mobile/tablet/desktop structure.

3. Visual components layer
- Contains reusable stateless widgets.
- Receives data/callbacks via constructor.
- Has no side effects.

## Responsive Rules

- Mobile: single-column flow.
- Tablet: adaptive spacing and constrained width.
- Desktop: two-column or split layout when useful.
- Do not duplicate business logic across breakpoints.
- Share the same form/state source across layouts.

## Component Granularity Rules

Create a shared component when at least one condition is true:

- It appears in two or more screens.
- It contains a stable visual identity block (brand header, shell, card).
- It is a reusable container pattern (panel, card, section wrapper).

Keep local to the page when:

- The widget depends on page-only store details.
- It is small and not reused.

## API Design Rules for Shared Widgets

- Expose only required constructor parameters.
- Use explicit types.
- Keep widgets immutable.
- Prefer `const` constructors.
- Avoid passing full stores to shared visual widgets.
- Pass primitive values and callbacks instead.

## Dart Doc Standard

Each public shared widget must include:

- One summary line explaining purpose.
- Optional second paragraph with usage scope.
- Dart Doc for constructor and important public fields.

Example:

```dart
/// Renders the brand logo used by authentication screens.
class AuthBrandLogoWidget extends StatelessWidget {
  /// Creates the logo with a configurable [size].
  const AuthBrandLogoWidget({super.key, required this.size});

  /// Diameter used by the logo container.
  final double size;
}
```

## Theme and Styling Rules

- Cache theme once per widget: `final theme = Theme.of(context);`
- Use `theme.colorScheme.*` and `theme.textTheme.*`.
- Avoid direct `Colors.*` and `Color(0xFF...)` in reusable components.
- Keep spacing tokens consistent (`8`, `12`, `16`, `20`, `24`, `32`, `40`, `56`).

## State Listening Rules in UI

- Observe command-level state only.
- Do not listen to entire stores in shared widgets.
- Keep listeners in page orchestration or feature widgets.
- Shared widgets should stay presentation-only.

## Suggested Naming Convention

Use suffixes to communicate intent:

- `*_panel_widget.dart`
- `*_card_widget.dart`
- `*_title_widget.dart`
- `*_logo_widget.dart`
- `*_section_widget.dart`

## AI Execution Checklist

Before finalizing a componentization task:

1. Is route entry still in `lib/app`?
2. Is business logic still in Store/Repository?
3. Are module-specific widgets in `lib/app/<module>/widgets/`?
4. Are cross-feature widgets in `lib/src/shared/widgets/`?
5. Do all public widgets include Dart Doc?
6. Is responsive behavior preserved on mobile and desktop?
7. Is Theme usage fully semantic?
8. Is static analysis clean?

## Example Applied in This Project

Authentication screen componentization:

Module-specific widgets in `lib/app/auth/widgets/`:

- `auth_brand_logo_widget.dart`
- `auth_brand_title_widget.dart`
- `auth_brand_panel_widget.dart`
- `auth_login_form_widget.dart`
- `glass_card_widget.dart`

Cross-feature widget in `lib/src/shared/widgets/`:

- `responsive_layout_widget.dart` (used by any module)

`lib/app/auth/login/login_page.dart` orchestrates auth command listening and layout switching. Auth-specific visual blocks live co-located under `lib/app/auth/widgets/` since they are not reused outside the auth module.
