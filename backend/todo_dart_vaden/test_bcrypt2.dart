import 'package:vaden_security/vaden_security.dart';

void main() {
  final encoder = BCryptPasswordEncoder();

  const password = '123456';

  // Full hash from DB
  const dbHash = r'$2a$10$PgXMiWs072ulNKk1wUZ9f.J3STl3sFknGoaXZQB/bDqFLfOhuGkQi';

  print('Password: $password');
  print('DB Hash: $dbHash');
  print('DB Hash length: ${dbHash.length}');

  final matches = encoder.matches(password, dbHash);
  print('Matches: $matches');
}
