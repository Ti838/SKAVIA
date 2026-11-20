/// Aggregated real user profile activity stats.
/// Strictly zero-initialized — never fabricates a 5.0 rating without verified reviews.
class ProfileStatsModel {
  final int servicesCount;
  final int projectsCount;
  final double ratingAverage;
  final int reviewCount;
  final int completedJobs;

  const ProfileStatsModel({
    this.servicesCount = 0,
    this.projectsCount = 0,
    this.ratingAverage = 0.0,
    this.reviewCount = 0,
    this.completedJobs = 0,
  });

  bool get hasVerifiedRating => reviewCount > 0 && ratingAverage > 0;

  Map<String, dynamic> toJson() => {
    'services_count': servicesCount,
    'projects_count': projectsCount,
    'rating_average': ratingAverage,
    'review_count': reviewCount,
    'completed_jobs': completedJobs,
  };

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    final reviews = (json['review_count'] as num?)?.toInt() ?? 0;
    final rawRating = (json['rating_average'] as num?)?.toDouble() ?? 0.0;
    return ProfileStatsModel(
      servicesCount: (json['services_count'] as num?)?.toInt() ?? 0,
      projectsCount: (json['projects_count'] as num?)?.toInt() ?? 0,
      ratingAverage: rawRating,
      reviewCount: reviews,
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 0,
    );
  }
}
