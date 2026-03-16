import 'package:todo_flutter/src/modules/todo/models/todo_model.dart';
import 'package:todo_flutter/src/modules/todo/repositories/todo_repository.dart';
import 'package:todo_flutter/src/shared/reactive_ui/rx_command.dart';

class TodoStore {
  final TodoRepository todoRepository;

  final StreamRxCommand<List<TodoModel>> todoList = StreamRxCommand<List<TodoModel>>();

  final RxCommand<TodoModel> createTodoCommand = RxCommand<TodoModel>();
  final RxCommand<TodoModel> updateTodoCommand = RxCommand<TodoModel>();
  final RxCommand<void> deleteTodoCommand = RxCommand<void>();
  final RxCommand<void> syncTodosCommand = RxCommand<void>();

  TodoStore(this.todoRepository);

  Future<void> watchTodos() async {
    final stream = await todoRepository.watchTodos();
    todoList.listen(() => stream);
  }

  Future<void> createTodo(TodoModel todo) async {
    await createTodoCommand.execute(() async {
      final result = await todoRepository.createTodo(todo);
      return result.fold((error) => throw (error), (created) => created);
    });
  }

  Future<void> updateTodo(TodoModel todo) async {
    await updateTodoCommand.execute(() async {
      final result = await todoRepository.updateTodo(todo);
      return result.fold((error) => throw (error), (updated) => updated);
    });
  }

  Future<void> deleteTodo(int id) async {
    await deleteTodoCommand.execute(() async {
      final result = await todoRepository.deleteTodo(id);
      return result.fold((error) => throw (error), (_) => null);
    });
  }

  Future<void> syncTodos() async {
    await syncTodosCommand.execute(() async {
      final result = await todoRepository.syncTodos();
      return result.fold((error) => throw (error), (_) => null);
    });
  }

  void dispose() {
    todoList.cancel();
    todoList.dispose();
    createTodoCommand.dispose();
    updateTodoCommand.dispose();
    deleteTodoCommand.dispose();
    syncTodosCommand.dispose();
  }
}
