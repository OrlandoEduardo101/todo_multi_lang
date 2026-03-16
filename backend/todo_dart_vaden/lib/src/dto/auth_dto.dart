import 'package:vaden/vaden.dart';

/// Request DTO for user registration
@DTO()
class RegisterRequest {
  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.name,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as String?)?.trim();
    final firstName = (json['firstName'] as String?)?.trim();
    final lastName = (json['lastName'] as String?)?.trim();

    if (rawName != null && rawName.isNotEmpty && (firstName == null || firstName.isEmpty)) {
      final parts = rawName.split(RegExp(r'\s+'));
      final first = parts.first;
      final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      return RegisterRequest(
        firstName: first,
        lastName: last,
        email: json['email'] as String,
        password: json['password'] as String,
        name: rawName,
      );
    }

    return RegisterRequest(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: json['email'] as String,
      password: json['password'] as String,
      name: rawName,
    );
  }
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? name;

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    if (name != null) 'name': name,
    'email': email,
    'password': password,
  };
}

/// Request DTO for user login
@DTO()
class LoginRequest {
  LoginRequest({required this.email, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      LoginRequest(email: json['email'] as String, password: json['password'] as String);
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

/// Response DTO for authentication success
@DTO()
class AuthResponse {
  AuthResponse({required this.token, required this.expiresIn, required this.user, this.tokenType = 'Bearer'});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] as String,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
    expiresIn: json['expiresIn'] as int,
    user: UserAuthProfile.fromJson(json['user'] as Map<String, dynamic>),
  );
  final String token;
  final String tokenType;
  final int expiresIn;
  final UserAuthProfile user;

  Map<String, dynamic> toJson() => {
    'token': token,
    'tokenType': tokenType,
    'expiresIn': expiresIn,
    'user': user.toJson(),
  };
}

/// User profile DTO for auth responses
@DTO()
class UserAuthProfile {
  UserAuthProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
  });

  factory UserAuthProfile.fromJson(Map<String, dynamic> json) => UserAuthProfile(
    id: json['id'] as String,
    email: json['email'] as String,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    roles: List<String>.from(json['roles'] as List),
  );
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> roles;

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'roles': roles,
  };
}
