import 'package:flutter/material.dart';

import 'auth_brand_logo_widget.dart';
import 'auth_brand_title_widget.dart';

/// A full-height authentication panel with gradient, branding, and highlights.
///
/// This widget is intended for wide layouts such as desktop login screens.
class AuthBrandPanelWidget extends StatelessWidget {
  /// Creates the brand panel with optional custom [featureLabels].
  const AuthBrandPanelWidget({
    super.key,
    this.featureLabels = const [
      'Organize suas tarefas com clareza',
      'Sincronize em todos os dispositivos',
      'Seus dados protegidos e seguros',
    ],
  });

  /// Feature texts shown under the title section.
  final List<String> featureLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icons = <IconData>[Icons.check_circle_outline_rounded, Icons.sync_rounded, Icons.security_rounded];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primaryContainer, theme.colorScheme.primary, theme.colorScheme.secondary],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthBrandLogoWidget(size: 100),
                const SizedBox(height: 32),
                AuthBrandTitleWidget(
                  titleColor: theme.colorScheme.onPrimary,
                  subtitleColor: theme.colorScheme.onPrimary.withValues(alpha: 0.65),
                  titleSize: 44,
                ),
                const SizedBox(height: 56),
                for (var index = 0; index < featureLabels.length; index++) ...[
                  _FeatureBulletWidget(
                    icon: index < icons.length ? icons[index] : Icons.check_circle_outline_rounded,
                    label: featureLabels[index],
                    color: theme.colorScheme.onPrimary,
                  ),
                  if (index < featureLabels.length - 1) const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureBulletWidget extends StatelessWidget {
  const _FeatureBulletWidget({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.85), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
