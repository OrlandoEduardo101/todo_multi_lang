import 'package:vaden/vaden.dart';
import 'paginated_response.dart';

/// User profile DTO for GET responses
/// Excludes sensitive fields like passwords
@DTO()
class UserProfile {
  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    roles: List<String>.from(json['roles'] as List),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'roles': roles,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

@DTO()
class UserPaginatedResponse implements PaginatedResponse<UserProfile> {
  UserPaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory UserPaginatedResponse.fromJson(Map<String, dynamic> json) => UserPaginatedResponse(
    data: (json['data'] as List).map((item) => UserProfile.fromJson(item as Map<String, dynamic>)).toList(),
    page: json['page'] as int,
    limit: json['limit'] as int,
    total: json['total'] as int,
    hasMore: json['hasMore'] as bool,
  );
  @override
  final List<UserProfile> data;
  @override
  final int page;
  @override
  final int limit;
  @override
  final int total;
  @override
  final bool hasMore;

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'page': page,
    'limit': limit,
    'total': total,
    'hasMore': hasMore,
  };
}

/// Request DTO for creating new user
@DTO()
class CreateUserRequest {
  CreateUserRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.roles = const ['user'],
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) => CreateUserRequest(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    roles: json['roles'] != null ? List<String>.from(json['roles'] as List) : const ['user'],
  );
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final List<String> roles;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'roles': roles,
  };
}

/// Request DTO for updating user
@DTO()
class UpdateUserRequest {
  UpdateUserRequest({this.firstName, this.lastName, this.email, this.roles});

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => UpdateUserRequest(
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    email: json['email'] as String?,
    roles: json['roles'] != null ? List<String>.from(json['roles'] as List) : null,
  );
  final String? firstName;
  final String? lastName;
  final String? email;
  final List<String>? roles;

  Map<String, dynamic> toJson() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (email != null) 'email': email,
    if (roles != null) 'roles': roles,
  };
}
