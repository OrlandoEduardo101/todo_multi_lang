import 'user_model.dart';

class AuthResponseModel {
  AuthResponseModel({
    required this.token,
    this.tokenType = 'Bearer',
    required this.expiresIn,
    this.user = const UserModel.guestUser(),
  });

  final String token;
  final String tokenType;
  final int expiresIn;
  final UserModel user;

  factory AuthResponseModel.guestUser() =>
      AuthResponseModel(token: '', tokenType: 'Bearer', expiresIn: 0, user: const UserModel.guestUser());

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) => AuthResponseModel(
    token: json['token'] ?? '',
    tokenType: (json['tokenType'] ?? 'Bearer'),
    expiresIn: (json['expiresIn'] ?? 259200),
    user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : const UserModel.guestUser(),
  );
}
