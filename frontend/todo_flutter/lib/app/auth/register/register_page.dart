import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:todo_flutter/app/app_widget.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';
import 'package:todo_flutter/app/auth/widgets/auth_register_form_widget.dart';
import 'package:todo_flutter/app/auth/widgets/auth_brand_logo_widget.dart';
import 'package:todo_flutter/app/auth/widgets/auth_brand_panel_widget.dart';
import 'package:todo_flutter/app/auth/widgets/auth_brand_title_widget.dart';
import 'package:todo_flutter/app/auth/widgets/glass_card_widget.dart';
import 'package:todo_flutter/src/shared/widgets/responsive_layout_widget.dart';

const _kTabletBreakpoint = 768.0;
const _kDesktopBreakpoint = 1200.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthStore _authStore = authModule.get<AuthStore>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authStore.registerCommand.addListener(_onRegisterChanged);
    if (kDebugMode) {
      _nameController.text = 'Test User';
      _emailController.text = 'test@test.com';
      _passwordController.text = '123456';
      _confirmPasswordController.text = '123456';
    }
  }

  void _onRegisterChanged() {
    if (!mounted) return;
    if (_authStore.registerCommand.completed) {
      final auth = _authStore.registerCommand.value;
      if (auth != null && auth.user is LoggedUserModel) {
        Routefly.navigate(routePaths.home);
      }
    }
    if (_authStore.registerCommand.error != null) {
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authStore.registerCommand.error!),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  void dispose() {
    _authStore.registerCommand.removeListener(_onRegisterChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _authStore.register(_nameController.text.trim(), _emailController.text.trim(), _passwordController.text);
    }
  }

  void _goToLogin() => Routefly.navigate(routePaths.auth.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayoutWidget(
        tabletBreakpoint: _kTabletBreakpoint,
        desktopBreakpoint: _kDesktopBreakpoint,
        mobileBuilder: (context) => _MobileLayout(
          authStore: _authStore,
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          onSubmit: _submit,
          onLoginTap: _goToLogin,
        ),
        tabletBuilder: (context) => _DesktopLayout(
          authStore: _authStore,
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          onSubmit: _submit,
          onLoginTap: _goToLogin,
        ),
        desktopBuilder: (context) => _DesktopLayout(
          authStore: _authStore,
          formKey: _formKey,
          nameController: _nameController,
          emailController: _emailController,
          passwordController: _passwordController,
          confirmPasswordController: _confirmPasswordController,
          onSubmit: _submit,
          onLoginTap: _goToLogin,
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.authStore,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final AuthStore authStore;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const AuthBrandLogoWidget(size: 88),
                const SizedBox(height: 20),
                AuthBrandTitleWidget(
                  titleColor: theme.colorScheme.onPrimary,
                  subtitleColor: theme.colorScheme.onPrimary.withValues(alpha: 0.65),
                ),
                const SizedBox(height: 40),
                GlassCardWidget(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.08),
                  borderColor: theme.colorScheme.onPrimary.withValues(alpha: 0.14),
                  child: AuthRegisterFormWidget(
                    authStore: authStore,
                    formKey: formKey,
                    nameController: nameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    onSubmit: onSubmit,
                    onLoginTap: onLoginTap,
                    isOnGradient: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.authStore,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onLoginTap,
  });

  final AuthStore authStore;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(flex: 5, child: AuthBrandPanelWidget()),
        Expanded(
          flex: 6,
          child: ColoredBox(
            color: theme.colorScheme.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Criar conta', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Preencha seus dados para começar',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 40),
                      AuthRegisterFormWidget(
                        authStore: authStore,
                        formKey: formKey,
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        onSubmit: onSubmit,
                        onLoginTap: onLoginTap,
                        isOnGradient: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
