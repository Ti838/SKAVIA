/// Domain entity representing a SKAVIA skilled worker / service specialist.
class WorkerProfileEntity {
  final String workerProfileId;
  final String userId;
  final String fullName;
  final String title;
  final String bio;
  final double hourlyRate;
  final double rating;
  final int reviewsCount;
  final String experience;
  final String location;
  final bool isVerified;
  final bool isAvailable;
  final List<String> skills;
  final String? avatarUrl;

  const WorkerProfileEntity({
    required this.workerProfileId,
    required this.userId,
    required this.fullName,
    required this.title,
    this.bio = '',
    required this.hourlyRate,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.experience = '',
    this.location = 'Dhaka, Bangladesh',
    this.isVerified = false,
    this.isAvailable = false,
    this.skills = const [],
    this.avatarUrl,
  });
}
