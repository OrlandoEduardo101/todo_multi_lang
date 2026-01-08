import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

import 'app_configuration.dart';
import 'database/drift_configuration.dart';
import 'openapi/openapi_configuration.dart';
import 'middleware/cors_configuration.dart';

@VadenModule([VadenSecurity, AppConfiguration, DriftConfiguration, OpenApiConfiguration, CorsConfiguration])
class AppModule {}
