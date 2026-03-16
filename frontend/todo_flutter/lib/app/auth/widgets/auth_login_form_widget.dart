import 'package:flutter/material.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

/// Reusable login form used by authentication pages.
class AuthLoginFormWidget extends StatelessWidget {
  /// Creates a login form bound to [authStore] and [formKey].
  const AuthLoginFormWidget({
    super.key,
    required this.authStore,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.isOnGradient,
    this.onRegisterTap,
  });

  /// Store with login command state.
  final AuthStore authStore;

  /// Form key used to validate user input.
  final GlobalKey<FormState> formKey;

  /// Controller for e-mail input.
  final TextEditingController emailController;

  /// Controller for password input.
  final TextEditingController passwordController;

  /// Callback executed when submit button is pressed.
  final VoidCallback onSubmit;

  /// Defines field colors for gradient or surface backgrounds.
  final bool isOnGradient;

  /// Optional callback to navigate to the register screen.
  final VoidCallback? onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EmailField(controller: emailController, isOnGradient: isOnGradient),
          const SizedBox(height: 16),
          _PasswordField(controller: passwordController, isOnGradient: isOnGradient),
          const SizedBox(height: 28),
          _LoginButton(authStore: authStore, onSubmit: onSubmit, isOnGradient: isOnGradient),
          if (onRegisterTap != null) ...[
            const SizedBox(height: 20),
            _RegisterLink(onTap: onRegisterTap!, isOnGradient: isOnGradient),
          ],
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required ThemeData theme,
  required String label,
  required IconData icon,
  required Color fg,
  required bool isOnGradient,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: fg.withValues(alpha: 0.6)),
    prefixIcon: Icon(icon, color: fg.withValues(alpha: 0.55), size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: fg.withValues(alpha: 0.07),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: fg.withValues(alpha: 0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: isOnGradient ? fg : theme.colorScheme.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
    ),
    errorStyle: TextStyle(color: theme.colorScheme.errorContainer),
  );
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.isOnGradient});

  final TextEditingController controller;
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: fg),
      decoration: _fieldDecoration(
        theme: theme,
        label: 'E-mail',
        icon: Icons.email_outlined,
        fg: fg,
        isOnGradient: isOnGradient,
      ),
      validator: (v) => (v == null || !v.contains('@')) ? 'E-mail inválido' : null,
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller, required this.isOnGradient});

  final TextEditingController controller;
  final bool isOnGradient;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = widget.isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return TextFormField(
      controller: widget.controller,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      style: TextStyle(color: fg),
      decoration: _fieldDecoration(
        theme: theme,
        label: 'Senha',
        icon: Icons.lock_outline_rounded,
        fg: fg,
        isOnGradient: widget.isOnGradient,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: fg.withValues(alpha: 0.55),
            size: 20,
          ),
          onPressed: () => setState(() => obscure = !obscure),
        ),
      ),
      validator: (v) => (v == null || v.length < 4) ? 'Senha muito curta' : null,
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink({required this.onTap, required this.isOnGradient});

  final VoidCallback onTap;
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Não tem uma conta? ', style: theme.textTheme.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.65))),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'Criar conta',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.authStore, required this.onSubmit, required this.isOnGradient});

  final AuthStore authStore;
  final VoidCallback onSubmit;
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final fgColor = isOnGradient ? theme.colorScheme.primary : theme.colorScheme.onPrimary;
    return ListenableBuilder(
      listenable: authStore.authCommand,
      builder: (context, _) {
        final loading = authStore.authCommand.isExecuting;
        return SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: loading
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: fgColor))
                : Text(
                    'Entrar',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: fgColor,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
