import 'package:flutter/foundation.dart';

@immutable
class ReviewModel {
  final String reviewId;
  final String workerProfileId;
  final String? serviceRequestId;
  final String? projectId;
  final String clientId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? clientName;
  final String? clientAvatar;

  const ReviewModel({
    required this.reviewId,
    required this.workerProfileId,
    this.serviceRequestId,
    this.projectId,
    required this.clientId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.clientName,
    this.clientAvatar,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id'] as String? ?? '',
      workerProfileId: json['worker_profile_id'] as String? ?? '',
      serviceRequestId: json['service_request_id'] as String?,
      projectId: json['project_id'] as String?,
      clientId: json['client_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      clientName: json['client_name'] as String?,
      clientAvatar: json['client_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'worker_profile_id': workerProfileId,
      if (serviceRequestId != null) 'service_request_id': serviceRequestId,
      if (projectId != null) 'project_id': projectId,
      'client_id': clientId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

@immutable
class ReputationModel {
  final String reputationId;
  final String workerProfileId;
  final double overallScore;
  final int completedJobs;
  final int totalRatings;
  final String badgeLevel;
  final DateTime updatedAt;

  const ReputationModel({
    required this.reputationId,
    required this.workerProfileId,
    required this.overallScore,
    required this.completedJobs,
    required this.totalRatings,
    required this.badgeLevel,
    required this.updatedAt,
  });

  factory ReputationModel.fromJson(Map<String, dynamic> json) {
    return ReputationModel(
      reputationId: json['reputation_id'] as String? ?? '',
      workerProfileId: json['worker_profile_id'] as String? ?? '',
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 5.0,
      completedJobs: (json['completed_jobs'] as num?)?.toInt() ?? 0,
      totalRatings: (json['total_ratings'] as num?)?.toInt() ?? 0,
      badgeLevel: json['badge_level'] as String? ?? 'Verified Specialist',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
