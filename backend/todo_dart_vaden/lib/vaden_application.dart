// GENERATED CODE - DO NOT MODIFY BY HAND
// Aggregated Vaden application file
// ignore_for_file: prefer_function_declarations_over_variables, implementation_imports
import 'config/app_configuration.dart';
import 'config/database/drift_configuration.dart';
import 'config/health_controller.dart';
import 'config/middleware/cors_configuration.dart';
import 'config/openapi/openapi_configuration.dart';
import 'config/openapi/openapi_controller.dart';
import 'config/security/security_configuration.dart';
import 'package:vaden_security/src/vaden_security_base.dart';
import 'package:vaden_security/src/models/user_details.dart';
import 'package:vaden_security/src/models/tokenization.dart';
import 'package:vaden_security/src/models/vaden_security_error.dart';
import 'package:vaden_security/src/auth_controller.dart';
import 'src/controllers/auth_controller.dart';
import 'src/controllers/todo_controller.dart';
import 'src/controllers/user_controller.dart';
import 'src/data/repositories/todo_repository_impl.dart';
import 'src/data/repositories/user_repository_impl.dart';
import 'src/dto/auth_dto.dart';
import 'src/dto/common_dto.dart';
import 'src/dto/todo_dto.dart';
import 'src/dto/user_dto.dart';
import 'src/services/auth_service.dart';
import 'src/services/user_details_service.dart';

import 'dart:convert';
import 'dart:io';
import 'package:vaden/vaden.dart';

class VadenApp implements DartVadenApplication {
  VadenApp();
  final _router = Router();
  final _injector = AutoInjector();

  @override
  AutoInjector get injector => _injector;

  @override
  Router get router => _router;

  @override
  Future<HttpServer> run(List<String> args) async {
    _injector.tryGet<CommandLineRunner>()?.run(args);
    _injector.tryGet<ApplicationRunner>()?.run(this);
    final pipeline = _injector.get<Pipeline>();
    final handler = pipeline.addHandler((request) async {
      try {
        final response = await _router(request);
        return response;
      } catch (e, stack) {
        print(e);
        print(stack);
        return _handleException(e);
      }
    });

    final settings = _injector.get<ApplicationSettings>();
    final port = settings['server']['port'] ?? 8080;
    final host = settings['server']['host'] ?? '0.0.0.0';

    final server = await serve(handler, host, port);

    return server;
  }

  @override
  Future<void> setup() async {
    final paths = <String, dynamic>{};
    final apis = <Api>[];
    final asyncBeans = <Future<void> Function()>[];
    _injector.addLazySingleton<DSON>(_DSON.new);

    final configurationAppConfiguration = AppConfiguration();

    _injector.addLazySingleton(configurationAppConfiguration.settings);
    _injector.addLazySingleton(configurationAppConfiguration.globalMiddleware);

    final configurationDriftConfiguration = DriftConfiguration();

    _injector.addLazySingleton(configurationDriftConfiguration.appDatabase);
    _injector.addLazySingleton(configurationDriftConfiguration.queryExecutor);
    _injector.addLazySingleton(configurationDriftConfiguration.userDao);
    _injector.addLazySingleton(configurationDriftConfiguration.todoDao);

    final configurationCorsConfiguration = CorsConfiguration();

    _injector.addLazySingleton(configurationCorsConfiguration.corsMiddleware);

    final configurationOpenApiConfiguration = OpenApiConfiguration();

    _injector.addLazySingleton(configurationOpenApiConfiguration.openApi);
    _injector.addLazySingleton(configurationOpenApiConfiguration.swaggerUI);

    final configurationSecurityConfiguration = SecurityConfiguration();

    _injector.addLazySingleton(configurationSecurityConfiguration.passwordEncoder);
    _injector.addLazySingleton(configurationSecurityConfiguration.jwtService);
    _injector.addLazySingleton(configurationSecurityConfiguration.httpSecurity);

    _injector.addBind(
      Bind.withClassName(
        constructor: TodoRepositoryImpl.new,
        type: BindType.lazySingleton,
        className: 'TodoRepository',
      ),
    );

    _injector.addBind(
      Bind.withClassName(
        constructor: UserRepositoryImpl.new,
        type: BindType.lazySingleton,
        className: 'UserRepository',
      ),
    );

    _injector.addLazySingleton(AuthService.new);

    _injector.addBind(
      Bind.withClassName(
        constructor: UserDetailsServiceImpl.new,
        type: BindType.lazySingleton,
        className: 'UserDetailsService<UserDetails>',
      ),
    );

    _injector.add(HealthController.new);
    final routerHealthController = Router();
    const pipelineHealthControllerhealth = Pipeline();
    final handlerHealthControllerhealth = (Request request) async {
      final ctrl = _injector.get<HealthController>();
      final result = await ctrl.health(request);
      return result;
    };
    routerHealthController.get('/health', pipelineHealthControllerhealth.addHandler(handlerHealthControllerhealth));
    _router.mount('/', routerHealthController.call);

    _injector.add(OpenAPIController.new);
    final routerOpenAPIController = Router();
    const pipelineOpenAPIControllergetSwagger = Pipeline();
    final handlerOpenAPIControllergetSwagger = (Request request) async {
      final ctrl = _injector.get<OpenAPIController>();
      final result = await ctrl.getSwagger(request);
      return result;
    };
    routerOpenAPIController.get(
      '/swagger',
      pipelineOpenAPIControllergetSwagger.addHandler(handlerOpenAPIControllergetSwagger),
    );
    const pipelineOpenAPIControllergetOpenApiJSON = Pipeline();
    final handlerOpenAPIControllergetOpenApiJSON = (Request request) async {
      final ctrl = _injector.get<OpenAPIController>();
      final result = ctrl.getOpenApiJSON(request);
      return result;
    };
    routerOpenAPIController.get(
      '/openapi.json',
      pipelineOpenAPIControllergetOpenApiJSON.addHandler(handlerOpenAPIControllergetOpenApiJSON),
    );
    _router.mount('/docs', routerOpenAPIController.call);

    _injector.add(AuthController.new);
    apis.add(const Api(tag: 'Auth', description: 'Authentication and authorization endpoints'));
    final routerAuthController = Router();
    paths['/auth/me'] = <String, dynamic>{
      ...paths['/auth/me'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Auth'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/auth/me']['get']['security'] = [
      {'bearer': []},
    ];
    paths['/auth/me']['get']['summary'] = 'Get current user details';
    paths['/auth/me']['get']['description'] = '';
    paths['/auth/me']['get']['responses']['200'] = {
      'description': 'User details retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/auth/me']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/me']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserDetails',
    };

    paths['/auth/me']['get']['responses']['403'] = {'description': 'Forbidden', 'content': <String, dynamic>{}};

    paths['/auth/me']['get']['responses']['403']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/me']['get']['responses']['403']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/me']['get']['responses']['400'] = {'description': 'Bad request', 'content': <String, dynamic>{}};

