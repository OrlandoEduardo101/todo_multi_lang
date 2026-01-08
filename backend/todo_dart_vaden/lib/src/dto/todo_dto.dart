import 'package:vaden/vaden.dart';

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
class PaginatedResponse<T> {
  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.hasMore,
  });

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonItem) =>
      PaginatedResponse(
        data: (json['data'] as List).map((item) => fromJsonItem(item as Map<String, dynamic>)).toList(),
        page: json['page'] as int,
        limit: json['limit'] as int,
        total: json['total'] as int,
        hasMore: json['hasMore'] as bool,
      );
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final bool hasMore;

  Map<String, dynamic> toJson(List<Map<String, dynamic>> Function(List<T>) toJsonList) => {
    'data': toJsonList(data),
    'page': page,
    'limit': limit,
    'total': total,
    'hasMore': hasMore,
  };
}
