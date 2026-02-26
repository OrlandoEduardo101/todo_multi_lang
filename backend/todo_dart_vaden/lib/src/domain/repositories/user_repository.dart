import '../../dto/user_dto.dart';
import '../entities/user.dart';

/// Interface for User repository
abstract interface class UserRepository {
  Future<UserProfile?> findById(String id);
  Future<UserProfile?> findByEmail(String email);
  Future<User?> findEntityById(String id);
  Future<User?> findEntityByEmail(String email);
  Future<List<UserProfile>> findAll({int page = 1, int limit = 10});
  Future<int> getTotalCount();
  Future<UserProfile> create(CreateUserRequest request);
  Future<UserProfile?> update(String id, UpdateUserRequest request);
  Future<bool> delete(String id);
}
