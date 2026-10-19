/// Domain entity representing a collaborative project or turnkey business contract.
class ProjectEntity {
  final String projectId;
  final String title;
  final String description;
  final String clientId;
  final String? teamLeaderId;
  final double budget;
  final double progressPercent; // 0.0 to 1.0
  final String status; // 'Planning', 'In Progress', 'In Review', 'Completed'
  final DateTime startDate;
  final DateTime? deadline;
  final List<String> requiredSkills;

  const ProjectEntity({
    required this.projectId,
    required this.title,
    required this.description,
    required this.clientId,
    this.teamLeaderId,
    required this.budget,
    this.progressPercent = 0.0,
    this.status = 'In Progress',
    required this.startDate,
    this.deadline,
    this.requiredSkills = const [],
  });
}
