import 'package:vaden/vaden.dart';

@Configuration()
class AppConfiguration {
  @Bean()
  ApplicationSettings settings() => ApplicationSettings.load('application.yaml');

  @Bean()
  Pipeline globalMiddleware(ApplicationSettings settings) {
    const defaultHeadersList = [
      'accept',
      'accept-encoding',
      'authorization',
      'content-type',
      'dnt',
      'origin',
      'user-agent',
      'Origin',
      'Content-Type',
      'Accept',
      'Cookie',
      'Authorization',
      // Flutter Web
      'access-control-allow-methods',
      'access-control-allow-origin',
      'access-control-allow-headers',
    ];

    final allowedOrigins =
        (settings['security']['corsAllowedOrigins'] as List?)?.map((e) => e.toString()).toList() ?? ['*'];

    return const Pipeline()
        .addMiddleware(cors(allowedOrigins: allowedOrigins, allowHeaders: defaultHeadersList))
        .addMiddleware(logRequests());
  }
}
