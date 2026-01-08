import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:vaden/vaden.dart';

import 'database.dart';
import '../../src/database/daos/todo_dao.dart';
import '../../src/database/daos/user_dao.dart';


@Configuration()
class DriftConfiguration {
  @Bean()
  AppDatabase appDatabase(QueryExecutor queryExecutor) {
    final database = AppDatabase(queryExecutor);
    _initializeDatabase(database);
    return database;
  }

  @Bean()
  QueryExecutor queryExecutor(ApplicationSettings settings) => PgDatabase(
    settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
    endpoint: pg.Endpoint(
      host: settings['database']['host'] as String? ?? 'localhost',
      database: settings['database']['database'] as String? ?? 'todo_db',
      username: settings['database']['username'] as String? ?? 'postgres',
      password: settings['database']['password'] as String? ?? 'postgres',
      port: settings['database']['port'] as int? ?? 5432,
    ),
  );

  @Bean()
  UserDao userDao(AppDatabase db) => UserDao(db);

  @Bean()
  TodoDao todoDao(AppDatabase db) => TodoDao(db);

  void _initializeDatabase(AppDatabase database) {
    Future.microtask(() async {
      try {
        print('🔄 Inicializando banco de dados e verificando migrações...');
        await database.customSelect('SELECT 1').get();
        print('✅ Banco de dados inicializado com sucesso!');
      } catch (e) {
        print('❌ Erro ao inicializar banco: $e');
      }
    });
  }
}
