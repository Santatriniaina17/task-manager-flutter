import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<Task> onToggle;
  final ValueChanged<int> onDelete;
  final ValueChanged<Task> onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),

      onDismissed: (_) {
        onDelete(task.id);
      },

      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) {
            onToggle(task);
          },
        ),

        title: Text(
          task.title,
          style: task.isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),

        subtitle: task.description != null && task.description!.isNotEmpty
            ? Text(task.description!)
            : null,

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit(task);
                break;

              case 'delete':
                onDelete(task.id);
                break;
            }
          },

          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),

            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 8),
                  Text('Supprimer'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
