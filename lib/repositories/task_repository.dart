import '../models/task.dart';

class TaskRepositoryException implements Exception {
  final String message;
  TaskRepositoryException(this.message);

  @override
  String toString() => message;
}

abstract class TaskRepository {
  Future<List<Task>> fetchTasks();

  Future<Task> createTask({required String title, String? description});

  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    bool? isDone,
  });

  Future<void> deleteTask(String id);
}
