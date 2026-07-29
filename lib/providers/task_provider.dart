import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/task_api_service.dart';
import '../models/task.dart';

const String kMyJsonServerBaseUrl =
    'https://my-json-server.typicode.com/Santatriniaina17/base-test';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: kMyJsonServerBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});

final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  return TaskApiService(ref.watch(dioProvider));
});

/// Erreur transitoire à afficher (bannière), séparée de l'état
/// principal pour ne pas perdre les données déjà chargées quand
/// une action ponctuelle échoue.
final taskErrorProvider = StateProvider<String?>((ref) => null);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() {
    return ref.read(taskApiServiceProvider).fetchTasks();
  }

  Future<void> addTask(String title, {String? description}) async {
    final api = ref.read(taskApiServiceProvider);
    final previous = state.value ?? [];

    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimistic = Task(
      id: tempId,
      title: title,
      description: description,
      isDone: false,
      createdAt: DateTime.now(),
    );

    state = AsyncData([...previous, optimistic]);
    ref.read(taskErrorProvider.notifier).state = null;

    try {
      final created = await api.createTask(
        title: title,
        description: description,
      );
      state = AsyncData([
        for (final t in state.value ?? [])
          if (t.id == tempId) created else t,
      ]);
    } on TaskApiException catch (e) {
      state = AsyncData(previous); // rollback
      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> toggleTask(Task task) async {
    final previous = state.value ?? [];
    final updated = task.copyWith(isDone: !task.isDone);
    state = AsyncData([
      for (final t in previous)
        if (t.id == task.id) updated else t,
    ]);
    ref.read(taskErrorProvider.notifier).state = null;

    try {
      await ref.read(taskApiServiceProvider).updateTask(updated);
    } on TaskApiException catch (e) {
      state = AsyncData(previous); // rollback
      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }

  Future<void> deleteTask(int id) async {
    final previous = state.value ?? [];
    state = AsyncData(previous.where((t) => t.id != id).toList());
    ref.read(taskErrorProvider.notifier).state = null;

    try {
      await ref.read(taskApiServiceProvider).deleteTask(id);
    } on TaskApiException catch (e) {
      state = AsyncData(previous); // rollback
      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }
}

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);
