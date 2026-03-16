import 'package:flutter/material.dart';

/// Standard responsive switcher for mobile, tablet, and desktop layouts.
class ResponsiveLayoutWidget extends StatelessWidget {
  /// Creates a responsive layout using width breakpoints.
  const ResponsiveLayoutWidget({
    super.key,
    required this.mobileBuilder,
    required this.desktopBuilder,
    this.tabletBuilder,
    this.tabletBreakpoint = 768,
    this.desktopBreakpoint = 1200,
  });

  /// Builder used when width is smaller than [tabletBreakpoint].
  final WidgetBuilder mobileBuilder;

  /// Builder used when width is between [tabletBreakpoint] and [desktopBreakpoint].
  ///
  /// When omitted, [mobileBuilder] is used for tablet sizes.
  final WidgetBuilder? tabletBuilder;

  /// Builder used when width is greater than or equal to [desktopBreakpoint].
  final WidgetBuilder desktopBuilder;

  /// Width threshold where tablet layout starts.
  final double tabletBreakpoint;

  /// Width threshold where desktop layout starts.
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth < tabletBreakpoint) {
          return mobileBuilder(context);
        }
        if (maxWidth < desktopBreakpoint) {
          final builder = tabletBuilder ?? mobileBuilder;
          return builder(context);
        }
        return desktopBuilder(context);
      },
    );
  }
}
