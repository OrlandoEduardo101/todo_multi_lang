class TodoModel {
  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    completed: json['completed'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

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
