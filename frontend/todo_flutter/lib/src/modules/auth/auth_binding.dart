import 'package:auto_injector/auto_injector.dart';
import 'package:todo_flutter/src/modules/auth/repositories/auth_repository.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

/// Registra as dependências do módulo de autenticação no [injector] fornecido.
///
/// Chamada internamente por [rootModule] durante sua configuração.
void registerAuthBindings(AutoInjector injector) {
  injector.addSingleton<AuthRepository>(AuthRepositoryImpl.new);
  injector.addLazySingleton<AuthStore>(AuthStore.new);
}

/// Accessor do módulo de autenticação.
///
/// Aponta para o [rootModule] após sua inicialização.
/// Usado pelas páginas para resolver dependências de auth.
late final AutoInjector authModule;
