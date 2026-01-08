import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

/// Security configuration (Vaden style) with beans for encoder, JWT, and HTTP security.
@Configuration()
class SecurityConfiguration {
  static const int bcryptCost = 10;

  @Bean()
  PasswordEncoder passwordEncoder() => BCryptPasswordEncoder();

  @Bean()
  JwtService jwtService(ApplicationSettings settings) => JwtService.withSettings(settings);

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
