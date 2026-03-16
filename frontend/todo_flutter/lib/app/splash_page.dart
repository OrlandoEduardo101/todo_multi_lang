import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:todo_flutter/app/app_widget.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final AuthStore authStore = authModule.get<AuthStore>();

  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final AnimationController _dotsController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);

    _dotsController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic));
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    authStore.watchAuthCommand.addListener(_onAuthChanged);

    // If auth state is already available (global watcher), navigate immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onAuthChanged();
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final auth = authStore.watchAuthCommand.value;
    if (auth == null) return;
    final isLoggedIn = auth.user is LoggedUserModel;
    Routefly.navigate(isLoggedIn ? routePaths.home : routePaths.auth.login);
  }

  @override
  void dispose() {
    authStore.watchAuthCommand.removeListener(_onAuthChanged);
    _fadeController.dispose();
    _pulseController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4527A0), Color(0xFF7B1FA2), Color(0xFF1A237E)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SizedBox.expand(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Animated logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: const Color(0xFF7B1FA2).withValues(alpha: 0.5),
                              blurRadius: 60,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 58),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // Title
                  SlideTransition(
                    position: _slideAnimation,
                    child: const Text(
                      'Todo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SlideTransition(
                    position: _slideAnimation,
                    child: Text(
                      'Organize seu dia com clareza',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Loading dots
                  _SplashLoadingDots(controller: _dotsController),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashLoadingDots extends StatelessWidget {
  const _SplashLoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (controller.value - i * 0.2).clamp(0.0, 1.0);
            final opacity = math.sin(phase * math.pi).clamp(0.15, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
