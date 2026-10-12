import 'package:flutter/foundation.dart';

/// Domain Entity representing the calculated algorithmic match result
/// between a Customer Requirement and a candidate Worker.
/// Aligned with SRS Section 3.1.G (FR-G01 - FR-G04) and table `match_results`.
@immutable
class MatchResultEntity {
  final String matchId;
  final String requirementId;
  final String workerProfileId;
  final double matchScore; // Overall score (0.00 - 100.00)
  final int rankPosition; // 1, 2, 3...
  final double skillScore; // 0 - 100 (Weight: 40%)
  final double distanceScore; // 0 - 100 (Weight: 25%)
  final double ratingScore; // 0 - 100 (Weight: 20%)
  final double rateScore; // 0 - 100 (Weight: 15%)

  // Flattened candidate profile metadata for rich UI representation
  final String workerName;
  final String? avatarUrl;
  final String tradeTitle;
  final String location;
  final double hourlyRate;
  final double rating;
  final int completedJobs;
  final bool isVerified;
  final List<String> skills;

  const MatchResultEntity({
    required this.matchId,
    required this.requirementId,
    required this.workerProfileId,
    required this.matchScore,
    required this.rankPosition,
    this.skillScore = 95.0,
    this.distanceScore = 90.0,
    this.ratingScore = 98.0,
    this.rateScore = 85.0,
    required this.workerName,
    this.avatarUrl,
    required this.tradeTitle,
    required this.location,
    required this.hourlyRate,
    this.rating = 4.9,
    this.completedJobs = 15,
    this.isVerified = true,
    this.skills = const [],
  });

  factory MatchResultEntity.fromMap(Map<String, dynamic> map) {
    return MatchResultEntity(
      matchId: map['match_id']?.toString() ?? '',
      requirementId: map['requirement_id']?.toString() ?? '',
      workerProfileId: map['worker_profile_id']?.toString() ?? '',
      matchScore: (map['match_score'] as num?)?.toDouble() ?? 0.0,
      rankPosition: (map['rank_position'] as num?)?.toInt() ?? 1,
      skillScore: (map['skill_score'] as num?)?.toDouble() ?? 90.0,
      distanceScore: (map['distance_score'] as num?)?.toDouble() ?? 85.0,
      ratingScore: (map['rating_score'] as num?)?.toDouble() ?? 95.0,
      rateScore: (map['rate_score'] as num?)?.toDouble() ?? 80.0,
      workerName: map['worker_name']?.toString() ?? 'Specialist',
      avatarUrl: map['avatar_url']?.toString(),
      tradeTitle: map['trade_title']?.toString() ?? 'Certified Specialist',
      location: map['location']?.toString() ?? 'Dhaka',
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 500.0,
      rating: (map['rating_average'] as num?)?.toDouble() ?? 5.0,
      completedJobs: (map['completed_jobs'] as num?)?.toInt() ?? 0,
      isVerified:
          map['is_verified'] == true ||
          map['verification_status'] == 'Verified',
      skills:
          (map['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'requirement_id': requirementId,
      'worker_profile_id': workerProfileId,
      'match_score': matchScore,
      'rank_position': rankPosition,
      'skill_score': skillScore,
      'distance_score': distanceScore,
      'rating_score': ratingScore,
      'rate_score': rateScore,
      'worker_name': workerName,
      'trade_title': tradeTitle,
      'location': location,
      'hourly_rate': hourlyRate,
      'rating_average': rating,
      'completed_jobs': completedJobs,
      'is_verified': isVerified,
    };
  }
}
