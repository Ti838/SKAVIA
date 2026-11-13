/// Data model representing an actionable milestone or subtask in a SKAVIA project.
/// Aligned with ClickUp & Upwork task pipeline architecture.
class TaskItemModel {
  final String taskId;
  final String projectId;
  final String title;
  final String description;
  final String status; // 'To Do', 'In Progress', 'In Review', 'Done'
  final String priority; // 'Low', 'Medium', 'High', 'Urgent'
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final DateTime? deadline;
  final double budgetWeight;

  const TaskItemModel({
    required this.taskId,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = 'To Do',
    this.priority = 'Medium',
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.deadline,
    this.budgetWeight = 0.0,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['deadline'] ?? json['due_date'];
    return TaskItemModel(
      taskId: json['task_id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Project Task',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Assigned',
      priority: json['priority']?.toString() ?? 'Medium',
      assignedWorkerId:
          (json['assigned_team_member_id'] ?? json['assigned_to'])?.toString(),
      assignedWorkerName: json['assigned_worker_name']?.toString(),
      deadline: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
      budgetWeight: (json['budget_weight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'project_id': projectId,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assigned_to': assignedWorkerId,
      'due_date': deadline?.toIso8601String(),
      'budget_weight': budgetWeight,
    };
  }

  TaskItemModel copyWith({
    String? taskId,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedWorkerId,
    String? assignedWorkerName,
    DateTime? deadline,
    double? budgetWeight,
  }) {
    return TaskItemModel(
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedWorkerId: assignedWorkerId ?? this.assignedWorkerId,
      assignedWorkerName: assignedWorkerName ?? this.assignedWorkerName,
      deadline: deadline ?? this.deadline,
      budgetWeight: budgetWeight ?? this.budgetWeight,
    );
  }
}
