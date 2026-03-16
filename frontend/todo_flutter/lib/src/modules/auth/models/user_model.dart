/// UserModel represents the user information in the authentication system.
/// It can be either a logged-in user with details or a guest user with no information.
/// This model is used in the AuthResponseModel to provide user details along with the authentication token.
/// The UserModel is a sealed class with two implementations: LoggedUserModel for authenticated users and GuestUserModel for unauthenticated users.
/// Union types are used to ensure type safety and clear distinction between logged-in and guest users in the application.

sealed class UserModel {
  const UserModel();

  const factory UserModel.loggedUser({required String id, required String email, required String name}) =
      LoggedUserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => LoggedUserModel.fromJson(json);

  Map<String, dynamic> toJson();

  const factory UserModel.guestUser() = GuestUserModel;
}

class LoggedUserModel implements UserModel {
  const LoggedUserModel({required this.id, required this.email, required this.name});

  final String id;
  final String email;
  final String name;

  factory LoggedUserModel.fromJson(Map<String, dynamic> json) => LoggedUserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    name: (json['name'] ?? '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim()) as String,
  );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'name': name};
}

class GuestUserModel implements UserModel {
  const GuestUserModel();

  factory GuestUserModel.fromJson(Map<String, dynamic> json) => const GuestUserModel();

  Map<String, dynamic> toJson() => {};
}
