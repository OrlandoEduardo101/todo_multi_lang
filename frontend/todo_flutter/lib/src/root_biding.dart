import 'package:auto_injector/auto_injector.dart';
import 'package:todo_flutter/src/modules/auth/auth_binding.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';
import 'package:todo_flutter/src/shared/http/dio_http_client.dart';
import 'package:todo_flutter/src/shared/http/http_client.dart';

/// Módulo raiz — único [AutoInjector] da aplicação.
///
/// Todas as dependências de infraestrutura e de cada feature são registradas
/// aqui para que o [commit] as resolva em um único escopo compartilhado.
/// Módulos de feature (ex: [authModule]) são aliases que apontam para este
/// injector após a inicialização.
final rootModule = AutoInjector(
  tag: 'AppModule',
  on: (i) {
    // Infraestrutura compartilhada
    i.addSingleton<AppDatabase>(AppDatabase.new);
    i.addSingleton<HttpClient>(DioHttpClient.new);

    // Features
    registerAuthBindings(i);

    i.commit();

    // Expor aliases de módulo após o commit
    authModule = i;
  },
);
