import '../models/task.dart';
import 'task_repository.dart';

class MockTaskRepository implements TaskRepository {
  int _idCounter = 3; // 1 et 2 déjà utilisés par les tâches de seed
  final Duration latency;

  final bool shouldFail;

  MockTaskRepository({
    this.latency = const Duration(milliseconds: 500),
    this.shouldFail = false,
  });

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Préparer le test technique',
      description: 'Flutter + NestJS, sans DB, 4h max',
      isDone: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '2',
      title: 'Relire le README',
      isDone: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  Future<void> _simulateNetwork() async {
    await Future.delayed(latency);
    if (shouldFail) {
      throw TaskRepositoryException('Erreur réseau simulée.');
    }
  }

  @override
  Future<List<Task>> fetchTasks() async {
    await _simulateNetwork();
    // Retourne une copie pour ne pas exposer la liste interne.
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task> createTask({required String title, String? description}) async {
    await _simulateNetwork();
    final task = Task(
      id: (_idCounter++).toString(),
      title: title,
      description: description,
      isDone: false,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    return task;
  }

  @override
  Future<Task> updateTask(
    String id, {
    String? title,
    String? description,
    bool? isDone,
  }) async {
    await _simulateNetwork();
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw TaskRepositoryException('Tâche $id introuvable.');
    }
    final updated = _tasks[index].copyWith(
      title: title,
      description: description,
      isDone: isDone,
    );
    _tasks[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(String id) async {
    await _simulateNetwork();
    final removed = _tasks.any((t) => t.id == id);
    if (!removed) {
      throw TaskRepositoryException('Tâche $id introuvable.');
    }
    _tasks.removeWhere((t) => t.id == id);
  }
}
