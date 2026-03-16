import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:todo_flutter/app/app_widget.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';
import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/modules/todo/stores/todo_store.dart';
import 'package:todo_flutter/src/modules/todo/todo_binding.dart';
import 'package:todo_flutter/src/shared/reactive_ui/rx_command.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthStore _authStore = authModule.get<AuthStore>();
  final TodoStore _todoStore = todoModule.get<TodoStore>();

  @override
  void initState() {
    super.initState();
    _authStore.logoutCommand.addListener(_onLogout);
    _todoStore.createTodoCommand.addListener(_onTodoMutation);
    _todoStore.updateTodoCommand.addListener(_onTodoMutation);
    _todoStore.deleteTodoCommand.addListener(_onTodoMutation);
    _todoStore.syncTodosCommand.addListener(_onTodoMutation);
    _todoStore.watchTodos();
  }

  void _onLogout() {
    if (!mounted) return;
    if (_authStore.logoutCommand.completed) {
      Routefly.navigate(routePaths.auth.login);
    }
  }

  void _onTodoMutation() {
    if (!mounted) return;

    _showCommandError(_todoStore.createTodoCommand);
    _showCommandError(_todoStore.updateTodoCommand);
    _showCommandError(_todoStore.deleteTodoCommand);
    _showCommandError(_todoStore.syncTodosCommand);
  }

  void _showCommandError(RxCommand<dynamic> command) {
    final error = command.error;
    if (error == null) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  void dispose() {
    _authStore.logoutCommand.removeListener(_onLogout);
    _todoStore.createTodoCommand.removeListener(_onTodoMutation);
    _todoStore.updateTodoCommand.removeListener(_onTodoMutation);
    _todoStore.deleteTodoCommand.removeListener(_onTodoMutation);
    _todoStore.syncTodosCommand.removeListener(_onTodoMutation);
    super.dispose();
  }

  String get _displayName {
    final user = _authStore.currentUser;
    return user is LoggedUserModel ? user.name : 'Usuário';
  }

  Future<void> _openCreateTodoDialog() async {
    final controller = TextEditingController();

    final title = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova tarefa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Digite o título'),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (title == null || title.isEmpty) return;

    final user = _authStore.currentUser;
    final userId = user is LoggedUserModel ? user.id : 'guest';

    final todo = TodoModel.pending(
      userId: userId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncState: TodoSyncState.pendingCreate,
    );

    await _todoStore.createTodo(todo);
  }

  Future<void> _toggleTodo(TodoModel todo, bool completed) async {
    final updated = todo.copyWith(
      completed: completed,
      updatedAt: DateTime.now(),
      syncState: todo.remoteId == null ? TodoSyncState.pendingCreate : TodoSyncState.pendingUpdate,
    );
    await _todoStore.updateTodo(updated);
  }

  Color _syncColor(ThemeData theme, TodoSyncState state) {
    return switch (state) {
      TodoSyncState.synced => theme.colorScheme.tertiary,
      TodoSyncState.syncError => theme.colorScheme.error,
      _ => theme.colorScheme.secondary,
    };
  }

  String _syncLabel(TodoSyncState state) {
    return switch (state) {
      TodoSyncState.pendingCreate => 'Pendente de criação',
      TodoSyncState.pendingUpdate => 'Pendente de atualização',
      TodoSyncState.pendingDelete => 'Pendente de exclusão',
      TodoSyncState.synced => 'Sincronizado',
      TodoSyncState.syncError => 'Erro na sincronização',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minhas Tarefas', style: theme.textTheme.titleMedium),
            Text('Olá, $_displayName', style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: _todoStore.syncTodosCommand,
            builder: (context, _) {
              final syncing = _todoStore.syncTodosCommand.isExecuting;
              return IconButton(
                icon: syncing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onSurface),
                      )
                    : const Icon(Icons.sync_rounded),
                tooltip: 'Sincronizar',
                onPressed: syncing ? null : _todoStore.syncTodos,
              );
            },
          ),
          ListenableBuilder(
            listenable: _authStore.logoutCommand,
            builder: (context, _) {
              if (_authStore.logoutCommand.isExecuting) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onSurface),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sair',
                onPressed: () => _authStore.logout(),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _todoStore.todoList,
        builder: (context, _) {
          if (_todoStore.todoList.isListening && !_todoStore.todoList.hasValue) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_todoStore.todoList.error != null && !_todoStore.todoList.hasValue) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _todoStore.todoList.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _todoStore.watchTodos, child: const Text('Tentar novamente')),
                  ],
                ),
              ),
            );
          }

          final todos = _todoStore.todoList.value ?? const <TodoModel>[];

          if (todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checklist_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('Nenhuma tarefa ainda', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text('Toque em + para adicionar uma tarefa', style: theme.textTheme.bodySmall),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _todoStore.syncTodos(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: todos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = todos[index];
                final syncColor = _syncColor(theme, todo.syncState);

                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.completed,
                      onChanged: (checked) => _toggleTodo(todo, checked ?? false),
                    ),
                    title: Text(
                      todo.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        decoration: todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(Icons.sync, size: 14, color: syncColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _syncLabel(todo.syncState),
                            style: theme.textTheme.bodySmall?.copyWith(color: syncColor),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () {
                        final localId = todo.localId;
                        if (localId != null) {
                          _todoStore.deleteTodo(localId);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: _openCreateTodoDialog, child: const Icon(Icons.add)),
    );
  }
}
