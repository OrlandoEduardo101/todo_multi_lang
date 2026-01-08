import 'dart:io';

import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:vaden/vaden.dart';

import 'package:todo_dart_vaden/config/app_module.dart';
import 'package:todo_dart_vaden/config/database/drift_configuration.dart';
import 'package:todo_dart_vaden/config/middleware/auth_middleware.dart';
import 'package:todo_dart_vaden/config/security/security_configuration.dart';

Future<void> main(List<String> args) async {
  // Load environment variables
  final host = Platform.environment['TODO_HOST'] ?? 'localhost';
  final port = int.parse(Platform.environment['TODO_PORT'] ?? '8080');

  try {
    // Initialize beans from DriftConfiguration
    // Note: In production, use Vaden's DI container to inject ApplicationSettings automatically
    // For now, we'll create QueryExecutor directly with environment variables
    final driftConfig = DriftConfiguration();

    final queryExecutor = PgDatabase(
      settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      endpoint: pg.Endpoint(
        host: Platform.environment['DB_HOST'] ?? 'localhost',
        database: Platform.environment['DB_NAME'] ?? 'todo_db',
        username: Platform.environment['DB_USER'] ?? 'postgres',
        password: Platform.environment['DB_PASSWORD'] ?? 'postgres',
        port: int.parse(Platform.environment['DB_PORT'] ?? '5432'),
      ),
    );

    final appDatabase = driftConfig.appDatabase(queryExecutor);
    final userDao = driftConfig.userDao(appDatabase);
    final todoDao = driftConfig.todoDao(appDatabase);

    // Initialize security beans
    final securityConfig = SecurityConfiguration();
    final passwordEncoder = securityConfig.passwordEncoder();

    // Initialize DI module
    final appModule = AppModule(
      appDatabase: appDatabase,
      userDao: userDao,
      todoDao: todoDao,
      passwordEncoder: passwordEncoder,
    );

    // Initialize AuthService
    final authService = appModule.getAuthService();

    // Create router
    final router = Router();

    // Auth routes (public)
    final authController = appModule.getAuthController();
    router.post('/auth/register', authController.register);
    router.post('/auth/login', authController.login);

    // User routes (protected)
    final userController = appModule.getUserController();
    router.get('/api/users', userController.listUsers);
    router.post('/api/users', userController.createUser);
    router.get('/api/users/<id>', userController.getUserById);
    router.put('/api/users/<id>', userController.updateUser);
    router.delete('/api/users/<id>', userController.deleteUser);

    // Todo routes (protected)
    final todoController = appModule.getTodoController();
    router.get('/api/todos', todoController.listTodos);
    router.post('/api/todos', todoController.createTodo);
    router.get('/api/todos/<id>', todoController.getTodoById);
    router.put('/api/todos/<id>', todoController.updateTodo);
    router.delete('/api/todos/<id>', todoController.deleteTodo);

    // Health check
    router.get('/health', (_) => Response.ok('{"status": "ok"}', headers: {'content-type': 'application/json'}));

    // Swagger/OpenAPI documentation
    router.get(
      '/docs/swagger',
      (_) => Response.ok('{"message": "Swagger UI - Coming soon"}', headers: {'content-type': 'application/json'}),
    );
    router.get(
      '/docs/openapi.json',
      (_) => Response.ok('{"openapi": "3.0.0"}', headers: {'content-type': 'application/json'}),
    );

    // Add middlewares
    final authMiddleware = AuthMiddleware(authService: authService);

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware)
        .addMiddleware(authMiddleware.middleware)
        .addHandler(router.call);

    // Start server
    final server = await serve(handler, host, port);

    print('');
    print('╔════════════════════════════════════════════════════╗');
    print('║  🚀 TODO Backend em Vaden + Drift ORM!            ║');
    print('║  🌐 Host: http://$host:${server.port}');
    print('║  📝 Docs: http://$host:${server.port}/docs/swagger ║');
    print('║  🏥 Health: http://$host:${server.port}/health   ║');
    print('║  🔐 JWT enabled com VadenSecurity                 ║');
    print('║  🔑 BCrypt password hashing ativado               ║');
    print('║  🗄️  Drift ORM + PostgreSQL                        ║');
    print('╚════════════════════════════════════════════════════╝');
    print('');

    // Graceful shutdown
    ProcessSignal.sigint.watch().listen((_) async {
      print('\n\n🛑 Shutting down server...');
      await server.close();
      await appDatabase.close();
      exit(0);
    });
  } catch (e) {
    print('❌ Error starting server: $e');
    exit(1);
  }
}

/// CORS middleware
Middleware _corsMiddleware = (innerHandler) => (request) async {
  if (request.method == 'OPTIONS') {
    return Response.ok(
      '',
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
      },
    );
  }

  final response = await innerHandler(request);
  return response.change(
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
    },
  );
};

// dart run build_runner build --delete-conflicting-outputs
// dart run backend/todo_dart_vaden/bin/server.dart
