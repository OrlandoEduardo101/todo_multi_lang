import 'dart:async';

import 'package:vaden/vaden.dart';

@Controller('/')
class HealthController {
  const HealthController();

  @Get('/health')
  FutureOr<Response> health(Request request) =>
      Response.ok('{"status": "ok", "service": "todo-api"}', headers: {'Content-Type': 'application/json'});
}
