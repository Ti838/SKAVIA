/// Aggregated real user profile activity stats.
class ProfileStatsModel {
  final int servicesCount;
  final int projectsCount;
  final double ratingAverage;
  final int completedJobs;

  const ProfileStatsModel({
    this.servicesCount = 0,
    this.projectsCount = 0,
    this.ratingAverage = 5.0,
    this.completedJobs = 0,
  });

  Map<String, dynamic> toJson() => {
        'services_count': servicesCount,
        'projects_count': projectsCount,
        'rating_average': ratingAverage,
        'completed_jobs': completedJobs,
      };

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatsModel(
      servicesCount: (json['services_count'] as num?)?.toInt() ?? 0,
      projectsCount: (json['projects_count'] as num?)?.toInt() ?? 0,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 5.0,
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 0,
    );
  }
}

