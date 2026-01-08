import 'dart:convert';

import 'package:vaden/vaden.dart' hide Server;
import 'package:vaden/vaden_openapi.dart';

@Configuration()
class OpenApiConfiguration {
  @Bean()
  OpenApi openApi(OpenApiConfig config, ApplicationSettings settings) => OpenApi(
    version: '3.0.0',
    info: const Info(
      title: 'TODO API - Vaden + Drift',
      version: '1.0.0',
      description: 'RESTful API for TODO management built with Vaden framework and Drift ORM on PostgreSQL',
    ),
    servers: [config.localServer],
    tags: config.tags,
    paths: config.paths,
    components: Components(schemas: config.schemas),
  );

  @Bean()
  SwaggerUI swaggerUI(OpenApi openApi) => SwaggerUI(
    jsonEncode(openApi.toJson()),
    title: 'TODO API Documentation',
    deepLink: true,
    persistAuthorization: true,
  );
}
