import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/empty_state.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              if (provider.errorMessage != null)
                _ErrorBanner(message: provider.errorMessage!),
              Expanded(child: _buildBody(context, provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final input = await showAddTaskDialog(context);
          if (input != null && input.title.isNotEmpty) {
            // ignore: use_build_context_synchronously
            context.read<TaskProvider>().addTask(
              input.title,
              description: input.description,
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, TaskProvider provider) {
    if (provider.isLoading && provider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.tasks.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.fetchTasks,
        // Wrap dans un ListView pour que le pull-to-refresh
        // fonctionne même quand la liste est vide.
        child: ListView(children: const [SizedBox(height: 120), EmptyState()]),
      );
    }

    return RefreshIndicator(
      onRefresh: provider.fetchTasks,
      child: ListView.builder(
        itemCount: provider.tasks.length,
        itemBuilder: (context, index) {
          final task = provider.tasks[index];
          return TaskTile(
            task: task,
            onToggle: (t) => provider.toggleTask(t),
            onDelete: (id) => provider.deleteTask(id),
          );
        },
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
