import 'package:flutter/material.dart';

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
  final bool isVerified;

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
    this.isVerified = false,
  });

  /// Verified technicians registry (Zero Hardcoded / Fake Data Enforcement).
  /// Technicians are loaded dynamically from Supabase marketplace and live GPS pings.
  static const List<RadarTechnician> seedTechnicians = [];
}
