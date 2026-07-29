import 'package:flutter/material.dart';

import '../models/task.dart';

class NewTaskInput {
  final String title;
  final String? description;

  NewTaskInput(this.title, this.description);
}

// Dialogue pour ajouter une tâche
Future<NewTaskInput?> showAddTaskDialog(BuildContext context) {
  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  return showDialog<NewTaskInput>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Nouvelle tâche'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Titre'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description (optionnel)',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final title = titleController.text.trim();

            final description = descriptionController.text.trim();

            if (title.isEmpty) {
              return;
            }

            Navigator.of(context).pop(
              NewTaskInput(title, description.isEmpty ? null : description),
            );
          },
          child: const Text('Ajouter'),
        ),
      ],
    ),
  );
}

// Dialogue pour modifier une tâche
Future<NewTaskInput?> showEditTaskDialog(
  BuildContext context, {
  required Task task,
}) {
  final titleController = TextEditingController(text: task.title);

  final descriptionController = TextEditingController(
    text: task.description ?? '',
  );

  return showDialog<NewTaskInput>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Modifier la tâche'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Titre'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              hintText: 'Description (optionnel)',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final title = titleController.text.trim();

            final description = descriptionController.text.trim();

            if (title.isEmpty) {
              return;
            }

            Navigator.of(context).pop(
              NewTaskInput(title, description.isEmpty ? null : description),
            );
          },
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
}
