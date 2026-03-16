import 'package:todo_flutter/src/modules/auth/models/auth_model.dart';
import 'package:todo_flutter/src/modules/auth/models/user_model.dart';
import 'package:todo_flutter/src/modules/auth/repositories/auth_repository.dart';
import 'package:todo_flutter/src/shared/reactive_ui/rx_command.dart';

class AuthStore {
  final AuthRepository authRepository;

  final StreamRxCommand<AuthResponseModel> watchAuthCommand = StreamRxCommand<AuthResponseModel>();

  final RxCommand<AuthResponseModel?> authCommand = RxCommand<AuthResponseModel?>();

  final RxCommand<void> logoutCommand = RxCommand<void>();

  final RxCommand<AuthResponseModel?> registerCommand = RxCommand<AuthResponseModel?>();

  AuthStore(this.authRepository);

  UserModel get currentUser {
    final auth = registerCommand.valueOrNull ?? authCommand.valueOrNull ?? watchAuthCommand.value;
    final user = auth?.user;
    return user is LoggedUserModel ? user : const UserModel.guestUser();
  }

  Future<void> refreshSession() async {}

  Future<void> login(String email, String password) async {
    await authCommand.execute(() async {
      final result = await authRepository.login(email, password);
      return result.fold((error) => throw (error), (auth) => auth);
    });
  }

  Future<void> logout() async {
    await logoutCommand.execute(() async {
      final result = await authRepository.logout();
      return result.fold((error) => throw (error), (_) => null);
    });
  }

  Future<void> register(String name, String email, String password) async {
    await registerCommand.execute(() async {
      final result = await authRepository.register(name, email, password);
      return result.fold((error) => throw (error), (auth) => auth);
    });
  }

  void watchAuth() {
    watchAuthCommand.listen(() => authRepository.watchCurrentUser());
  }
}
