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

final taskErrorProvider = StateProvider<String?>((ref) => null);

class TaskListNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() async {
    return ref.read(taskApiServiceProvider).fetchTasks();
  }

  /// Ajouter une tâche
  Future<void> addTask(String title, {String? description}) async {
    final api = ref.read(taskApiServiceProvider);

    final previous = state.value ?? [];

    // ID temporaire 
    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final optimisticTask = Task(
      id: tempId,
      title: title,
      description: description,
      isDone: false,
      createdAt: DateTime.now(),
    );

    // Affichage immédiat
    state = AsyncData([...previous, optimisticTask]);

    ref.read(taskErrorProvider.notifier).state = null;

    try {
      final created = await api.createTask(
        title: title,
        description: description,
      );

      // Remplacer la tâche temporaire
      state = AsyncData([
        for (final task in state.value ?? [])
          if (task.id == tempId) created else task,
      ]);
    } on TaskApiException catch (e) {
      // Rollback
      state = AsyncData(previous);

      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }

  // Modifier uniquement le statut terminé / non terminé
  Future<void> toggleTask(Task task) async {
    final previous = state.value ?? [];

    final updatedTask = task.copyWith(isDone: !task.isDone);

    // Mise à jour immédiate
    state = AsyncData([
      for (final currentTask in previous)
        if (currentTask.id == task.id) updatedTask else currentTask,
    ]);

    ref.read(taskErrorProvider.notifier).state = null;

    try {
      await ref.read(taskApiServiceProvider).updateTask(updatedTask);
    } on TaskApiException catch (e) {
      // Rollback
      state = AsyncData(previous);

      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }

  // Modifier le titre et/ou la description
  Future<void> updateTask(Task updatedTask) async {
    final previous = state.value ?? [];

    // Mise à jour immédiate
    state = AsyncData([
      for (final currentTask in previous)
        if (currentTask.id == updatedTask.id) updatedTask else currentTask,
    ]);

    ref.read(taskErrorProvider.notifier).state = null;

    try {
      final updated = await ref
          .read(taskApiServiceProvider)
          .updateTask(updatedTask);

      // Remplacer avec la réponse du serveur
      state = AsyncData([
        for (final currentTask in state.value ?? [])
          if (currentTask.id == updatedTask.id) updated else currentTask,
      ]);
    } on TaskApiException catch (e) {
      // Rollback
      state = AsyncData(previous);

      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }

  // Supprimer une tâche
  Future<void> deleteTask(int id) async {
    final previous = state.value ?? [];

    // Suppression immédiate
    state = AsyncData(previous.where((task) => task.id != id).toList());

    ref.read(taskErrorProvider.notifier).state = null;

    try {
      await ref.read(taskApiServiceProvider).deleteTask(id);
    } on TaskApiException catch (e) {
      // Rollback
      state = AsyncData(previous);

      ref.read(taskErrorProvider.notifier).state = e.message;
    }
  }
}

final taskListProvider = AsyncNotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);
