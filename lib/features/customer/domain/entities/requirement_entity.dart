/// Domain entity representing a customer's job/service requirement.
class RequirementEntity {
  final String requirementId;
  final String clientId;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final double budget;
  final String
  status; // 'Open', 'Assigned', 'In Progress', 'Completed', 'Cancelled'
  final DateTime createdAt;
  final bool isComplexProject;

  const RequirementEntity({
    required this.requirementId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.budget,
    this.status = 'Open',
    required this.createdAt,
    this.isComplexProject = false,
  });
}
