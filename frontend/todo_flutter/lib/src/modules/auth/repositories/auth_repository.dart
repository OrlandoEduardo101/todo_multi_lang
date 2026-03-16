import 'package:todo_flutter/src/modules/auth/models/auth_model.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/shared/database/app_database.dart';
import 'package:todo_flutter/src/shared/database/tables/auth_table.dart';
import 'package:todo_flutter/src/shared/either/either.dart';
import 'package:todo_flutter/src/shared/errors/app_exception.dart';
import 'package:todo_flutter/src/shared/http/http_client.dart';
import 'package:todo_flutter/src/shared/http/http_exception.dart';

/// Contract for authentication operations.
///
/// All futures return an [Either] so callers can handle errors without
/// try/catch. Stream variants emit updates reactively (e.g. to rebuild UI
/// whenever the session changes).
abstract class AuthRepository {
  /// Authenticates the user with [email] and [password].
  ///
  /// Returns the logged-in [AuthResponseModel] on success, or an [AppException] on
  /// failure (wrong credentials, network error, etc.).
  Future<Either<AppException, AuthResponseModel>> login(String email, String password);

  /// Clears the current session from local storage.
  Future<Either<AppException, void>> logout();

  /// Validates the locally stored session and returns the associated user.
  ///
  /// Clears the session and returns an error if it is missing or expired.
  Future<Either<AppException, UserModel>> refreshSession();

  /// Returns the user from the active local session without a network call.
  ///
  /// Returns an error when no valid session exists.
  Future<Either<AppException, UserModel>> getCurrentUser();

  /// Registers a new account with the given [name], [email], and [password].
  ///
  /// Persists the session returned by the server on success.
  Future<Either<AppException, AuthResponseModel>> register(String name, String email, String password);

  /// Emits the current [UserModel] whenever the session changes.
  ///
  /// Falls back to [UserModel.guestUser] when no valid session is present.
  Stream<AuthResponseModel> watchCurrentUser();

  /// Like [watchCurrentUser] but wraps the value in [Either] so downstream
  /// listeners can distinguish between authenticated and unauthenticated states.
  Stream<Either<AppException, AuthResponseModel>> watchCurrentUserWithErrors();

  /// Emits `true` when the user is logged in, `false` otherwise.
  Stream<bool> watchIsLoggedIn();

  /// Performs [login] and exposes the result as a single-item stream.
  Stream<Either<AppException, AuthResponseModel>> watchLogin(String email, String password);

  /// Performs [register] and exposes the result as a single-item stream.
  Stream<Either<AppException, AuthResponseModel>> watchRegister(String name, String email, String password);
}

/// Default [AuthRepository] implementation.
///
/// Uses [httpClient] for remote calls and [database] to persist/read the
/// session locally via [AppDatabase].
class AuthRepositoryImpl implements AuthRepository {
  /// Local database used to persist and read session data.
  final AppDatabase database;

  /// HTTP client used to communicate with the authentication API.
  final HttpClient httpClient;

  /// Creates an [AuthRepositoryImpl] with the given [database] and [httpClient].
  AuthRepositoryImpl(this.database, this.httpClient);

  @override
  Future<Either<AppException, AuthResponseModel>> login(String email, String password) async {
    try {
      final response = await httpClient.post('/auth/login', body: {'email': email, 'password': password});

      final auth = AuthResponseModel.fromJson(response);
      await database.saveSession(auth);
      return Either.right(auth);
    } on HttpException catch (e) {
      return Left(AppException(e.toString(), statusCode: e.statusCode));
    } on DatabaseException catch (e) {
      return Left(AppException('Database error: ${e.message}'));
    } catch (e) {
      return Left(AppException('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> logout() async {
    try {
      await database.clearSession();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(AppException('Database error: ${e.message}'));
    }
  }

  @override
  Future<Either<AppException, UserModel>> refreshSession() async {
    try {
      final session = await database.watchSession().first;
      if (session == null || session.isExpired) {
        await database.clearSession();
        return Left(AppException('Session expired'));
      }
      return Right(session.toModel().user);
    } on DatabaseException catch (e) {
      return Left(AppException('Database error: ${e.message}'));
    }
  }

  @override
  Future<Either<AppException, UserModel>> getCurrentUser() async {
    try {
      final session = await database.watchSession().first;
      if (session == null || session.isExpired) {
        await database.clearSession();
        return Left(AppException('No active session'));
      }
      return Right(session.toModel().user);
    } on DatabaseException catch (e) {
      return Left(AppException('Database error: ${e.message}'));
    }
  }

  @override
  Future<Either<AppException, AuthResponseModel>> register(String name, String email, String password) async {
    try {
      final response = await httpClient.post(
        '/auth/register',
        body: {'name': name, 'email': email, 'password': password},
      );

      final auth = AuthResponseModel.fromJson(response);
      await database.saveSession(auth);
      return Either.right(auth);
    } on HttpException catch (e) {
      return Left(AppException(e.toString(), statusCode: e.statusCode));
    } on DatabaseException catch (e) {
      return Left(AppException('Database error: ${e.message}'));
    } catch (e) {
      return Left(AppException('Unexpected error: $e'));
    }
  }

  @override
  Stream<AuthResponseModel> watchCurrentUser() {
    return database.watchSession().map((session) {
      if (session == null || session.isExpired) {
        database.clearSession();
        return AuthResponseModel.guestUser();
      }
      return session.toModel();
    });
  }

  @override
  Stream<Either<AppException, AuthResponseModel>> watchCurrentUserWithErrors() {
    return database.watchSession().map((session) {
      if (session == null || session.isExpired) {
        database.clearSession();
        return Left(AppException('No active session'));
      }
      return Right(session.toModel());
    });
  }

  @override
  Stream<bool> watchIsLoggedIn() {
    return database.watchSession().map((session) {
      if (session == null || session.isExpired) {
        database.clearSession();
        return false;
      }
      return true;
    });
  }

  @override
  Stream<Either<AppException, AuthResponseModel>> watchLogin(String email, String password) {
    return Stream.fromFuture(login(email, password));
  }

  @override
  Stream<Either<AppException, AuthResponseModel>> watchRegister(String name, String email, String password) {
    return Stream.fromFuture(register(name, email, password));
  }
}
