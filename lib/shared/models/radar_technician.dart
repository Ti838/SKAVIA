import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Data class representing a verified technician on the live radar map
class RadarTechnician {
  final String id;
  final String name;
  final String trade;
  final IconData icon;
  final Color color;
  final double rating;
  final int jobs;
  final double distanceKm;
  final double startingRate;
  final double latitude;
  final double longitude;
  final String zone;

  const RadarTechnician({
    required this.id,
    required this.name,
    required this.trade,
    required this.icon,
    required this.color,
    required this.rating,
    required this.jobs,
    required this.distanceKm,
    required this.startingRate,
    required this.latitude,
    required this.longitude,
    required this.zone,
  });

  /// Seed verified technician coordinates across metropolitan areas
  static const List<RadarTechnician> seedTechnicians = [
    RadarTechnician(
      id: 'tech_1',
      name: 'Mohammad Rafiqul Islam',
      trade: 'Master Electrician',
      icon: Icons.electric_bolt_rounded,
      color: AppColors.accentPeach,
      rating: 4.95,
      jobs: 142,
      distanceKm: 1.2,
      startingRate: 500,
      latitude: 23.7465,
      longitude: 90.3750,
      zone: 'Dhanmondi, Dhaka',
    ),
    RadarTechnician(
      id: 'tech_2',
      name: 'Kazi Farhan Tanvir',
      trade: 'HVAC & AC Specialist',
      icon: Icons.ac_unit_rounded,
      color: AppColors.primarySky,
      rating: 4.88,
      jobs: 98,
      distanceKm: 2.1,
      startingRate: 800,
      latitude: 23.7925,
      longitude: 90.4078,
      zone: 'Gulshan 1, Dhaka',
    ),
    RadarTechnician(
      id: 'tech_3',
      name: 'Abdur Rahim',
      trade: 'Sanitary Master Plumber',
      icon: Icons.plumbing_rounded,
      color: AppColors.accentAqua,
      rating: 4.90,
      jobs: 116,
      distanceKm: 2.8,
      startingRate: 450,
      latitude: 23.7937,
      longitude: 90.4043,
      zone: 'Banani, Dhaka',
    ),
    RadarTechnician(
      id: 'tech_4',
      name: 'Kamrul Hasan',
      trade: 'Wiring & Circuit Specialist',
      icon: Icons.electric_bolt_rounded,
      color: AppColors.accentPeach,
      rating: 4.82,
      jobs: 64,
      distanceKm: 3.5,
      startingRate: 550,
      latitude: 23.8071,
      longitude: 90.3686,
      zone: 'Mirpur 10, Dhaka',
    ),
    RadarTechnician(
      id: 'tech_5',
      name: 'Shahadat Hossain',
      trade: 'AC Gas & Inverter Expert',
      icon: Icons.ac_unit_rounded,
      color: AppColors.primarySky,
      rating: 4.92,
      jobs: 85,
      distanceKm: 4.2,
      startingRate: 850,
      latitude: 23.8759,
      longitude: 90.3795,
      zone: 'Uttara Sec 3, Dhaka',
    ),
  ];
}
