class Task {
  final String id;
  final String title;
  final bool isDone;

  Task({required this.id, required this.title, required this.isDone});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(id: json['id'], title: json['title'], isDone: json['isDone']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isDone': isDone};
  }

  //copier et modifiée
  Task copyWith({String? title, bool? isDone}) {
    return Task(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
