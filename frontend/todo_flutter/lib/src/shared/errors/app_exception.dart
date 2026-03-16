/// Base exception for all HTTP-related errors.
///
/// Carries a human-readable [message] and an optional [statusCode] returned
/// by the server.
class AppException implements Exception {
  /// Describes what went wrong.
  final String message;

  /// The HTTP status code associated with the error, if available.
  final int? statusCode;

  /// Creates an [AppException] with the given [message] and optional [statusCode].
  AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException: $message (status code: $statusCode)';
}

class DatabaseException extends AppException {
  DatabaseException(super.message, {super.statusCode});
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.statusCode});
}

class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.statusCode});
}

class MappingException extends AppException {
  MappingException(super.message, {super.statusCode});
}
