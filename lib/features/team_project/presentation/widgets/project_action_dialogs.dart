import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Reusable modal dialogs for adding tasks and team members in project management.
class ProjectActionDialogs {
  /// Shows dialog to create a new task
  static void showAddTaskDialog(
    BuildContext context, {
    required ValueChanged<String> onTaskAdded,
  }) {
    final titleController = TextEditingController();
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBg,
        scrollable: true,
        title: Text(
          'Add New Task',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: const InputDecoration(
            hintText: 'e.g. Implement payment flow',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = titleController.text.trim();
              if (text.isNotEmpty) {
                onTaskAdded(text);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.brandAccent,
              foregroundColor: tokens.onBrandAccent,
            ),
            child: const Text('Add Task'),
          ),
        ],
      ),
    ).whenComplete(titleController.dispose);
  }

  /// Shows dialog to add a new team member
  static void showAddMemberDialog(
    BuildContext context, {
    required Function(String name, String role) onMemberAdded,
  }) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBg,
        scrollable: true,
        title: Text(
          'Add Team Member',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: const InputDecoration(
                hintText: 'Member Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: roleController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: const InputDecoration(
                hintText: 'Role (e.g. Developer, QA)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final role = roleController.text.trim();
              if (name.isNotEmpty) {
                onMemberAdded(name, role.isNotEmpty ? role : 'Developer');
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.brandAccent,
              foregroundColor: tokens.onBrandAccent,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    ).whenComplete(() {
      nameController.dispose();
      roleController.dispose();
    });
  }
}
