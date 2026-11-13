import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
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
  late final List<TaskItemModel> _tasks;

  String get _cacheKey => 'task_board_tasks_${widget.projectId}';

  static final List<TaskItemModel> _defaultTasks = [
    const TaskItemModel(
      taskId: 'task_001',
      projectId: 'proj_001',
      title: 'Architectural Blueprint & Load Calculations',
      description:
          'Review structural engineering drawings for HVAC ductwork and MEP layout.',
      status: 'Done',
      priority: 'High',
      assignedWorkerName: 'Engr. Tariqul Islam',
      budgetWeight: 15000.0,
    ),
    const TaskItemModel(
      taskId: 'task_002',
      projectId: 'proj_001',
      title: '3-Phase Main Switchboard & Conduit Installation',
      description:
          'Complete high-voltage distribution wiring and grounding rod certification.',
      status: 'In Progress',
      priority: 'Urgent',
      assignedWorkerName: 'Rahul Ahmed',
      budgetWeight: 25000.0,
    ),
    const TaskItemModel(
      taskId: 'task_003',
      projectId: 'proj_001',
      title: 'Fire Suppression & Sensor Calibration',
      description:
          'Install heat and smoke detectors connected to emergency central control.',
      status: 'In Review',
      priority: 'High',
      assignedWorkerName: 'Kamal Hossain',
      budgetWeight: 12000.0,
    ),
    const TaskItemModel(
      taskId: 'task_004',
      projectId: 'proj_001',
      title: 'Final Quality Audit & Handover Signoff',
      description:
          'Complete client inspection walkthrough and generate signed digital handover certificate.',
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
    final cached = LocalCacheService.instance.get(_cacheKey);
    if (cached is List && cached.isNotEmpty) {
      _tasks = cached
          .whereType<Map>()
          .map((m) => TaskItemModel.fromJson(Map<String, dynamic>.from(m)))
          .toList();
      if (_tasks.isEmpty) {
        _tasks.addAll(_defaultTasks);
      }
    } else {
      _tasks = List<TaskItemModel>.from(_defaultTasks);
    }
  }

  void _saveTasksLocally() {
    LocalCacheService.instance.put(
      _cacheKey,
      _tasks
          .map(
            (t) => {
              ...t.toJson(),
              'assigned_worker_name': t.assignedWorkerName,
            },
          )
          .toList(),
    );
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
    _saveTasksLocally();

    UiFeedbackHelper.showSuccess(context, 'Task moved to $nextStatus');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppBar(
        title: Text(
          'Task Board — ${widget.projectTitle}',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: tokens.sheetBg,
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
            icon: Icon(
              Icons.add_task_rounded,
              size: 22,
              color: colorScheme.onSurface,
            ),
            onPressed: () async {
              final newTask = await Navigator.of(context).push<TaskItemModel>(
                MaterialPageRoute(
                  builder: (_) => AssignTaskScreen(projectId: widget.projectId),
                ),
              );
              if (newTask != null && mounted) {
                setState(() => _tasks.add(newTask));
                _saveTasksLocally();
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: tokens.brandAccent,
          unselectedLabelColor: tokens.mutedText,
          indicatorColor: tokens.brandAccent,
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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (list.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 48,
                color: tokens.mutedText.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'No tasks in "$status"',
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.mutedText, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = list[index];
        final isUrgent = task.priority == 'Urgent' || task.priority == 'High';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(
              color: isUrgent
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : tokens.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? AppColors.errorRed.withValues(alpha: 0.12)
                            : tokens.softBlueBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${task.priority} Priority',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isUrgent
                              ? AppColors.errorRed
                              : tokens.brandAccent,
                        ),
                      ),
                    ),
                    if (task.budgetWeight > 0)
                      Text(
                        '৳ ${task.budgetWeight.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: tokens.brandAccent,
                        ),
                      ),
                  ],
                ),
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
                    color: tokens.secondaryText,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 16,
                          color: tokens.mutedText,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            task.assignedWorkerName ?? 'Unassigned',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (status != 'Done')
                      TextButton.icon(
                        icon: Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: tokens.brandAccent,
                        ),
                        label: Text(
                          status == 'To Do'
                              ? 'Start Task'
                              : status == 'In Progress'
                              ? 'Submit Review'
                              : 'Mark Done',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tokens.brandAccent,
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
              ),
            ],
          ),
        );
      },
    );
  }
}
