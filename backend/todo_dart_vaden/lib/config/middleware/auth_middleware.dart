import 'package:shelf/shelf.dart';
import '../../src/services/auth_service.dart';

/// Auth Middleware for JWT token validation
class AuthMiddleware {
  AuthMiddleware({required this.authService});
  final AuthService authService;

  /// Middleware that validates JWT token in Authorization header
  Middleware get middleware =>
      (innerHandler) => (request) async {
        // Skip authentication for public routes
        if (_isPublicRoute(request)) {
          return innerHandler(request);
        }

        // Get authorization header
        final authHeader = request.headers['authorization'];
        if (authHeader == null || authHeader.isEmpty) {
          return Response(
            401,
            body: '{"error": "Missing authorization header"}',
            headers: {'content-type': 'application/json'},
          );
        }

        // Extract token from "Bearer <token>"
        final parts = authHeader.split(' ');
        if (parts.length != 2 || parts[0].toLowerCase() != 'bearer') {
          return Response(
            401,
            body: '{"error": "Invalid authorization header format"}',
            headers: {'content-type': 'application/json'},
          );
        }

        final token = parts[1];

        // Verify token
        final userId = authService.getUserIdFromToken(token);
        if (userId == null) {
          return Response(
            401,
            body: '{"error": "Invalid or expired token"}',
            headers: {'content-type': 'application/json'},
          );
        }

        // Add user ID to request context
        final updatedRequest = request.change(context: {'user_id': userId, 'token': token});

        return innerHandler(updatedRequest);
      };

  /// Check if route is public (doesn't require authentication)
  bool _isPublicRoute(Request request) {
    final path = request.url.path;
    const publicRoutes = ['/auth/register', '/auth/login', '/health', '/docs/swagger', '/docs/openapi.json'];

    return publicRoutes.any(path.startsWith);
  }
}

/// Extract user ID from request context
int? getUserIdFromContext(Request request) => request.context['user_id'] as int?;

/// Extract token from request context
String? getTokenFromContext(Request request) => request.context['token'] as String?;
