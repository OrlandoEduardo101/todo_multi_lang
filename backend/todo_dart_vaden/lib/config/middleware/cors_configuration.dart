import 'package:vaden/vaden.dart';

@Configuration()
class CorsConfiguration {
  @Bean()
  Middleware corsMiddleware(ApplicationSettings settings) {
    final allowedOrigins =
        (settings['security']['corsAllowedOrigins'] as List?)?.map((e) => e.toString()).toList() ?? ['*'];

    return (innerHandler) => (request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': allowedOrigins.contains('*') ? '*' : allowedOrigins.join(','),
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
            'Access-Control-Max-Age': '86400',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': allowedOrigins.contains('*') ? '*' : allowedOrigins.join(','),
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept, Authorization',
        },
      );
    };
  }
}
