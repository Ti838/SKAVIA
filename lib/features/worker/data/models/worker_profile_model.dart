import '../../domain/entities/worker_profile_entity.dart';

/// Data transfer object mapping between Supabase PostgREST and WorkerProfileEntity.
class WorkerProfileModel extends WorkerProfileEntity {
  const WorkerProfileModel({
    required super.workerProfileId,
    required super.userId,
    required super.fullName,
    required super.title,
    super.bio,
    required super.hourlyRate,
    super.rating,
    super.reviewsCount,
    super.experience,
    super.location,
    super.isVerified,
    super.isAvailable,
    super.skills,
    super.avatarUrl,
  });

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) {
    return WorkerProfileModel(
      workerProfileId: json['worker_profile_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Specialist',
      title:
          json['trade_title']?.toString() ??
          json['title']?.toString() ??
          'Technician',
      bio: json['bio']?.toString() ?? '',
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 150.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      experience: json['experience']?.toString() ?? '2+ years',
      location: json['location']?.toString() ?? 'Dhaka, Bangladesh',
      isVerified: json['is_verified'] == true || json['status'] == 'Verified',
      isAvailable: json['is_available'] != false,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'worker_profile_id': workerProfileId,
      'user_id': userId,
      'trade_title': title,
      'bio': bio,
      'hourly_rate': hourlyRate,
      'rating': rating,
      'reviews_count': reviewsCount,
      'experience': experience,
      'location': location,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'skills': skills,
      'avatar_url': avatarUrl,
    };
  }
}
