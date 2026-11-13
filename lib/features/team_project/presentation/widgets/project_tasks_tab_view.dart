import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'project_task_item_card.dart';

class ProjectTasksTabView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final int selectedTaskFilter;
  final ValueChanged<int> onFilterChanged;
  final ValueChanged<int> onToggleTaskStatus;
  final VoidCallback onAddTask;

  const ProjectTasksTabView({
    super.key,
    required this.tasks,
    required this.selectedTaskFilter,
    required this.onFilterChanged,
    required this.onToggleTaskStatus,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    final indexedTasks = tasks.asMap().entries.where((entry) {
      final t = entry.value;
      if (selectedTaskFilter == 1) {
        return t['hasAttachment'] == true ||
            (t['attachmentName']?.toString().isNotEmpty ?? false);
      }
      if (selectedTaskFilter == 2) {
        return t['status'] == 'Completed' || t['isMilestone'] == true;
      }
      return true;
    }).toList();

    return Column(
      key: const ValueKey('tasks_tab'),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              _buildTaskSubTab(context, 0, 'Tasks (${tasks.length})'),
              const SizedBox(width: 10),
              _buildTaskSubTab(context, 1, 'Files'),
              const SizedBox(width: 10),
              _buildTaskSubTab(context, 2, 'Milestones'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: indexedTasks.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedTaskFilter == 1
                              ? Icons.folder_open_rounded
                              : Icons.flag_outlined,
                          size: 46,
                          color: tokens.mutedText,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedTaskFilter == 1
                              ? 'No deliverable files attached yet'
                              : 'No milestones completed yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedTaskFilter == 1
                              ? 'Upload files on task submissions to track deliverables here.'
                              : 'Mark tasks Completed to promote project milestones.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: tokens.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  itemCount: indexedTasks.length,
                  itemBuilder: (context, idx) {
                    final entry = indexedTasks[idx];
                    return ProjectTaskItemCard(
                      task: entry.value,
                      onToggleStatus: () => onToggleTaskStatus(entry.key),
                    );
                  },
                ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Task',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.brandAccent,
                foregroundColor: tokens.onBrandAccent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSubTab(BuildContext context, int index, String title) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isSelected = selectedTaskFilter == index;

    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.softBlueBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? tokens.brandAccent : tokens.border,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? tokens.brandAccent
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
