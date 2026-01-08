import 'package:postgres/postgres.dart';
import '../../dto/user_dto.dart';
import '../entities/user.dart';

/// Interface for User repository
abstract interface class UserRepository {
  Future<UserProfile?> findById(int id);
  Future<UserProfile?> findByEmail(String email);
  Future<User?> findEntityByEmail(String email);
  Future<List<UserProfile>> findAll({int page = 1, int limit = 10});
  Future<int> getTotalCount();
  Future<UserProfile> create(CreateUserRequest request);
  Future<UserProfile?> update(int id, UpdateUserRequest request);
  Future<bool> delete(int id);
}
