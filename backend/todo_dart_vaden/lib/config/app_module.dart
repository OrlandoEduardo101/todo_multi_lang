import 'package:vaden_security/vaden_security.dart';

import '../src/controllers/auth_controller.dart';
import '../src/controllers/todo_controller.dart';
import '../src/controllers/user_controller.dart';
import '../src/data/repositories/todo_repository_impl.dart';
import '../src/data/repositories/user_repository_impl.dart';
import '../src/database/daos/todo_dao.dart';
import '../src/database/daos/user_dao.dart';
import '../src/domain/repositories/todo_repository.dart';
import '../src/domain/repositories/user_repository.dart';
import '../src/services/auth_service.dart';
import 'database/database.dart';

/// Application Module - Dependency Injection configuration with Drift
class AppModule {
  AppModule({
    required this.appDatabase,
    required this.userDao,
    required this.todoDao,
    required this.passwordEncoder,
    required this.jwtService,
  });

  final AppDatabase appDatabase;
  final UserDao userDao;
  final TodoDao todoDao;
  final PasswordEncoder passwordEncoder;
  final JwtService jwtService;

  /// Get User Repository
  UserRepository getUserRepository() => UserRepositoryImpl(userDao, passwordEncoder);

  /// Get Todo Repository
  TodoRepository getTodoRepository() => TodoRepositoryImpl(todoDao);

  /// Get Password Encoder
  PasswordEncoder getPasswordEncoder() => passwordEncoder;

  /// Get Auth Service
  AuthService getAuthService() => AuthService(getUserRepository(), getPasswordEncoder());

  /// Get Auth Controller
  AppAuthController getAuthController() => AppAuthController(
    userRepository: getUserRepository(),
    passwordEncoder: getPasswordEncoder(),
    jwtService: jwtService,
  );

  /// Get User Controller
  UserController getUserController() => UserController(userRepository: getUserRepository());

  /// Get Todo Controller
  TodoController getTodoController() => TodoController(todoRepository: getTodoRepository());
}
