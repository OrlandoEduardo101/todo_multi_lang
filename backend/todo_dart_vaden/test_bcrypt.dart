import 'package:vaden_security/vaden_security.dart';

void main() {
  final encoder = BCryptPasswordEncoder();

  const password = '123456';
  final hash = encoder.encode(password);

  print('Password: $password');
  print('Generated hash: $hash');
  print('Hash length: ${hash.length}');

  final matches = encoder.matches(password, hash);
  print('Matches: $matches');

  // Test with the hash from DB
  const dbHash = r'$2a$10$PgXMiWs072ulNKk1wUZ9f.J2L9KbH.HXnZaJZ1C5W5AHyJzQXYfPe';
  final matchesDb = encoder.matches(password, dbHash);
  print('\nTesting with DB hash:');
  print('DB Hash: $dbHash');
  print('Matches with password "$password": $matchesDb');
}
