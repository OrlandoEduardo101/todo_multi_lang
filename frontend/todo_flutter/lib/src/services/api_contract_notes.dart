/// UUID migration notes for frontend contract parity:
///
/// - user.id: String (UUID)
/// - todo.id: String (UUID)
/// - todo.userId: String (UUID)
///
/// Backends expected:
/// - Java: http://localhost:8081
/// - Dart: http://localhost:8080
/// - Go:   http://localhost:3000
///
/// All should accept/read/write same UUID-based schema in Postgres.
class ApiContractNotes {
  static const String userIdType = 'String(UUID)';
  static const String todoIdType = 'String(UUID)';
}
