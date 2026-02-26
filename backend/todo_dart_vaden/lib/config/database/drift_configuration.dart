import 'dart:io' show Platform;

import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:vaden/vaden.dart';

import '../../src/database/daos/todo_dao.dart';
import '../../src/database/daos/user_dao.dart';
import 'database.dart';

@Configuration()
class DriftConfiguration {
  @Bean()
  AppDatabase appDatabase(QueryExecutor queryExecutor) {
    final database = AppDatabase(queryExecutor);
    _initializeDatabase(database);
    return database;
  }

  @Bean()
  QueryExecutor queryExecutor(ApplicationSettings settings) {
    final postgresRaw = settings['postgres'];
    final postgres = postgresRaw is Map ? postgresRaw.cast<String, dynamic>() : <String, dynamic>{};
    final rawPort = postgres['port'];
    final resolvedPortStr = _resolveEnv(rawPort);
    final port = rawPort is int ? rawPort : int.tryParse(resolvedPortStr ?? '') ?? 5432;

    return PgDatabase(
      settings: const pg.ConnectionSettings(sslMode: pg.SslMode.disable),
      endpoint: pg.Endpoint(
        host: _resolveEnv(postgres['host']) ?? 'localhost',
        database: _resolveEnv(postgres['database']) ?? 'todo_db',
        username: _resolveEnv(postgres['username']) ?? 'postgres',
        password: _resolveEnv(postgres['password']) ?? 'postgres',
        port: port,
      ),
    );
  }

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

  String? _resolveEnv(dynamic raw) {
    if (raw == null) return null;
    final s = raw.toString();
    final m = RegExp(r'^\$\{([^:}]+)(?::([^}]*))?\}$').firstMatch(s);
    if (m != null) {
      final key = m.group(1)!;
      final def = m.group(2);
      return Platform.environment[key] ?? def ?? s;
    }
    return s;
  }
}
