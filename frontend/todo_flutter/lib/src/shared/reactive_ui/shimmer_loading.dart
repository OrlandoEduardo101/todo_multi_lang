/// A widget that displays a shimmering effect to indicate loading state.
/// It uses an [AnimationController] to create a gradient animation that simulates a loading shimmer.
/// The [child] widget is wrapped with a [ShaderMask] that applies the shimmer effect. The shimmer animation continuously loops until the widget is disposed.
/// This widget can be used as a placeholder while content is being loaded, providing a visually appealing loading indicator to users.
/// Example usage:
/// ```dart
/// ShimmerLoading(
///   child: Container(
///     width: double.infinity,
///     height: 100,
///     color: Colors.grey[300],
///   ),
/// );
/// ```

import 'package:flutter/material.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key, required this.child});

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerPercent = _controller.value;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFFFFFFF),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                (shimmerPercent - 0.4).clamp(0.0, 1.0),
                (shimmerPercent - 0.2).clamp(0.0, 1.0),
                shimmerPercent.clamp(0.0, 1.0),
                (shimmerPercent + 0.2).clamp(0.0, 1.0),
                (shimmerPercent + 0.4).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
