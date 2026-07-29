class Task {
  final String id;
  final String title;
  final String? description;
  final bool isDone;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    this.description,
    required this.createdAt,
  });

  //copier et modifiée
  Task copyWith({
    String? id,
    String? title,
    bool? isDone,
    String? description,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      isDone: json['isDone'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, description: $description, isDone: $isDone, createdAt: $createdAt)';
}
