/// Todo entity representing a task in the system
class Todo {
  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.deletedAt,
  });
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  /// Check if todo is deleted (soft delete)
  bool get isDeleted => deletedAt != null;

  @override
  String toString() => 'Todo(id: $id, userId: $userId, title: $title, completed: $completed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo && runtimeType == other.runtimeType && id == other.id && userId == other.userId;

  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
}
