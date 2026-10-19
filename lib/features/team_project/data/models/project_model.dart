import '../../domain/entities/project_entity.dart';

/// Data model mapping between Supabase PostgREST projects table and ProjectEntity.
class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.projectId,
    required super.title,
    required super.description,
    required super.clientId,
    super.teamLeaderId,
    required super.budget,
    super.progressPercent,
    super.status,
    required super.startDate,
    super.deadline,
    super.requiredSkills,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Turnkey Project',
      description: json['description']?.toString() ?? '',
      clientId: json['client_id']?.toString() ?? '',
      teamLeaderId: json['team_leader_id']?.toString(),
      budget: (json['budget'] as num?)?.toDouble() ?? 50000.0,
      progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'In Progress',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString())
          : null,
      requiredSkills:
          (json['required_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      'description': description,
      'client_id': clientId,
      'team_leader_id': teamLeaderId,
      'budget': budget,
      'progress_percent': progressPercent,
      'status': status,
      'start_date': startDate.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'required_skills': requiredSkills,
    };
  }
}
