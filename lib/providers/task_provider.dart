import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/mock_task_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;

  TaskProvider({TaskRepository? repository})
    : _repository = repository ?? MockTaskRepository();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _repository.fetchTasks();
    } on TaskRepositoryException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, {String? description}) async {
    _errorMessage = null;
    try {
      final created = await _repository.createTask(
        title: title,
        description: description,
      );
      _tasks = [..._tasks, created];
      notifyListeners();
    } on TaskRepositoryException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Coche / décoche une tâche avec mise à jour optimiste.
  Future<void> toggleTask(Task task) async {
    final previousTasks = _tasks;
    final optimistic = task.copyWith(isDone: !task.isDone);
    _tasks = _tasks.map((t) => t.id == task.id ? optimistic : t).toList();
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateTask(
        task.id,
        isDone: optimistic.isDone,
      );
      _tasks = _tasks.map((t) => t.id == task.id ? updated : t).toList();
    } on TaskRepositoryException catch (e) {
      _tasks = previousTasks; // rollback
      _errorMessage = e.message;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final previousTasks = _tasks;
    _tasks = _tasks.where((t) => t.id != id).toList();
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteTask(id);
    } on TaskRepositoryException catch (e) {
      _tasks = previousTasks; // rollback
      _errorMessage = e.message;
      notifyListeners();
    }
  }
}
