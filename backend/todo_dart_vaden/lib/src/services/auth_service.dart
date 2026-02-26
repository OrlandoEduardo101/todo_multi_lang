import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';
import '../domain/repositories/user_repository.dart';
import '../dto/auth_dto.dart';
import '../dto/user_dto.dart';

/// Authentication service aligned with Vaden patterns (no JWT dependency here).
@Service()
class AuthService {
  AuthService(this._userRepository, this._passwordEncoder);
  final UserRepository _userRepository;
  final PasswordEncoder _passwordEncoder;

  /// Login user: validates credentials and returns placeholder tokens.
  Future<AuthResponse> login(LoginRequest credentials) async {
    final userEntity = await _userRepository.findEntityByEmail(credentials.email);
    if (userEntity == null) {
      throw AuthException('InvalidCredentials', 'Invalid email or password');
    }

    final isValidPassword = _passwordEncoder.matches(credentials.password, userEntity.password);

    if (!isValidPassword) {
      throw AuthException('InvalidCredentials', 'Invalid email or password');
    }

    final profile = _toAuthProfile(userEntity);

    return AuthResponse(token: 'placeholder_access_token_${profile.id}', expiresIn: 3600, user: profile);
  }

  /// Register a new user and return placeholder tokens.
  Future<AuthResponse> register(RegisterRequest request) async {
    final existing = await _userRepository.findByEmail(request.email);
    if (existing != null) {
      throw AuthException('EmailAlreadyInUse', 'Email is already registered');
    }

    final created = await _userRepository.create(
      CreateUserRequest(
        firstName: request.firstName,
        lastName: request.lastName,
        email: request.email,
        password: request.password,
      ),
    );

    return AuthResponse(
      token: 'placeholder_access_token_${created.id}',
      expiresIn: 3600,
      user: UserAuthProfile(
        id: created.id,
        email: created.email,
        firstName: created.firstName,
        lastName: created.lastName,
        roles: created.roles,
      ),
    );
  }

  UserAuthProfile _toAuthProfile(userEntity) => UserAuthProfile(
    id: userEntity.id,
    email: userEntity.email,
    firstName: userEntity.firstName,
    lastName: userEntity.lastName,
    roles: userEntity.roles,
  );

  /// Decode placeholder token format: placeholder_access_token_<userId>
  String? getUserIdFromToken(String token) {
    final parts = token.split('_');
    if (parts.length < 4) return null;
    return parts.last;
  }
}

/// Custom exception for auth errors following the reference pattern.
class AuthException implements Exception {
  AuthException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => 'AuthException: $code - $message';
}
