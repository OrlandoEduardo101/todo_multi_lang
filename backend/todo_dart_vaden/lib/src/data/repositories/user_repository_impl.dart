import 'package:drift/drift.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:vaden/vaden.dart';
import 'package:vaden_security/vaden_security.dart';

import '../../../config/database/database.dart';
import '../../database/daos/user_dao.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../dto/user_dto.dart';

/// Implementation of User repository using Drift DAOs
@Repository()
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._userDao, this._passwordEncoder);
  final UserDao _userDao;
  final PasswordEncoder _passwordEncoder;

  @override
  Future<UserProfile?> findById(String id) async {
    try {
      final user = await _userDao.findById(id);
      return user != null ? _mapToUserProfile(user) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfile?> findByEmail(String email) async {
    try {
      final user = await _userDao.findByEmail(email);
      return user != null ? _mapToUserProfile(user) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> findEntityByEmail(String email) async {
    try {
      final user = await _userDao.findByEmail(email);
      return user != null ? _mapToUserEntity(user) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> findEntityById(String id) async {
    try {
      final user = await _userDao.findById(id);
      return user != null ? _mapToUserEntity(user) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<UserProfile>> findAll({int page = 1, int limit = 10}) async {
    try {
      final users = await _userDao.getPaginated(page, limit);
      return users.map(_mapToUserProfile).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getTotalCount() async {
    try {
      return await _userDao.countActive();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfile> create(CreateUserRequest request) async {
    try {
      final hashedPassword = _passwordEncoder.encode(request.password);
      final now = DateTime.now();

      final companion = UsersTableCompanion(
        name: Value(_buildDisplayName(request.firstName, request.lastName, request.email)),
        firstName: Value(request.firstName),
        lastName: Value(request.lastName),
        email: Value(request.email),
        password: Value(hashedPassword),
        roles: Value(request.roles),
        createdAt: Value(PgDateTime(now)),
        updatedAt: Value(PgDateTime(now)),
      );

      final id = await _userDao.createUser(companion);
      final user = await _userDao.findById(id);
      return _mapToUserProfile(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserProfile?> update(String id, UpdateUserRequest request) async {
    try {
      final updates = UsersTableCompanion(
        name: (request.firstName != null || request.lastName != null)
            ? Value(_buildDisplayName(request.firstName ?? '', request.lastName ?? '', request.email ?? ''))
            : const Value.absent(),
        firstName: request.firstName != null ? Value(request.firstName) : const Value.absent(),
        lastName: request.lastName != null ? Value(request.lastName) : const Value.absent(),
        email: request.email != null ? Value(request.email!) : const Value.absent(),
        roles: request.roles != null ? Value(request.roles!) : const Value.absent(),
        updatedAt: Value(PgDateTime(DateTime.now())),
      );

      final success = await _userDao.updateUser(id, updates);
      if (!success) {
        return null;
      }

      final user = await _userDao.findById(id);
      return user != null ? _mapToUserProfile(user) : null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      return await _userDao.softDelete(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Map Drift UsersTableData to UserProfile DTO
  UserProfile _mapToUserProfile(UsersTableData? user) => UserProfile(
    id: user?.id.toString() ?? '',
    firstName: user?.firstName ?? '',
    lastName: user?.lastName ?? '',
    email: user?.email ?? '',
    roles: user?.roles ?? [],
    createdAt: user?.createdAt.toDateTime() ?? DateTime.now(),
    updatedAt: user?.updatedAt.toDateTime() ?? DateTime.now(),
  );

  User _mapToUserEntity(UsersTableData? user) => User(
    id: user?.id.toString() ?? '',
    firstName: user?.firstName ?? '',
    lastName: user?.lastName ?? '',
    email: user?.email ?? '',
    password: user?.password ?? '',
    roles: user?.roles ?? [],
    createdAt: user?.createdAt.toDateTime() ?? DateTime.now(),
    updatedAt: user?.updatedAt.toDateTime() ?? DateTime.now(),
    deletedAt: user?.deletedAt?.toDateTime(),
  );

  String _buildDisplayName(String firstName, String lastName, String email) {
    final merged = '${firstName.trim()} ${lastName.trim()}'.trim();
    if (merged.isNotEmpty) {
      return merged;
    }
    return email.isNotEmpty ? email : 'User';
  }
}
