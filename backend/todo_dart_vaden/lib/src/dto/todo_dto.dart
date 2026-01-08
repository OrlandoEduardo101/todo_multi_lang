import 'package:vaden/vaden.dart';
import 'paginated_response.dart';

/// Todo profile DTO for GET responses
@DTO()
class TodoProfile {
  TodoProfile({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory TodoProfile.fromJson(Map<String, dynamic> json) => TodoProfile(
    id: json['id'] as int,
    userId: json['userId'] as int,
    title: json['title'] as String,
    description: json['description'] as String?,
    completed: json['completed'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Request DTO for creating new todo
@DTO()
class CreateTodoRequest {
  CreateTodoRequest({required this.title, this.description});

  factory CreateTodoRequest.fromJson(Map<String, dynamic> json) =>
      CreateTodoRequest(title: json['title'] as String, description: json['description'] as String?);
  final String title;
  final String? description;

  Map<String, dynamic> toJson() => {'title': title, 'description': description};
}

/// Request DTO for updating todo
@DTO()
class UpdateTodoRequest {
  UpdateTodoRequest({this.title, this.description, this.completed});

  factory UpdateTodoRequest.fromJson(Map<String, dynamic> json) => UpdateTodoRequest(
    title: json['title'] as String?,
    description: json['description'] as String?,
    completed: json['completed'] as bool?,
  );
  final String? title;
  final String? description;
  final bool? completed;

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (completed != null) 'completed': completed,
  };
}

/// Paginated response wrapper
@DTO()
class TodoPaginatedResponse implements PaginatedResponse<TodoProfile> {
  TodoPaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory TodoPaginatedResponse.fromJson(Map<String, dynamic> json) => TodoPaginatedResponse(
    data: (json['data'] ?? []).map((item) => TodoProfile.fromJson(item as Map<String, dynamic>)).toList(),
    page: json['page'] ?? 1,
    limit: json['limit'] ?? 10,
    total: json['total'] ?? 0,
    hasMore: json['hasMore'] ?? false,
  );
  @override
  final List<TodoProfile> data;
  @override
  final int page;
  @override
  final int limit;
  @override
  final int total;
  @override
  final bool hasMore;

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'page': page,
    'limit': limit,
    'total': total,
    'hasMore': hasMore,
  };
}
