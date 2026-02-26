/// User entity representing a user account in the system
class User {
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Check if user is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  /// Check if user has admin role
  bool get isAdmin => roles.contains('admin');

  /// Get full name
  String get fullName => '$firstName $lastName';

  @override
  String toString() => 'User(id: $id, email: $email, fullName: $fullName, roles: $roles)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id && email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
