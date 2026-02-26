import 'dart:io';

import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

/// Security configuration (Vaden style) with beans for encoder, JWT, and HTTP security.
@Configuration()
class SecurityConfiguration {
  static const int bcryptCost = 10;

  @Bean()
  PasswordEncoder passwordEncoder() {
    final encoder = BCryptPasswordEncoder();
    print('🔐 PasswordEncoder criado com cost=$bcryptCost');
    return encoder;
  }

  @Bean()
  JwtService jwtService(ApplicationSettings settings) {
    final secret =
        Platform.environment['JWT_SECRET'] ??
        (settings['jwt.secret'] as String?) ??
        (settings['jwt']?['secret'] as String?) ??
        'shared-dev-jwt-secret-32-characters-minimum-123456';

    final expRaw =
        settings['jwt.expirationHours'] ??
        settings['jwt']?['expirationHours'] ??
        Platform.environment['JWT_EXPIRATION_HOURS'];
    final exp = expRaw is int ? expRaw : int.tryParse(expRaw?.toString() ?? '') ?? 72;

    return JwtService(
      secret: secret,
      tokenValidity: Duration(hours: exp),
    );
  }

  @Bean()
  HttpSecurity httpSecurity() => HttpSecurity([
    RequestMatcher('/auth/**').permitAll(),
    RequestMatcher('/docs/**').permitAll(),
    RequestMatcher('/health').permitAll(),

    // // Public files/endpoints
    // RequestMatcher('/api/file/serve/**').permitAll(),
    // RequestMatcher('/api/file/image/**').permitAll(),
    // RequestMatcher('/api/file/download/**').permitAll(),
    // RequestMatcher('/api/file/direct/**').permitAll(),
    // RequestMatcher('/api/file/get/**').permitAll(),

    // Mercado Pago callback example
    RequestMatcher('/api/v1/payment/mercado-pago/callback').permitAll(),

    AnyRequest().authenticated(),
  ]);
}
