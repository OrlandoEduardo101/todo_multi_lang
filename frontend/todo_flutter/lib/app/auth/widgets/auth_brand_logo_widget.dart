import 'package:flutter/material.dart';

/// Renders the circular brand logo used in authentication screens.
///
/// The visual style follows the app theme and adapts to light/dark modes.
class AuthBrandLogoWidget extends StatelessWidget {
  /// Creates an authentication brand logo with a configurable [size].
  const AuthBrandLogoWidget({super.key, required this.size});

  /// Diameter used for both width and height.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.onPrimary.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 48, spreadRadius: 4),
        ],
      ),
      child: Icon(Icons.checklist_rounded, color: theme.colorScheme.onPrimary, size: size * 0.45),
    );
  }
}
