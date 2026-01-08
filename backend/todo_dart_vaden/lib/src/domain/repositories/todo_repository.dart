import 'package:postgres/postgres.dart';
import '../../dto/todo_dto.dart';
/// Interface for Todo repository
abstract interface class TodoRepository {
  Future<TodoProfile?> findById(int id);
  Future<List<TodoProfile>> findByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
    String? search,
    bool? completed,
    String sortBy = 'created_at',
    String order = 'desc',
  });
  Future<int> getTotalCountByUserId(int userId, {String? search, bool? completed});
  Future<TodoProfile> create(int userId, CreateTodoRequest request);
  Future<TodoProfile?> update(int id, UpdateTodoRequest request);
  Future<bool> delete(int id);
}
