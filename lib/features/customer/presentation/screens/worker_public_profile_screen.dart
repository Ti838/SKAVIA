export '../../../worker/presentation/screens/worker_profile_detail_screen.dart'
    show WorkerProfileDetailScreen;

import 'package:flutter/material.dart';

import '../../../worker/presentation/screens/worker_profile_detail_screen.dart';

/// Customer alias for viewing a worker's public marketplace profile.
class WorkerPublicProfileScreen extends StatelessWidget {
  final String name;
  final String title;
  final double rating;
  final int reviewsCount;
  final String experience;
  final String location;
  final String hourlyRate;
  final List<String> skills;
  final String avatarUrl;

  const WorkerPublicProfileScreen({
    super.key,
    this.name = 'Rahul Ahmed',
    this.title = 'Flutter Developer',
    this.rating = 4.8,
    this.reviewsCount = 32,
    this.experience = '2+ years',
    this.location = 'Dhaka, Bangladesh',
    this.hourlyRate = '৳ 1,500/hr',
    this.skills = const ['Flutter', 'Dart', 'Firebase', 'REST API', 'UI/UX'],
    this.avatarUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=250',
  });

  @override
  Widget build(BuildContext context) {
    return WorkerProfileDetailScreen(
      name: name,
      title: title,
      rating: rating,
      reviewsCount: reviewsCount,
      experience: experience,
      location: location,
      hourlyRate: hourlyRate,
      skills: skills,
      avatarUrl: avatarUrl,
    );
  }
}
