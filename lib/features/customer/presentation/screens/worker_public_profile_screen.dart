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
    this.name = 'Specialist',
    this.title = 'Trade Specialist',
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.experience = '',
    this.location = 'Dhaka, Bangladesh',
    this.hourlyRate = '৳ 0/hr',
    this.skills = const [],
    this.avatarUrl = '',
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
