import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

import '../domain/repositories/user_repository.dart';
import '../dto/auth_dto.dart';
import '../dto/user_dto.dart';

/// Auth Controller - handles user registration and login
@Api(tag: 'Authentication', description: 'User authentication endpoints')
@Controller('/auth')
class AppAuthController {
  AppAuthController({required this.userRepository, required this.passwordEncoder, required this.jwtService});
  final UserRepository userRepository;
  final PasswordEncoder passwordEncoder;
  final JwtService jwtService;

  /// POST /auth/register - Register new user
  @ApiOperation(summary: 'Register new user', description: 'Create a new user account with email and password')
  @ApiResponse(
    201,
    description: 'User registered successfully',
    content: ApiContent(type: 'application/json', schema: AuthResponse),
  )
  @ApiResponse(400, description: 'Invalid request data')
  @ApiResponse(409, description: 'User already exists')
  @ApiResponse(500, description: 'Internal server error')
  @Post('/register')
  Future<AuthResponse> register(@Body() RegisterRequest data) async {
    // Validate input
    final derivedFirstName = data.firstName.trim();
    final derivedLastName = data.lastName.trim();
    if (derivedFirstName.isEmpty || data.email.isEmpty || data.password.isEmpty) {
      throw const ResponseException(400, 'All fields are required');
    }

    // Check if user already exists
    final existing = await userRepository.findByEmail(data.email);
    if (existing != null) {
      throw const ResponseException(409, 'User with this email already exists');
    }

    // Hash password using BCrypt (via VadenSecurity)
    // final hashedPassword = passwordEncoder.encode(data.password);

    // Create user
    final createRequest = CreateUserRequest(
      firstName: derivedFirstName,
      lastName: derivedLastName,
      email: data.email,
      password: data.password,
    );

    try {
      final created = await userRepository.create(createRequest);
      final tokenization = jwtService.generateToken(
        UserDetails(username: created.id, password: data.password, roles: created.roles),
        claims: {'user_id': created.id, 'email': created.email},
      );

      return AuthResponse(
        token: tokenization.accessToken,
        expiresIn: 259200,
        user: UserAuthProfile(
          id: created.id,
          email: created.email,
          firstName: created.firstName,
          lastName: created.lastName,
          roles: created.roles,
        ),
      );
    } catch (e) {
      throw ResponseException(500, 'Failed to register user: ${e.toString()}');
    }
  }

  /// POST /auth/login - Login user and get JWT token
  @ApiOperation(summary: 'User login', description: 'Authenticate user and receive JWT access token')
  @ApiResponse(
    200,
    description: 'Login successful',
    content: ApiContent(type: 'application/json', schema: AuthResponse),
  )
  @ApiResponse(400, description: 'Invalid request data')
  @ApiResponse(401, description: 'Invalid credentials')
  @ApiResponse(500, description: 'Internal server error')
  @Post('/login')
  Future<AuthResponse> login(@Body() LoginRequest loginData) async {
    if (loginData.email.isEmpty || loginData.password.isEmpty) {
      throw const ResponseException(400, 'Email and password are required');
    }

    try {
      // Find user entity by email (includes password hash)
      print('🔍 POST Login: Buscando usuário ${loginData.email}');
      final userEntity = await userRepository.findEntityByEmail(loginData.email);
      if (userEntity == null) {
        print('❌ POST Login: Usuário não encontrado');
        throw const ResponseException(401, 'Invalid credentials');
      }

      print('✅ POST Login: Usuário encontrado');
      print('🔐 Senha recebida: ${loginData.password}');
      print('🔐 Hash no DB (30 chars): ${userEntity.password.substring(0, 30)}...');

      // Verify password using BCrypt
      print('🔑 Testando passwordEncoder.matches...');
      final passwordMatches = passwordEncoder.matches(loginData.password, userEntity.password);
      print('🔑 Resultado: $passwordMatches');

      if (!passwordMatches) {
        print('❌ POST Login: Senha não confere');
        throw const ResponseException(401, 'Invalid credentials');
      }

      final tokenization = jwtService.generateToken(
        UserDetails(username: userEntity.id, password: userEntity.password, roles: userEntity.roles),
        claims: {'user_id': userEntity.id, 'email': userEntity.email},
      );

      return AuthResponse(
        token: tokenization.accessToken,
        expiresIn: 259200, // 72 hours
        user: UserAuthProfile(
          id: userEntity.id,
          email: userEntity.email,
          firstName: userEntity.firstName,
          lastName: userEntity.lastName,
          roles: userEntity.roles,
        ),
      );
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to login: ${e.toString()}');
    }
  }
}