    paths['/auth/me']['get']['responses']['400']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/me']['get']['responses']['400']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/me']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    paths['/auth/me']['get']['responses']['500']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/me']['get']['responses']['500']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/me']['get']['responses']['401'] = {'description': 'Unauthorized', 'content': <String, dynamic>{}};

    paths['/auth/me']['get']['responses']['401']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/me']['get']['responses']['401']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    const pipelineAuthControllerme = Pipeline();
    final handlerAuthControllerme = (Request request) async {
      final header = _parse<String?>(request.headers['Authorization']);
      final ctrl = _injector.get<AuthController>();
      final result = await ctrl.me(header);
      return Response.ok(jsonEncode(result), headers: {'Content-Type': 'application/json'});
    };
    routerAuthController.get('/me', pipelineAuthControllerme.addHandler(handlerAuthControllerme));

    // Alias to keep parity with other backends.
    final routerApiMeAliasController = Router();
    paths['/api/me'] = <String, dynamic>{
      ...paths['/api/me'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Auth'],
        'summary': 'Get current user details',
        'description': '',
        'responses': <String, dynamic>{
          '200': {'description': 'Current user retrieved', 'content': <String, dynamic>{}},
        },
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[
          {'bearer': []},
        ],
      },
    };
    routerApiMeAliasController.get('/me', pipelineAuthControllerme.addHandler(handlerAuthControllerme));
    _router.mount('/api', routerApiMeAliasController.call);

    paths['/auth/login'] = <String, dynamic>{
      ...paths['/auth/login'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Auth'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/auth/login']['get']['security'] = [
      {'basic': []},
    ];
    paths['/auth/login']['get']['summary'] = 'Login and get access and refresh tokens';
    paths['/auth/login']['get']['description'] = '';
    paths['/auth/login']['get']['responses']['200'] = {
      'description': 'Tokens retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/auth/login']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/Tokenization',
    };

    paths['/auth/login']['get']['responses']['403'] = {'description': 'Forbidden', 'content': <String, dynamic>{}};

    paths['/auth/login']['get']['responses']['403']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['get']['responses']['403']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/login']['get']['responses']['400'] = {'description': 'Bad request', 'content': <String, dynamic>{}};

    paths['/auth/login']['get']['responses']['400']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['get']['responses']['400']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/login']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    paths['/auth/login']['get']['responses']['500']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['get']['responses']['500']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/login']['get']['responses']['401'] = {'description': 'Unauthorized', 'content': <String, dynamic>{}};

    paths['/auth/login']['get']['responses']['401']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['get']['responses']['401']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    const pipelineAuthControllerlogin = Pipeline();
    final handlerAuthControllerlogin = (Request request) async {
      final basic = _parse<String?>(request.headers['Authorization']);
      final ctrl = _injector.get<AuthController>();
      final result = await ctrl.login(basic);
      final jsoResponse = _injector.get<DSON>().toJson<Tokenization>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerAuthController.get('/login', pipelineAuthControllerlogin.addHandler(handlerAuthControllerlogin));
    paths['/auth/refresh'] = <String, dynamic>{
      ...paths['/auth/refresh'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Auth'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/auth/refresh']['get']['security'] = [
      {'bearer-refresh': []},
    ];
    paths['/auth/refresh']['get']['summary'] = 'Refresh access token using refresh token';
    paths['/auth/refresh']['get']['description'] = '';
    paths['/auth/refresh']['get']['responses']['200'] = {
      'description': 'Tokens refreshed successfully',
      'content': <String, dynamic>{},
    };

    paths['/auth/refresh']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/refresh']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/Tokenization',
    };

    paths['/auth/refresh']['get']['responses']['403'] = {'description': 'Forbidden', 'content': <String, dynamic>{}};

    paths['/auth/refresh']['get']['responses']['403']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/refresh']['get']['responses']['403']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/refresh']['get']['responses']['400'] = {'description': 'Bad request', 'content': <String, dynamic>{}};

    paths['/auth/refresh']['get']['responses']['400']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/refresh']['get']['responses']['400']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/refresh']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    paths['/auth/refresh']['get']['responses']['500']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/refresh']['get']['responses']['500']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    paths['/auth/refresh']['get']['responses']['401'] = {'description': 'Unauthorized', 'content': <String, dynamic>{}};

    paths['/auth/refresh']['get']['responses']['401']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/refresh']['get']['responses']['401']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/VadenSecurityError',
    };

    const pipelineAuthControllerrefresh = Pipeline();
    final handlerAuthControllerrefresh = (Request request) async {
      final header = _parse<String?>(request.headers['Authorization']);
      final ctrl = _injector.get<AuthController>();
      final result = await ctrl.refresh(header);
      final jsoResponse = _injector.get<DSON>().toJson<Tokenization>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerAuthController.get('/refresh', pipelineAuthControllerrefresh.addHandler(handlerAuthControllerrefresh));
    _router.mount('/auth', routerAuthController.call);

    _injector.add(AppAuthController.new);
    apis.add(const Api(tag: 'Authentication', description: 'User authentication endpoints'));
    final routerAppAuthController = Router();
    paths['/auth/register'] = <String, dynamic>{
      ...paths['/auth/register'] ?? <String, dynamic>{},
      'post': {
        'tags': ['Authentication'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/auth/register']['post']['summary'] = 'Register new user';
    paths['/auth/register']['post']['description'] = 'Create a new user account with email and password';
    paths['/auth/register']['post']['responses']['201'] = {
      'description': 'User registered successfully',
      'content': <String, dynamic>{},
    };

    paths['/auth/register']['post']['responses']['201']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/register']['post']['responses']['201']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserProfile',
    };

    paths['/auth/register']['post']['responses']['400'] = {
      'description': 'Invalid request data',
      'content': <String, dynamic>{},
    };

    paths['/auth/register']['post']['responses']['409'] = {
      'description': 'User already exists',
      'content': <String, dynamic>{},
    };

    paths['/auth/register']['post']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineAppAuthControllerregister = Pipeline();
    paths['/auth/register']['post']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/RegisterRequest'},
        },
      },
      'required': true,
    };

    final handlerAppAuthControllerregister = (Request request) async {
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final data = _injector.get<DSON>().fromJson<RegisterRequest>(bodyJson) as dynamic;

      if (data == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (RegisterRequest)'}));
      }

      if (data is Validator<RegisterRequest>) {
        final validator = data.validate(ValidatorBuilder<RegisterRequest>());
        final resultValidator = validator.validate(data as RegisterRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<AppAuthController>();
      final result = await ctrl.register(data);
      final jsoResponse = _injector.get<DSON>().toJson<UserProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerAppAuthController.post(
      '/register',
      pipelineAppAuthControllerregister.addHandler(handlerAppAuthControllerregister),
    );
    paths['/auth/login'] = <String, dynamic>{
      ...paths['/auth/login'] ?? <String, dynamic>{},
      'post': {
        'tags': ['Authentication'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/auth/login']['post']['summary'] = 'User login';
    paths['/auth/login']['post']['description'] = 'Authenticate user and receive JWT access token';
    paths['/auth/login']['post']['responses']['200'] = {
      'description': 'Login successful',
      'content': <String, dynamic>{},
    };

    paths['/auth/login']['post']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/auth/login']['post']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/AuthResponse',
    };

    paths['/auth/login']['post']['responses']['400'] = {
      'description': 'Invalid request data',
      'content': <String, dynamic>{},
    };

    paths['/auth/login']['post']['responses']['401'] = {
      'description': 'Invalid credentials',
      'content': <String, dynamic>{},
    };

    paths['/auth/login']['post']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineAppAuthControllerlogin = Pipeline();
    paths['/auth/login']['post']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/LoginRequest'},
        },
      },
      'required': true,
    };

    final handlerAppAuthControllerlogin = (Request request) async {
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final loginData = _injector.get<DSON>().fromJson<LoginRequest>(bodyJson) as dynamic;

      if (loginData == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (LoginRequest)'}));
      }

      if (loginData is Validator<LoginRequest>) {
        final validator = loginData.validate(ValidatorBuilder<LoginRequest>());
        final resultValidator = validator.validate(loginData as LoginRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<AppAuthController>();
      final result = await ctrl.login(loginData);
      final jsoResponse = _injector.get<DSON>().toJson<AuthResponse>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerAppAuthController.post('/login', pipelineAppAuthControllerlogin.addHandler(handlerAppAuthControllerlogin));
    _router.mount('/auth', routerAppAuthController.call);

    _injector.add(TodoController.new);
    apis.add(const Api(tag: 'Todos', description: 'Todo management endpoints'));
    final routerTodoController = Router();
    paths['/api/todos/'] = <String, dynamic>{
      ...paths['/api/todos/'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Todos'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/todos/']['get']['summary'] = 'List todos';
    paths['/api/todos/']['get']['description'] =
        'Get paginated list of todos with optional filters (search, completed status, sorting)';
    paths['/api/todos/']['get']['responses']['200'] = {
      'description': 'Todos retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/todos/']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/TodoPaginatedResponse',
    };

    paths['/api/todos/']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineTodoControllerlistTodos = Pipeline();
    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'page',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'limit',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'search',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'completed',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'sortBy',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/']['get']['parameters']?.add({
      'name': 'order',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    final handlerTodoControllerlistTodos = (Request request) async {
      if (request.context['user'] == null) {
        return Response(400, body: jsonEncode({'error': 'Context is required (user)'}));
      }

      final currentUser = request.context['user'] as dynamic;
      final page = _parse<int?>(request.url.queryParameters['page']);
      final limit = _parse<int?>(request.url.queryParameters['limit']);
      final search = _parse<String?>(request.url.queryParameters['search']);
      final completed = _parse<bool?>(request.url.queryParameters['completed']);
      final sortBy = _parse<String?>(request.url.queryParameters['sortBy']);
      final order = _parse<String?>(request.url.queryParameters['order']);
      final ctrl = _injector.get<TodoController>();
      final result = await ctrl.listTodos(currentUser, page, limit, search, completed, sortBy, order);
      final jsoResponse = _injector.get<DSON>().toJson<TodoPaginatedResponse>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerTodoController.get('/', pipelineTodoControllerlistTodos.addHandler(handlerTodoControllerlistTodos));
    paths['/api/todos/{id}'] = <String, dynamic>{
      ...paths['/api/todos/{id}'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Todos'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/todos/{id}']['get']['summary'] = 'Get todo by ID';
    paths['/api/todos/{id}']['get']['description'] = 'Retrieve detailed information about a specific todo';
    paths['/api/todos/{id}']['get']['responses']['200'] = {
      'description': 'Todo retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/todos/{id}']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/TodoProfile',
    };

    paths['/api/todos/{id}']['get']['responses']['400'] = {
      'description': 'Invalid todo ID',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['get']['responses']['404'] = {
      'description': 'Todo not found',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineTodoControllergetTodoById = Pipeline();
    paths['/api/todos/{id}']['get']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    final handlerTodoControllergetTodoById = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final todoId = _parse<String>(request.params['id'])!;

      final ctrl = _injector.get<TodoController>();
      final result = await ctrl.getTodoById(todoId);
      final jsoResponse = _injector.get<DSON>().toJson<TodoProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerTodoController.get('/<id>', pipelineTodoControllergetTodoById.addHandler(handlerTodoControllergetTodoById));
    paths['/api/todos/'] = <String, dynamic>{
      ...paths['/api/todos/'] ?? <String, dynamic>{},
      'post': {
        'tags': ['Todos'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/todos/']['post']['summary'] = 'Create todo';
    paths['/api/todos/']['post']['description'] = 'Create a new todo item for the authenticated user';
    paths['/api/todos/']['post']['responses']['201'] = {
      'description': 'Todo created successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/']['post']['responses']['201']['content']['application/json'] = <String, dynamic>{};

    paths['/api/todos/']['post']['responses']['201']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/TodoProfile',
    };

    paths['/api/todos/']['post']['responses']['400'] = {
      'description': 'Invalid request data',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/']['post']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineTodoControllercreateTodo = Pipeline();
    paths['/api/todos/']['post']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/CreateTodoRequest'},
        },
      },
      'required': true,
    };

    final handlerTodoControllercreateTodo = (Request request) async {
      if (request.context['user'] == null) {
        return Response(400, body: jsonEncode({'error': 'Context is required (user)'}));
      }

      final currentUser = request.context['user'] as dynamic;
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final data = _injector.get<DSON>().fromJson<CreateTodoRequest>(bodyJson) as dynamic;

      if (data == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (CreateTodoRequest)'}));
      }

      if (data is Validator<CreateTodoRequest>) {
        final validator = data.validate(ValidatorBuilder<CreateTodoRequest>());
        final resultValidator = validator.validate(data as CreateTodoRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<TodoController>();
      final result = await ctrl.createTodo(currentUser, data);
      final jsoResponse = _injector.get<DSON>().toJson<TodoProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerTodoController.post('/', pipelineTodoControllercreateTodo.addHandler(handlerTodoControllercreateTodo));
    paths['/api/todos/{id}'] = <String, dynamic>{
      ...paths['/api/todos/{id}'] ?? <String, dynamic>{},
      'put': {
        'tags': ['Todos'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/todos/{id}']['put']['summary'] = 'Update todo';
    paths['/api/todos/{id}']['put']['description'] = 'Update todo information (title, description, completed status)';
    paths['/api/todos/{id}']['put']['responses']['200'] = {
      'description': 'Todo updated successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['put']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/todos/{id}']['put']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/TodoProfile',
    };

    paths['/api/todos/{id}']['put']['responses']['400'] = {
      'description': 'Invalid todo ID',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['put']['responses']['404'] = {
      'description': 'Todo not found',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['put']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineTodoControllerupdateTodo = Pipeline();
    paths['/api/todos/{id}']['put']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    paths['/api/todos/{id}']['put']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/UpdateTodoRequest'},
        },
      },
      'required': true,
    };

    final handlerTodoControllerupdateTodo = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final todoId = _parse<String>(request.params['id'])!;

      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final updateData = _injector.get<DSON>().fromJson<UpdateTodoRequest>(bodyJson) as dynamic;

      if (updateData == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (UpdateTodoRequest)'}));
      }

      if (updateData is Validator<UpdateTodoRequest>) {
        final validator = updateData.validate(ValidatorBuilder<UpdateTodoRequest>());
        final resultValidator = validator.validate(updateData as UpdateTodoRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<TodoController>();
      final result = await ctrl.updateTodo(todoId, updateData);
      final jsoResponse = _injector.get<DSON>().toJson<TodoProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerTodoController.put('/<id>', pipelineTodoControllerupdateTodo.addHandler(handlerTodoControllerupdateTodo));
    paths['/api/todos/{id}'] = <String, dynamic>{
      ...paths['/api/todos/{id}'] ?? <String, dynamic>{},
      'delete': {
        'tags': ['Todos'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/todos/{id}']['delete']['summary'] = 'Delete todo';
    paths['/api/todos/{id}']['delete']['description'] = 'Soft delete a todo item by ID';
    paths['/api/todos/{id}']['delete']['responses']['200'] = {
      'description': 'Todo deleted successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['delete']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/todos/{id}']['delete']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/StatusResponse',
    };

    paths['/api/todos/{id}']['delete']['responses']['400'] = {
      'description': 'Invalid todo ID',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['delete']['responses']['404'] = {
      'description': 'Todo not found',
      'content': <String, dynamic>{},
    };

    paths['/api/todos/{id}']['delete']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineTodoControllerdeleteTodo = Pipeline();
    paths['/api/todos/{id}']['delete']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    final handlerTodoControllerdeleteTodo = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final todoId = _parse<String>(request.params['id'])!;

      final ctrl = _injector.get<TodoController>();
      final result = await ctrl.deleteTodo(todoId);
      final jsoResponse = _injector.get<DSON>().toJson<StatusResponse>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerTodoController.delete('/<id>', pipelineTodoControllerdeleteTodo.addHandler(handlerTodoControllerdeleteTodo));
    _router.mount('/api/todos', routerTodoController.call);

    _injector.add(UserController.new);
    apis.add(const Api(tag: 'Users', description: 'User management endpoints'));
    final routerUserController = Router();
    paths['/api/users/'] = <String, dynamic>{
      ...paths['/api/users/'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Users'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/users/']['get']['summary'] = 'List users';
    paths['/api/users/']['get']['description'] = 'Get paginated list of all users';
    paths['/api/users/']['get']['responses']['200'] = {
      'description': 'Users retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/users/']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/users/']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserPaginatedResponse',
    };

    paths['/api/users/']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineUserControllerlistUsers = Pipeline();
    paths['/api/users/']['get']['parameters']?.add({
      'name': 'page',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    paths['/api/users/']['get']['parameters']?.add({
      'name': 'limit',
      'in': 'query',
      'required': false,
      'schema': {'type': 'string'},
    });

    final handlerUserControllerlistUsers = (Request request) async {
      final page = _parse<int?>(request.url.queryParameters['page']);
      final limit = _parse<int?>(request.url.queryParameters['limit']);
      final ctrl = _injector.get<UserController>();
      final result = await ctrl.listUsers(page, limit);
      final jsoResponse = _injector.get<DSON>().toJson<UserPaginatedResponse>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerUserController.get('/', pipelineUserControllerlistUsers.addHandler(handlerUserControllerlistUsers));
    paths['/api/users/{id}'] = <String, dynamic>{
      ...paths['/api/users/{id}'] ?? <String, dynamic>{},
      'get': {
        'tags': ['Users'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/users/{id}']['get']['summary'] = 'Get user by ID';
    paths['/api/users/{id}']['get']['description'] = 'Retrieve detailed information about a specific user';
    paths['/api/users/{id}']['get']['responses']['200'] = {
      'description': 'User retrieved successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['get']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/users/{id}']['get']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserProfile',
    };

    paths['/api/users/{id}']['get']['responses']['400'] = {
      'description': 'Invalid user ID',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['get']['responses']['404'] = {
      'description': 'User not found',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['get']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineUserControllergetUserById = Pipeline();
    paths['/api/users/{id}']['get']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    final handlerUserControllergetUserById = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final userId = _parse<String>(request.params['id'])!;

      final ctrl = _injector.get<UserController>();
      final result = await ctrl.getUserById(userId);
      final jsoResponse = _injector.get<DSON>().toJson<UserProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerUserController.get('/<id>', pipelineUserControllergetUserById.addHandler(handlerUserControllergetUserById));
    paths['/api/users/'] = <String, dynamic>{
      ...paths['/api/users/'] ?? <String, dynamic>{},
      'post': {
        'tags': ['Users'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/users/']['post']['summary'] = 'Create user';
    paths['/api/users/']['post']['description'] = 'Create a new user in the system';
    paths['/api/users/']['post']['responses']['201'] = {
      'description': 'User created successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/users/']['post']['responses']['201']['content']['application/json'] = <String, dynamic>{};

    paths['/api/users/']['post']['responses']['201']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserProfile',
    };

    paths['/api/users/']['post']['responses']['400'] = {
      'description': 'Invalid request data',
      'content': <String, dynamic>{},
    };

    paths['/api/users/']['post']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineUserControllercreateUser = Pipeline();
    paths['/api/users/']['post']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/CreateUserRequest'},
        },
      },
      'required': true,
    };

    final handlerUserControllercreateUser = (Request request) async {
      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final data = _injector.get<DSON>().fromJson<CreateUserRequest>(bodyJson) as dynamic;

      if (data == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (CreateUserRequest)'}));
      }

      if (data is Validator<CreateUserRequest>) {
        final validator = data.validate(ValidatorBuilder<CreateUserRequest>());
        final resultValidator = validator.validate(data as CreateUserRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<UserController>();
      final result = await ctrl.createUser(data);
      final jsoResponse = _injector.get<DSON>().toJson<UserProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerUserController.post('/', pipelineUserControllercreateUser.addHandler(handlerUserControllercreateUser));
    paths['/api/users/{id}'] = <String, dynamic>{
      ...paths['/api/users/{id}'] ?? <String, dynamic>{},
      'put': {
        'tags': ['Users'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/users/{id}']['put']['summary'] = 'Update user';
    paths['/api/users/{id}']['put']['description'] = 'Update user information by ID';
    paths['/api/users/{id}']['put']['responses']['200'] = {
      'description': 'User updated successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['put']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/users/{id}']['put']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/UserProfile',
    };

    paths['/api/users/{id}']['put']['responses']['400'] = {
      'description': 'Invalid user ID',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['put']['responses']['404'] = {
      'description': 'User not found',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['put']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineUserControllerupdateUser = Pipeline();
    paths['/api/users/{id}']['put']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    paths['/api/users/{id}']['put']['requestBody'] = {
      'content': {
        'application/json': {
          'schema': {r'$ref': '#/components/schemas/UpdateUserRequest'},
        },
      },
      'required': true,
    };

    final handlerUserControllerupdateUser = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final userId = _parse<String>(request.params['id'])!;

      final bodyString = await request.readAsString();
      final bodyJson = jsonDecode(bodyString) as Map<String, dynamic>;
      final updateData = _injector.get<DSON>().fromJson<UpdateUserRequest>(bodyJson) as dynamic;

      if (updateData == null) {
        return Response(400, body: jsonEncode({'error': 'Invalid body: (UpdateUserRequest)'}));
      }

      if (updateData is Validator<UpdateUserRequest>) {
        final validator = updateData.validate(ValidatorBuilder<UpdateUserRequest>());
        final resultValidator = validator.validate(updateData as UpdateUserRequest);
        if (!resultValidator.isValid) {
          throw ResponseException<List<Map<String, dynamic>>>(400, resultValidator.exceptionToJson());
        }
      }

      final ctrl = _injector.get<UserController>();
      final result = await ctrl.updateUser(userId, updateData);
      final jsoResponse = _injector.get<DSON>().toJson<UserProfile>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerUserController.put('/<id>', pipelineUserControllerupdateUser.addHandler(handlerUserControllerupdateUser));
    paths['/api/users/{id}'] = <String, dynamic>{
      ...paths['/api/users/{id}'] ?? <String, dynamic>{},
      'delete': {
        'tags': ['Users'],
        'summary': '',
        'description': '',
        'responses': <String, dynamic>{},
        'parameters': <Map<String, dynamic>>[],
        'security': <Map<String, dynamic>>[],
      },
    };

    paths['/api/users/{id}']['delete']['summary'] = 'Delete user';
    paths['/api/users/{id}']['delete']['description'] = 'Soft delete a user by ID';
    paths['/api/users/{id}']['delete']['responses']['200'] = {
      'description': 'User deleted successfully',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['delete']['responses']['200']['content']['application/json'] = <String, dynamic>{};

    paths['/api/users/{id}']['delete']['responses']['200']['content']['application/json']['schema'] = {
      r'$ref': '#/components/schemas/StatusResponse',
    };

    paths['/api/users/{id}']['delete']['responses']['400'] = {
      'description': 'Invalid user ID',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['delete']['responses']['404'] = {
      'description': 'User not found',
      'content': <String, dynamic>{},
    };

    paths['/api/users/{id}']['delete']['responses']['500'] = {
      'description': 'Internal server error',
      'content': <String, dynamic>{},
    };

    const pipelineUserControllerdeleteUser = Pipeline();
    paths['/api/users/{id}']['delete']['parameters']?.add({
      'name': 'id',
      'in': 'path',
      'required': true,
      'schema': {'type': 'string'},
    });

    final handlerUserControllerdeleteUser = (Request request) async {
      if (request.params['id'] == null) {
        return Response(400, body: jsonEncode({'error': 'Path Param is required (id)'}));
      }
      final userId = _parse<String>(request.params['id'])!;

      final ctrl = _injector.get<UserController>();
      final result = await ctrl.deleteUser(userId);
      final jsoResponse = _injector.get<DSON>().toJson<StatusResponse>(result);
      return Response.ok(jsonEncode(jsoResponse), headers: {'Content-Type': 'application/json'});
    };
    routerUserController.delete('/<id>', pipelineUserControllerdeleteUser.addHandler(handlerUserControllerdeleteUser));
    _router.mount('/api/users', routerUserController.call);

    _injector.addLazySingleton(OpenApiConfig.create(paths, apis).call);
    _injector.commit();

    for (final asyncBean in asyncBeans) {
      await asyncBean();
    }

    await VadenSecurity().register(this);
  }

  Future<Response> _handleException(dynamic e) async =>
      Response.internalServerError(body: jsonEncode({'error': 'Internal server error'}));

  PType? _parse<PType>(String? value) {
    if (value == null) {
      return null;
    }

    if (PType == int) {
      return int.parse(value) as PType;
    } else if (PType == double) {
      return double.parse(value) as PType;
    } else if (PType == bool) {
      return bool.parse(value) as PType;
    } else {
      return value as PType;
    }
  }
}

class _DSON extends DSON {
  @override
  (Map<Type, FromJsonFunction>, Map<Type, ToJsonFunction>, Map<Type, ToOpenApiNormalMap>) getMaps() {
    final fromJsonMap = <Type, FromJsonFunction>{};
    final toJsonMap = <Type, ToJsonFunction>{};
    final toOpenApiMap = <Type, ToOpenApiNormalMap>{};

    fromJsonMap[UserDetails] = (json) => Function.apply(UserDetails.new, [], {
      #username: json['username'],
      #password: json['password'],
      #roles: json['roles'].cast<String>(),
    });
    toJsonMap[UserDetails] = (object) {
      final obj = object as UserDetails;
      return {'username': obj.username, 'roles': obj.roles};
    };
    toOpenApiMap[UserDetails] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'username': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['username', 'roles'],
    };

    fromJsonMap[Tokenization] = (json) => Function.apply(Tokenization.new, [], {
      #accessToken: json['access_token'],
      #refreshToken: json['refresh_token'],
    });
    toJsonMap[Tokenization] = (object) {
      final obj = object as Tokenization;
      return {'access_token': obj.accessToken, 'refresh_token': obj.refreshToken};
    };
    toOpenApiMap[Tokenization] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'access_token': {'type': 'string'},
        'refresh_token': {'type': 'string'},
      },
      'required': ['access_token', 'refresh_token'],
    };

    fromJsonMap[VadenSecurityError] = (json) => Function.apply(VadenSecurityError.new, [json['error']], {});
    toJsonMap[VadenSecurityError] = (object) {
      final obj = object as VadenSecurityError;
      return {'error': obj.error};
    };
    toOpenApiMap[VadenSecurityError] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'error': {'type': 'string'},
      },
      'required': ['error'],
    };

    fromJsonMap[RegisterRequest] = (json) => Function.apply(RegisterRequest.new, [], {
      #firstName: json['firstName'],
      #lastName: json['lastName'],
      #email: json['email'],
      #password: json['password'],
    });
    toJsonMap[RegisterRequest] = (object) {
      final obj = object as RegisterRequest;
      return {'firstName': obj.firstName, 'lastName': obj.lastName, 'email': obj.email, 'password': obj.password};
    };
    toOpenApiMap[RegisterRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'email': {'type': 'string'},
        'password': {'type': 'string'},
      },
      'required': ['firstName', 'lastName', 'email', 'password'],
    };

    fromJsonMap[LoginRequest] = (json) =>
        Function.apply(LoginRequest.new, [], {#email: json['email'], #password: json['password']});
    toJsonMap[LoginRequest] = (object) {
      final obj = object as LoginRequest;
      return {'email': obj.email, 'password': obj.password};
    };
    toOpenApiMap[LoginRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'email': {'type': 'string'},
        'password': {'type': 'string'},
      },
      'required': ['email', 'password'],
    };

    fromJsonMap[AuthResponse] = (json) => Function.apply(AuthResponse.new, [], {
      #token: json['token'],
      #expiresIn: json['expiresIn'],
      #user: fromJson<UserAuthProfile>(json['user']),
      if (json.containsKey('tokenType')) #tokenType: json['tokenType'],
    });
    toJsonMap[AuthResponse] = (object) {
      final obj = object as AuthResponse;
      return {
        'token': obj.token,
        'tokenType': obj.tokenType,
        'expiresIn': obj.expiresIn,
        'user': toJson<UserAuthProfile>(obj.user),
      };
    };
    toOpenApiMap[AuthResponse] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'token': {'type': 'string'},
        'tokenType': {'type': 'string'},
        'expiresIn': {'type': 'integer'},
        'user': {r'$ref': '#/components/schemas/UserAuthProfile'},
      },
      'required': ['token', 'tokenType', 'expiresIn', 'user'],
    };

    fromJsonMap[UserAuthProfile] = (json) => Function.apply(UserAuthProfile.new, [], {
      #id: json['id'],
      #email: json['email'],
      #firstName: json['firstName'],
      #lastName: json['lastName'],
      #roles: json['roles'].cast<String>(),
    });
    toJsonMap[UserAuthProfile] = (object) {
      final obj = object as UserAuthProfile;
      return {
        'id': obj.id,
        'email': obj.email,
        'firstName': obj.firstName,
        'lastName': obj.lastName,
        'roles': obj.roles,
      };
    };
    toOpenApiMap[UserAuthProfile] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'id': {'type': 'string'},
        'email': {'type': 'string'},
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['id', 'email', 'firstName', 'lastName', 'roles'],
    };

    fromJsonMap[StatusResponse] = (json) => Function.apply(StatusResponse.new, [], {#message: json['message']});
    toJsonMap[StatusResponse] = (object) {
      final obj = object as StatusResponse;
      return {'message': obj.message};
    };
    toOpenApiMap[StatusResponse] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'message': {'type': 'string'},
      },
      'required': ['message'],
    };

    fromJsonMap[TodoProfile] = (json) => Function.apply(TodoProfile.new, [], {
      #id: json['id'],
      #userId: json['userId'],
      #title: json['title'],
      #completed: json['completed'],
      #createdAt: DateTime.parse(json['createdAt'] as String),
      #updatedAt: DateTime.parse(json['updatedAt'] as String),
      #description: json['description'],
    });
    toJsonMap[TodoProfile] = (object) {
      final obj = object as TodoProfile;
      return {
        'id': obj.id,
        'userId': obj.userId,
        'title': obj.title,
        'description': obj.description,
        'completed': obj.completed,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      };
    };
    toOpenApiMap[TodoProfile] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'id': {'type': 'string'},
        'userId': {'type': 'string'},
        'title': {'type': 'string'},
        'description': {'type': 'string'},
        'completed': {'type': 'boolean'},
        'createdAt': {'type': 'string', 'format': 'date-time'},
        'updatedAt': {'type': 'string', 'format': 'date-time'},
      },
      'required': ['id', 'userId', 'title', 'completed', 'createdAt', 'updatedAt'],
    };

    fromJsonMap[CreateTodoRequest] = (json) =>
        Function.apply(CreateTodoRequest.new, [], {#title: json['title'], #description: json['description']});
    toJsonMap[CreateTodoRequest] = (object) {
      final obj = object as CreateTodoRequest;
      return {'title': obj.title, 'description': obj.description};
    };
    toOpenApiMap[CreateTodoRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'title': {'type': 'string'},
        'description': {'type': 'string'},
      },
      'required': ['title'],
    };

    fromJsonMap[UpdateTodoRequest] = (json) => Function.apply(UpdateTodoRequest.new, [], {
      #title: json['title'],
      #description: json['description'],
      #completed: json['completed'],
    });
    toJsonMap[UpdateTodoRequest] = (object) {
      final obj = object as UpdateTodoRequest;
      return {'title': obj.title, 'description': obj.description, 'completed': obj.completed};
    };
    toOpenApiMap[UpdateTodoRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'title': {'type': 'string'},
        'description': {'type': 'string'},
        'completed': {'type': 'boolean'},
      },
      'required': [],
    };

    fromJsonMap[TodoPaginatedResponse] = (json) => Function.apply(TodoPaginatedResponse.new, [], {
      #data: fromJsonList<TodoProfile>(json['data']),
      #page: json['page'],
      #limit: json['limit'],
      #total: json['total'],
      #hasMore: json['hasMore'],
    });
    toJsonMap[TodoPaginatedResponse] = (object) {
      final obj = object as TodoPaginatedResponse;
      return {
        'data': toJsonList<TodoProfile>(obj.data),
        'page': obj.page,
        'limit': obj.limit,
        'total': obj.total,
        'hasMore': obj.hasMore,
      };
    };
    toOpenApiMap[TodoPaginatedResponse] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'data': {
          'type': 'array',
          'items': {r'$ref': '#/components/schemas/TodoProfile'},
        },
        'page': {'type': 'integer'},
        'limit': {'type': 'integer'},
        'total': {'type': 'integer'},
        'hasMore': {'type': 'boolean'},
      },
      'required': ['data', 'page', 'limit', 'total', 'hasMore'],
    };

    fromJsonMap[UserProfile] = (json) => Function.apply(UserProfile.new, [], {
      #id: json['id'],
      #firstName: json['firstName'],
      #lastName: json['lastName'],
      #email: json['email'],
      #roles: json['roles'].cast<String>(),
      #createdAt: DateTime.parse(json['createdAt'] as String),
      #updatedAt: DateTime.parse(json['updatedAt'] as String),
    });
    toJsonMap[UserProfile] = (object) {
      final obj = object as UserProfile;
      return {
        'id': obj.id,
        'firstName': obj.firstName,
        'lastName': obj.lastName,
        'email': obj.email,
        'roles': obj.roles,
        'createdAt': obj.createdAt.toIso8601String(),
        'updatedAt': obj.updatedAt.toIso8601String(),
      };
    };
    toOpenApiMap[UserProfile] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'id': {'type': 'string'},
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'email': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
        'createdAt': {'type': 'string', 'format': 'date-time'},
        'updatedAt': {'type': 'string', 'format': 'date-time'},
      },
      'required': ['id', 'firstName', 'lastName', 'email', 'roles', 'createdAt', 'updatedAt'],
    };

    fromJsonMap[UserPaginatedResponse] = (json) => Function.apply(UserPaginatedResponse.new, [], {
      #data: fromJsonList<UserProfile>(json['data']),
      #page: json['page'],
      #limit: json['limit'],
      #total: json['total'],
      #hasMore: json['hasMore'],
    });
    toJsonMap[UserPaginatedResponse] = (object) {
      final obj = object as UserPaginatedResponse;
      return {
        'data': toJsonList<UserProfile>(obj.data),
        'page': obj.page,
        'limit': obj.limit,
        'total': obj.total,
        'hasMore': obj.hasMore,
      };
    };
    toOpenApiMap[UserPaginatedResponse] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'data': {
          'type': 'array',
          'items': {r'$ref': '#/components/schemas/UserProfile'},
        },
        'page': {'type': 'integer'},
        'limit': {'type': 'integer'},
        'total': {'type': 'integer'},
        'hasMore': {'type': 'boolean'},
      },
      'required': ['data', 'page', 'limit', 'total', 'hasMore'],
    };

    fromJsonMap[CreateUserRequest] = (json) => Function.apply(CreateUserRequest.new, [], {
      #firstName: json['firstName'],
      #lastName: json['lastName'],
      #email: json['email'],
      #password: json['password'],
      if (json.containsKey('roles')) #roles: json['roles'].cast<String>(),
    });
    toJsonMap[CreateUserRequest] = (object) {
      final obj = object as CreateUserRequest;
      return {
        'firstName': obj.firstName,
        'lastName': obj.lastName,
        'email': obj.email,
        'password': obj.password,
        'roles': obj.roles,
      };
    };
    toOpenApiMap[CreateUserRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'email': {'type': 'string'},
        'password': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['firstName', 'lastName', 'email', 'password', 'roles'],
    };

    fromJsonMap[UpdateUserRequest] = (json) => Function.apply(UpdateUserRequest.new, [], {
      #firstName: json['firstName'],
      #lastName: json['lastName'],
      #email: json['email'],
      #roles: json['roles']?.cast<String>(),
    });
    toJsonMap[UpdateUserRequest] = (object) {
      final obj = object as UpdateUserRequest;
      return {'firstName': obj.firstName, 'lastName': obj.lastName, 'email': obj.email, 'roles': obj.roles};
    };
    toOpenApiMap[UpdateUserRequest] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'email': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': [],
    };

    fromJsonMap[CustomUserDetails] = (json) => Function.apply(CustomUserDetails.new, [], {
      #id: json['id'],
      #username: json['username'],
      #password: json['password'],
      #roles: json['roles'].cast<String>(),
      if (json.containsKey('firstName')) #firstName: json['firstName'],
      if (json.containsKey('lastName')) #lastName: json['lastName'],
      #createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      #updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    });
    toJsonMap[CustomUserDetails] = (object) {
      final obj = object as CustomUserDetails;
      return {
        'id': obj.id,
        'firstName': obj.firstName,
        'lastName': obj.lastName,
        'createdAt': obj.createdAt?.toIso8601String(),
        'updatedAt': obj.updatedAt?.toIso8601String(),
        'username': obj.username,
        'roles': obj.roles,
      };
    };
    toOpenApiMap[CustomUserDetails] = {
      'type': 'object',
      'properties': <String, dynamic>{
        'id': {'type': 'string'},
        'firstName': {'type': 'string'},
        'lastName': {'type': 'string'},
        'createdAt': {'type': 'string', 'format': 'date-time'},
        'updatedAt': {'type': 'string', 'format': 'date-time'},
        'username': {'type': 'string'},
        'roles': {
          'type': 'array',
          'items': {'type': 'string'},
        },
      },
      'required': ['id', 'firstName', 'lastName', 'username', 'roles'],
    };

    return (fromJsonMap, toJsonMap, toOpenApiMap);
  }
}
