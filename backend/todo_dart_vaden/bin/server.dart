import 'dart:io';

import 'package:todo_dart_vaden/vaden_application.dart';
import 'package:vaden/vaden.dart';

Future<void> main(List<String> args) async {
  try {
    print('🔄 Inicializando banco de dados e verificando migrações...');

    // Initialize generated Vaden application
    final vaden = VadenApp();

    // Setup and start the server
    await vaden.setup();
    final server = await vaden.run(args);

    final settings = vaden.injector.get<ApplicationSettings>();
    final host = (settings['server']['host'] as String?) ?? 'localhost';
    final port = server.port;
    print('');
    print('╔════════════════════════════════════════════════════╗');
    print('║  🚀 TODO Backend em Vaden + Drift ORM!            ║');
    print('║  🌐 Host: http://$host:$port');
    print('║  📝 Docs: http://$host:$port/docs/swagger ║');
    print('║  🏥 Health: http://$host:$port/health   ║');
    print('║  🔐 JWT enabled com VadenSecurity                 ║');
    print('║  🔑 BCrypt password hashing ativado               ║');
    print('║  🗄️  Drift ORM + PostgreSQL                        ║');
    print('╚════════════════════════════════════════════════════╝');
    print('');
  } catch (e, stackTrace) {
    print('❌ Erro ao inicializar servidor: $e');
    print(stackTrace);
    exit(1);
  }
}

// dart run bin/server.dart
// puro dart run build_runner build --delete-conflicting-outputs
// dart run backend/todo_dart_vaden/bin/server.dart
