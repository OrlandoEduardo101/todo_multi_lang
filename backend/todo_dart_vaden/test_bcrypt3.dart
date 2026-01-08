import 'package:vaden_security/vaden_security.dart';

void main() {
  final encoder = BCryptPasswordEncoder();

  const password = '123456';

  // Full hash from DB for user ID 4
  const dbHash = r'$2a$10$gWibCKHHVO/JsKpVWgKM6OaVRK3.52wHzypkIImMiW36mM8n2l4JC';

  print('Password: $password');
  print('DB Hash: $dbHash');
  print('DB Hash length: ${dbHash.length}');

  final matches = encoder.matches(password, dbHash);
  print('Matches: $matches');
}
