import 'package:flutter/material.dart';

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
    return Column(
      key: const ValueKey('tasks_tab'),
      children: [
        // Sub-filter tabs: Tasks | Files | Milestones
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              _buildTaskSubTab(0, 'Tasks'),
              const SizedBox(width: 10),
              _buildTaskSubTab(1, 'Files'),
              const SizedBox(width: 10),
              _buildTaskSubTab(2, 'Milestones'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Task Items List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ProjectTaskItemCard(
                task: task,
                onToggleStatus: () => onToggleTaskStatus(index),
              );
            },
          ),
        ),

        // Bottom "+ Add Task" button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text(
                'Add Task',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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

  Widget _buildTaskSubTab(int index, String title) {
    final isSelected = selectedTaskFilter == index;
    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(0xFF2563EB)
                : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}
