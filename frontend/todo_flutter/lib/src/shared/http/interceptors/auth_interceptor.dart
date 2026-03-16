import 'package:dio/dio.dart';
import 'package:todo_flutter/src/modules/auth/stores/auth_session_store.dart';

/// Dio interceptor that attaches the JWT bearer token to every outgoing
/// request and handles automatic session refresh on 401 responses.
///
/// - For [LoggedUserModel] users the `Authorization: Bearer <token>` header is
///   injected when a non-empty token is present.
/// - For [GuestUserModel] users the request is rejected immediately with an
///   `Unauthorized` error so that unauthenticated calls never reach the server.
class AuthInterceptor implements Interceptor {
  /// Global auth session state.
  final AuthSessionStore authSessionStore;

  /// Creates an [AuthInterceptor] that reads credentials from [authSessionStore].
  AuthInterceptor(this.authSessionStore);

  /// Adds the `Authorization` header for logged-in users, or rejects the
  /// request when the current user is a guest.
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Public auth endpoints should not receive Authorization headers.
    if (options.path.contains('/login') || options.path.contains('/register') || options.path.contains('/refresh')) {
      handler.next(options);
      return;
    }

    final authorizationHeader = authSessionStore.authorizationHeader;
    if (authorizationHeader == null) {
      options.headers.remove('Authorization');
      handler.next(options);
      return;
    }

    options.headers['Authorization'] = authorizationHeader;

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
      authSessionStore.clearSession();
    }

    handler.next(err);
  }
}
