import 'package:todo_flutter/src/shared/errors/app_exception.dart';

/// Base exception for all HTTP-related errors.
///
/// Carries a human-readable [message] and an optional [statusCode] returned
/// by the server.
class HttpException implements AppException {
  /// Describes what went wrong.
  @override
  final String message;

  /// The HTTP status code associated with the error, if available.
  @override
  final int? statusCode;

  /// Creates an [HttpException] with the given [message] and optional [statusCode].
  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $message (status code: $statusCode)';
}

/// Thrown when a network-level failure occurs (e.g. no internet connection).
class NetworkException extends HttpException {
  /// Creates a [NetworkException] with the given [message].
  NetworkException(super.message);
}

/// Thrown when the server returns a 5xx response.
class ServerException extends HttpException {
  /// Creates a [ServerException] with the given [message] and optional [statusCode].
  ServerException(super.message, {super.statusCode});
}

/// Thrown when the server returns a 4xx response (excluding 401).
class ClientException extends HttpException {
  /// Creates a [ClientException] with the given [message] and optional [statusCode].
  ClientException(super.message, {super.statusCode});
}

/// Thrown when the server returns a 401 Unauthorized response.
class UnauthorizedException extends HttpException {
  /// Creates an [UnauthorizedException] with the given [message] and optional [statusCode].
  UnauthorizedException(super.message, {super.statusCode});
}
