import 'package:auto_injector/auto_injector.dart';
import 'package:todo_flutter/src/modules/todo/repositories/todo_repository.dart';
import 'package:todo_flutter/src/modules/todo/stores/todo_store.dart';

void registerTodoBindings(AutoInjector injector) {
  injector.addSingleton<TodoRepository>(TodoRepositoryImpl.new);
  injector.addLazySingleton<TodoStore>(TodoStore.new);
}

late final AutoInjector todoModule;
