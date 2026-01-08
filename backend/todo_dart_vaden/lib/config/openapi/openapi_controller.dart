import 'dart:async';

import 'package:vaden/vaden.dart';
import 'package:vaden/vaden_openapi.dart' hide Response;

@Controller('/docs')
class OpenAPIController {
  const OpenAPIController(this.swaggerUI);
  final SwaggerUI swaggerUI;

  @Get('/swagger')
  FutureOr<Response> getSwagger(Request request) => swaggerUI.call(request);

  @Get('/openapi.json')
  Response getOpenApiJSON(Request request) =>
      Response.ok(swaggerUI.schemaText, headers: {'Content-Type': 'application/json'});
}
