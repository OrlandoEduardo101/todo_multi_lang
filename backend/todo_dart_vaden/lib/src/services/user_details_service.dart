import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';
import '../domain/repositories/user_repository.dart';
import '../dto/user_dto.dart';

/// UserDetailsService implementation to integrate VadenSecurity with our UserRepository.
@Service()
class UserDetailsServiceImpl implements UserDetailsService {
  UserDetailsServiceImpl(this.userRepository);
  final UserRepository userRepository;

  @override
  Future<UserDetails?> loadUserByUsername(String username) async {
    print('🔍 UserDetailsService: Buscando usuário: $username');
    var user = await userRepository.findEntityByEmail(username);
    user ??= await userRepository.findEntityById(username);
    if (user == null) {
      print('❌ UserDetailsService: Usuário não encontrado');
      return null;
    }

    print('✅ UserDetailsService: Usuário encontrado - ${user.email}');
    print('🔐 Password hash (primeiros 30 chars): ${user.password.substring(0, 30)}...');
    print('👤 Roles: ${user.roles}');

    final userDetails = CustomUserDetails(
      id: user.id,
      username: user.email,
      password: user.password,
      roles: user.roles,
      firstName: user.firstName,
      lastName: user.lastName,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
    print('📦 UserDetails criado - username: ${userDetails.username}, roles: ${userDetails.roles}');
    return userDetails;
  }
}

/// Custom user details DTO used by VadenSecurity.
@DTO()
class CustomUserDetails extends UserDetails {
  CustomUserDetails({
    required this.id,
    required super.username,
    required super.password,
    required super.roles,
    this.firstName = '',
    this.lastName = '',
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Convert CustomUserDetails to UserProfile DTO for API responses
  UserProfile toUserProfile() => UserProfile(
    id: id,
    firstName: firstName,
    lastName: lastName,
    email: username,
    roles: roles,
    createdAt: createdAt ?? DateTime.now(),
    updatedAt: updatedAt ?? DateTime.now(),
  );
}
