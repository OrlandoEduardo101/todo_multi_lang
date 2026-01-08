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
    final user = await userRepository.findEntityByEmail(username);
    if (user == null) return null;

    return CustomUserDetails(id: user.id, username: user.email, password: user.password, roles: user.roles);
  }
}

/// Custom user details DTO used by VadenSecurity.
@DTO()
class CustomUserDetails extends UserDetails {
  CustomUserDetails({required this.id, required super.username, required super.password, required super.roles});

  final int id;
}
