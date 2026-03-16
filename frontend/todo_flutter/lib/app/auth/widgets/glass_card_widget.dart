import 'package:flutter/material.dart';

/// A themed glass-like card container for elevated content over gradients.
class GlassCardWidget extends StatelessWidget {
  /// Creates a glass card using [color], [borderColor], and [child].
  const GlassCardWidget({super.key, required this.color, required this.borderColor, required this.child});

  /// Background fill color for the card.
  final Color color;

  /// Border color for the card outline.
  final Color borderColor;

  /// Content rendered inside the card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}
