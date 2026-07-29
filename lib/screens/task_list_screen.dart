import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskListProvider);

    final error = ref.watch(taskErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),

      body: Column(
        children: [
          if (error != null) _ErrorBanner(message: error),

          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (err, _) => _RetryView(
                message: err is Exception ? err.toString() : 'Erreur inconnue',
                onRetry: () {
                  ref.invalidate(taskListProvider);
                },
              ),

              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(child: Text('Aucune tâche'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(taskListProvider.future),

                  child: ListView.builder(
                    itemCount: tasks.length,

                    itemBuilder: (context, index) {
                      final task = tasks[index];

                      return TaskTile(
                        task: task,

                        // Cocher / décocher
                        onToggle: (task) {
                          ref.read(taskListProvider.notifier).toggleTask(task);
                        },

                        // Supprimer
                        onDelete: (id) {
                          ref.read(taskListProvider.notifier).deleteTask(id);
                        },

                        // Modifier
                        onEdit: (task) async {
                          final input = await showEditTaskDialog(
                            context,
                            task: task,
                          );

                          if (input == null) {
                            return;
                          }

                          if (input.title.trim().isEmpty) {
                            return;
                          }

                          final updatedTask = task.copyWith(
                            title: input.title,
                            description: input.description,
                          );

                          ref
                              .read(taskListProvider.notifier)
                              .updateTask(updatedTask);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final input = await showAddTaskDialog(context);

          if (input == null) {
            return;
          }

          if (input.title.trim().isEmpty) {
            return;
          }

          ref
              .read(taskListProvider.notifier)
              .addTask(input.title, description: input.description);
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      color: Theme.of(context).colorScheme.errorContainer,

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

      child: Text(
        message,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  final String message;

  final VoidCallback onRetry;

  const _RetryView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(message, textAlign: TextAlign.center),

          const SizedBox(height: 12),

          FilledButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
}
