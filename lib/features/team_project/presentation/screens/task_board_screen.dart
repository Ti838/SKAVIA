import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../data/models/task_item_model.dart';
import 'assign_task_screen.dart';

/// Interactive Task Board Screen inspired by ClickUp status pipelines.
/// Organizes tasks into To Do, In Progress, In Review, and Done.
class TaskBoardScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const TaskBoardScreen({
    super.key,
    required this.projectId,
    this.projectTitle = 'Turnkey Project Execution',
  });

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final List<TaskItemModel> _tasks = [
    const TaskItemModel(
      taskId: 'task_001',
      projectId: 'proj_001',
      title: 'Architectural Blueprint & Load Calculations',
      description: 'Review structural engineering drawings for HVAC ductwork and MEP layout.',
      status: 'Done',
      priority: 'High',
      assignedWorkerName: 'Engr. Tariqul Islam',
      budgetWeight: 15000.0,
    ),
    const TaskItemModel(
      taskId: 'task_002',
      projectId: 'proj_001',
      title: '3-Phase Main Switchboard & Conduit Installation',
      description: 'Complete high-voltage distribution wiring and grounding rod certification.',
      status: 'In Progress',
      priority: 'Urgent',
      assignedWorkerName: 'Rahul Ahmed',
      budgetWeight: 25000.0,
    ),
    const TaskItemModel(
      taskId: 'task_003',
      projectId: 'proj_001',
      title: 'Fire Suppression & Sensor Calibration',
      description: 'Install heat and smoke detectors connected to emergency central control.',
      status: 'In Review',
      priority: 'High',
      assignedWorkerName: 'Kamal Hossain',
      budgetWeight: 12000.0,
    ),
    const TaskItemModel(
      taskId: 'task_004',
      projectId: 'proj_001',
      title: 'Final Quality Audit & Handover Signoff',
      description: 'Complete client inspection walkthrough and generate signed digital handover certificate.',
      status: 'To Do',
      priority: 'Medium',
      assignedWorkerName: 'Pending Specialist',
      budgetWeight: 8000.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TaskItemModel> _getTasksForStatus(String status) {
    return _tasks
        .where((t) => t.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  void _advanceTask(TaskItemModel task) {
    final nextStatus = task.status == 'To Do'
        ? 'In Progress'
        : task.status == 'In Progress'
        ? 'In Review'
        : 'Done';

    setState(() {
      final index = _tasks.indexWhere((t) => t.taskId == task.taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(status: nextStatus);
      }
    });

    UiFeedbackHelper.showSuccess(context, 'Task moved to $nextStatus');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Task Board — ${widget.projectTitle}',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, size: 22),
            onPressed: () async {
              final newTask = await Navigator.of(context).push<TaskItemModel>(
                MaterialPageRoute(
                  builder: (_) => AssignTaskScreen(projectId: widget.projectId),
                ),
              );
              if (newTask != null) {
                setState(() => _tasks.add(newTask));
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryRoyal,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primaryRoyal,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: [
            Tab(text: 'To Do (${_getTasksForStatus('To Do').length})'),
            Tab(
              text: 'In Progress (${_getTasksForStatus('In Progress').length})',
            ),
            Tab(text: 'In Review (${_getTasksForStatus('In Review').length})'),
            Tab(text: 'Done (${_getTasksForStatus('Done').length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('To Do'),
          _buildTaskList('In Progress'),
          _buildTaskList('In Review'),
          _buildTaskList('Done'),
        ],
      ),
    );
  }

  Widget _buildTaskList(String status) {
    final list = _getTasksForStatus(status);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No tasks in "$status"',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      itemCount: list.length,
      separatorBuilder: (_, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = list[index];
        final isUrgent = task.priority == 'Urgent' || task.priority == 'High';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: isUrgent
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? AppColors.errorRed.withValues(alpha: 0.12)
                          : AppColors.primarySky.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${task.priority} Priority',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isUrgent
                            ? AppColors.errorRed
                            : AppColors.primaryRoyal,
                      ),
                    ),
                  ),
                  if (task.budgetWeight > 0)
                    Text(
                      '৳ ${(task.budgetWeight).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primaryRoyal,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                task.title,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: AppColors.textMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.assignedWorkerName ?? 'Unassigned',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  if (status != 'Done')
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                      label: Text(
                        status == 'To Do'
                            ? 'Start Task'
                            : status == 'In Progress'
                            ? 'Submit Review'
                            : 'Mark Done',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => _advanceTask(task),
                    )
                  else
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
