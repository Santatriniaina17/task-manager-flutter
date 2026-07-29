import 'package:flutter/material.dart';

class NewTaskInput {
  final String title;
  final String? description;
  NewTaskInput(this.title, this.description);
}

/// Retourne le titre + description saisis (ou null si annulé).
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
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final title = titleController.text.trim();
            final description = descriptionController.text.trim();
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
