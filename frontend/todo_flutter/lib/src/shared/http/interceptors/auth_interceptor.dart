import 'package:dio/dio.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_store.dart';

/// Dio interceptor that attaches the JWT bearer token to every outgoing
/// request and handles automatic session refresh on 401 responses.
///
/// - For [LoggedUserModel] users the `Authorization: Bearer <token>` header is
///   injected when a non-empty token is present.
/// - For [GuestUserModel] users the request is rejected immediately with an
///   `Unauthorized` error so that unauthenticated calls never reach the server.
class AuthInterceptor implements Interceptor {
  /// The store that holds the current authentication state.
  final AuthStore authStore;

  /// Creates an [AuthInterceptor] that reads credentials from [authStore].
  AuthInterceptor(this.authStore);

  /// Adds the `Authorization` header for logged-in users, or rejects the
  /// request when the current user is a guest.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final UserModel user = authStore.currentUser;
    if (user is LoggedUserModel) {
      final token = authStore.authCommand.value?.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    if (user is GuestUserModel) {
      options.headers.remove('Authorization');
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Unauthorized: Guest users cannot make authenticated requests.',
          type: DioExceptionType.unknown,
        ),
      );
      return;
    }

    handler.next(options);
  }

  /// Passes successful responses through without modification.
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Triggers an automatic session refresh when the server returns 401.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Logout automático em caso de 401
      authStore.refreshSession();
    }

    handler.next(err);
  }
}
