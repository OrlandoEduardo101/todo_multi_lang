import 'package:flutter/material.dart';

/// Displays the authentication brand title and subtitle.
///
/// Use this widget in splash and login screens to keep brand identity
/// consistent across layouts.
class AuthBrandTitleWidget extends StatelessWidget {
  /// Creates a title block using [titleColor], [subtitleColor], and [titleSize].
  const AuthBrandTitleWidget({super.key, required this.titleColor, required this.subtitleColor, this.titleSize = 36});

  /// Color used by the main product title text.
  final Color titleColor;

  /// Color used by the supporting subtitle text.
  final Color subtitleColor;

  /// Font size for the main title text.
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Todo',
          style: TextStyle(
            color: titleColor,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text('Organize seu dia com clareza', style: TextStyle(color: subtitleColor, fontSize: 14, letterSpacing: 0.3)),
      ],
    );
  }
}
