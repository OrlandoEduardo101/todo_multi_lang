import 'package:flutter/material.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

/// Reusable registration form used by the register page.
class AuthRegisterFormWidget extends StatelessWidget {
  /// Creates a registration form bound to [authStore] and [formKey].
  const AuthRegisterFormWidget({
    super.key,
    required this.authStore,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onLoginTap,
    required this.isOnGradient,
  });

  /// Store with register command state.
  final AuthStore authStore;

  /// Form key used to validate user input.
  final GlobalKey<FormState> formKey;

  /// Controller for full name input.
  final TextEditingController nameController;

  /// Controller for e-mail input.
  final TextEditingController emailController;

  /// Controller for password input.
  final TextEditingController passwordController;

  /// Controller for password confirmation input.
  final TextEditingController confirmPasswordController;

  /// Callback executed when submit button is pressed.
  final VoidCallback onSubmit;

  /// Callback executed when the login link is tapped.
  final VoidCallback onLoginTap;

  /// Defines field colors for gradient or surface backgrounds.
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = isOnGradient
        ? theme.colorScheme.onPrimary.withValues(alpha: 0.65)
        : theme.colorScheme.onSurface.withValues(alpha: 0.55);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NameField(controller: nameController, isOnGradient: isOnGradient),
          const SizedBox(height: 16),
          _EmailField(controller: emailController, isOnGradient: isOnGradient),
          const SizedBox(height: 16),
          _PasswordField(
            controller: passwordController,
            confirmController: confirmPasswordController,
            isOnGradient: isOnGradient,
          ),
          const SizedBox(height: 16),
          _ConfirmPasswordField(
            controller: confirmPasswordController,
            passwordController: passwordController,
            isOnGradient: isOnGradient,
          ),
          const SizedBox(height: 28),
          _RegisterButton(authStore: authStore, onSubmit: onSubmit, isOnGradient: isOnGradient),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Já tem uma conta?', style: TextStyle(color: secondaryColor, fontSize: 14)),
              TextButton(
                onPressed: onLoginTap,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 6)),
                child: Text(
                  'Entrar',
                  style: TextStyle(
                    color: isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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

class _NameField extends StatelessWidget {
  const _NameField({required this.controller, required this.isOnGradient});

  final TextEditingController controller;
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: TextStyle(color: fg),
      decoration: _fieldDecoration(
        theme: theme,
        label: 'Nome completo',
        icon: Icons.person_outline_rounded,
        fg: fg,
        isOnGradient: isOnGradient,
      ),
      validator: (v) => (v == null || v.trim().length < 2) ? 'Nome muito curto' : null,
    );
  }
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
  const _PasswordField({required this.controller, required this.confirmController, required this.isOnGradient});

  final TextEditingController controller;
  final TextEditingController confirmController;
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
      textInputAction: TextInputAction.next,
      style: TextStyle(color: fg),
      onChanged: (_) => widget.confirmController.text.isNotEmpty ? Form.of(context).validate() : null,
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

class _ConfirmPasswordField extends StatefulWidget {
  const _ConfirmPasswordField({required this.controller, required this.passwordController, required this.isOnGradient});

  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool isOnGradient;

  @override
  State<_ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<_ConfirmPasswordField> {
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
        label: 'Confirmar senha',
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
      validator: (v) => v != widget.passwordController.text ? 'As senhas não coincidem' : null,
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.authStore, required this.onSubmit, required this.isOnGradient});

  final AuthStore authStore;
  final VoidCallback onSubmit;
  final bool isOnGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isOnGradient ? theme.colorScheme.onPrimary : theme.colorScheme.primary;
    final fgColor = isOnGradient ? theme.colorScheme.primary : theme.colorScheme.onPrimary;
    return ListenableBuilder(
      listenable: authStore.registerCommand,
      builder: (context, _) {
        final loading = authStore.registerCommand.isExecuting;
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
                    'Criar conta',
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
