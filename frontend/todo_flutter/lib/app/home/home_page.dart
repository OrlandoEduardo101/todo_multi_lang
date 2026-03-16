import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:todo_flutter/app/app_widget.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthStore _authStore = authModule.get<AuthStore>();

  @override
  void initState() {
    super.initState();
    _authStore.logoutCommand.addListener(_onLogout);
  }

  void _onLogout() {
    if (!mounted) return;
    if (_authStore.logoutCommand.completed) {
      Routefly.navigate(routePaths.auth.login);
    }
  }

  @override
  void dispose() {
    _authStore.logoutCommand.removeListener(_onLogout);
    super.dispose();
  }

  String get _displayName {
    final user = _authStore.currentUser;
    return user is LoggedUserModel ? user.name : 'Usuário';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minhas Tarefas',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text('Olá, $_displayName', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: _authStore.logoutCommand,
            builder: (context, _) {
              if (_authStore.logoutCommand.isExecuting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white54),
                tooltip: 'Sair',
                onPressed: () => _authStore.logout(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_rounded, size: 64, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 16),
            Text('Nenhuma tarefa ainda', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Toque em + para adicionar uma tarefa',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: abrir modal de criação de tarefa
        },
        backgroundColor: const Color(0xFF7B1FA2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
