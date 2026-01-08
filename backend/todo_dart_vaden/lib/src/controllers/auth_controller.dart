import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

import '../domain/repositories/user_repository.dart';
import '../dto/auth_dto.dart';
import '../dto/user_dto.dart';

/// Auth Controller - handles user registration and login
@Api(tag: 'Authentication', description: 'User authentication endpoints')
@Controller('/auth')
class AuthController {
  AuthController({required this.userRepository, required this.passwordEncoder});
  final UserRepository userRepository;
  final PasswordEncoder passwordEncoder;

  /// POST /auth/register - Register new user
  @ApiOperation(summary: 'Register new user', description: 'Create a new user account with email and password')
  @ApiResponse(
    201,
    description: 'User registered successfully',
    content: ApiContent(type: 'application/json', schema: UserProfile),
  )
  @ApiResponse(400, description: 'Invalid request data')
  @ApiResponse(409, description: 'User already exists')
  @ApiResponse(500, description: 'Internal server error')
  @Post('/register')
  Future<UserProfile> register(@Body() RegisterRequest data) async {
    // Validate input
    if (data.firstName.isEmpty || data.lastName.isEmpty || data.email.isEmpty || data.password.isEmpty) {
      throw const ResponseException(400, 'All fields are required');
    }

    // Check if user already exists
    final existing = await userRepository.findByEmail(data.email);
    if (existing != null) {
      throw const ResponseException(409, 'User with this email already exists');
    }

    // Hash password using BCrypt (via VadenSecurity)
    final hashedPassword = passwordEncoder.encode(data.password);

    // Create user
    final createRequest = CreateUserRequest(
      firstName: data.firstName,
      lastName: data.lastName,
      email: data.email,
      password: hashedPassword,
    );

    try {
      return await userRepository.create(createRequest);
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
      // Find user by email
      final user = await userRepository.findByEmail(loginData.email);
      if (user == null) {
        throw const ResponseException(401, 'Invalid credentials');
      }

      // Verify password - this needs the password hash from database
      // TODO: Add method to get user with password for verification

      // TODO: Use JwtService from vaden_security to generate token
      final token = 'token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';

      return AuthResponse(
        token: token,
        expiresIn: 259200, // 72 hours
        user: UserAuthProfile(
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          roles: user.roles,
        ),
      );
    } catch (e) {
      if (e is ResponseException) rethrow;
      throw ResponseException(500, 'Failed to login: ${e.toString()}');
    }
  }
}
