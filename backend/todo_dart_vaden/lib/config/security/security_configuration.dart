import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';
import 'dart:io';

/// Security configuration (Vaden style) with beans for encoder, JWT, and HTTP security.
@Configuration()
class SecurityConfiguration {
  static const int bcryptCost = 10;

  @Bean()
  PasswordEncoder passwordEncoder() => BCryptPasswordEncoder();

  @Bean()
  JwtService jwtService(ApplicationSettings settings) {
    final secret = (settings['jwt.secret'] as String?) ??
        (settings['jwt']?['secret'] as String?) ??
        Platform.environment['JWT_SECRET'] ??
        'change-me-in-prod';

    final expRaw = settings['jwt.expirationHours'] ??
      settings['jwt']?['expirationHours'] ??
      Platform.environment['JWT_EXPIRATION_HOURS'];
    final exp = expRaw is int
      ? expRaw
      : int.tryParse(expRaw?.toString() ?? '') ?? 72;

    // Instantiate JwtService directly with secret and expiration
    return JwtService(secret: secret);
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
