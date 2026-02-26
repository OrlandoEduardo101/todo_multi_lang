import '../../dto/todo_dto.dart';

/// Interface for Todo repository
abstract interface class TodoRepository {
  Future<TodoProfile?> findById(String id);
  Future<List<TodoProfile>> findByUserId(
    String userId, {
    int page = 1,
    int limit = 10,
    String? search,
    bool? completed,
    String sortBy = 'created_at',
    String order = 'desc',
  });
  Future<int> getTotalCountByUserId(String userId, {String? search, bool? completed});
  Future<TodoProfile> create(String userId, CreateTodoRequest request);
  Future<TodoProfile?> update(String id, UpdateTodoRequest request);
  Future<bool> delete(String id);
}
