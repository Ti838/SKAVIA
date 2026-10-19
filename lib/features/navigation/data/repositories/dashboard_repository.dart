import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../customer/data/models/requirement_model.dart';

/// Aggregated dashboard data container for worker profile stats
class DashboardWorkerStats {
  final int completedJobs;
  final double ratingAverage;
  final bool isAvailable;
  final double totalEarnings;
  final List<Map<String, dynamic>> incomingRequests;

  const DashboardWorkerStats({
    required this.completedJobs,
    required this.ratingAverage,
    required this.isAvailable,
    required this.totalEarnings,
    required this.incomingRequests,
  });

  factory DashboardWorkerStats.empty() {
    return const DashboardWorkerStats(
      completedJobs: 0,
      ratingAverage: 5.0,
      isAvailable: true,
      totalEarnings: 0.0,
      incomingRequests: [],
    );
  }
}

/// Repository responsible for dashboard data aggregation across roles, active bookings,
/// worker metrics, live requirement feeds, and notification badges.
class DashboardRepository {
  final SupabaseClient _client;

  DashboardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  /// Loads the most recent active service request for the client (Requested, Accepted, In Progress)
  Future<Map<String, dynamic>?> getActiveClientBooking(String userId) async {
    try {
      final res = await _client
          .from('service_requests')
          .select(
            'service_request_id, agreed_price, service_notes, scheduled_at, status, '
            'worker_profiles ( title, rating_average, users ( full_name, phone, avatar_url ) )',
          )
          .eq('client_id', userId)
          .inFilter('status', ['Requested', 'Accepted', 'In Progress'])
          .order('scheduled_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[DashboardRepository] getActiveClientBooking error: $e');
      return null;
    }
  }

  /// Fetches basic user profile record (avatar, active role mode, location)
  Future<Map<String, dynamic>?> getUserProfileRecord(String userId) async {
    try {
      final res = await _client
          .from('users')
          .select('avatar_url, active_mode, location')
          .eq('user_id', userId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[DashboardRepository] getUserProfileRecord error: $e');
      return null;
    }
  }

  /// Fetches worker metrics including completed jobs, rating, earnings, and live incoming requests
  Future<DashboardWorkerStats> getWorkerStats(String userId) async {
    try {
      final workerProfile = await _client
          .from('worker_profiles')
          .select(
            'worker_profile_id, completed_jobs, rating_average, is_available',
          )
          .eq('user_id', userId)
          .maybeSingle();

      if (workerProfile == null) {
        return DashboardWorkerStats.empty();
      }

      final wpId = workerProfile['worker_profile_id'];
      final jobs = (workerProfile['completed_jobs'] as num?)?.toInt() ?? 0;
      final rating =
          (workerProfile['rating_average'] as num?)?.toDouble() ?? 5.0;
      final available = workerProfile['is_available'] as bool? ?? true;

      // Earnings calculation
      double earningsSum = 0.0;
      try {
        final earningsRes = await _client
            .from('worker_earnings')
            .select('net_amount')
            .eq('worker_profile_id', wpId)
            .eq('status', 'Credited');

        if (earningsRes.isNotEmpty) {
          for (final row in earningsRes) {
            earningsSum += (row['net_amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      } catch (_) {}

      // Incoming requests
      List<Map<String, dynamic>> requests = [];
      try {
        final requestsRes = await _client
            .from('service_requests')
            .select(
              'service_request_id, agreed_price, service_notes, scheduled_at, location',
            )
            .eq('worker_profile_id', wpId)
            .eq('status', 'Requested')
            .limit(5);
        requests = List<Map<String, dynamic>>.from(requestsRes);
      } catch (_) {}

      return DashboardWorkerStats(
        completedJobs: jobs,
        ratingAverage: rating,
        isAvailable: available,
        totalEarnings: earningsSum,
        incomingRequests: requests,
      );
    } catch (e) {
      debugPrint('[DashboardRepository] getWorkerStats error: $e');
      return DashboardWorkerStats.empty();
    }
  }

  /// Fetches open job requirements for customer dashboard preview
  Future<List<JobRequirementItem>> getOpenRequirements({int limit = 5}) async {
    try {
      final reqRes = await _client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, created_at, category_id, submitted_by',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .limit(limit);

      final List<JobRequirementItem> items = [];
      for (final row in reqRes) {
        items.add(
          JobRequirementItem(
            id: row['requirement_id']?.toString() ?? '',
            title: row['title']?.toString() ?? 'Requirement',
            category: 'Trade & Service',
            categoryId: row['category_id']?.toString() ?? 'cat_electrical',
            description: row['description']?.toString() ?? '',
            location: row['location']?.toString() ?? 'Dhaka, Bangladesh',
            budgetMin: (row['budget'] as num?)?.toDouble() ?? 1200.0,
            budgetMax: ((row['budget'] as num?)?.toDouble() ?? 1200.0) * 1.25,
            urgency: 'Standard',
            timeAgo: 'Recent',
            clientName: 'Verified Member',
          ),
        );
      }
      return items;
    } catch (e) {
      debugPrint('[DashboardRepository] getOpenRequirements error: $e');
      return [];
    }
  }

  /// Checks if current user has any unread notifications
  Future<bool> hasUnreadNotifications(String userId) async {
    try {
      final notifRes = await _client
          .from('notifications')
          .select('notification_id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .limit(1);
      return (notifRes as List).isNotEmpty;
    } catch (e) {
      debugPrint('[DashboardRepository] hasUnreadNotifications error: $e');
      return false;
    }
  }

  /// Updates active user mode ('client' or 'worker') in database
  Future<void> updateActiveMode(String userId, String mode) async {
    try {
      await _client
          .from('users')
          .update({'active_mode': mode})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('[DashboardRepository] updateActiveMode error: $e');
    }
  }

  /// Toggles worker online availability
  Future<void> updateWorkerAvailability(String userId, bool isAvailable) async {
    try {
      await _client
          .from('worker_profiles')
          .update({'is_available': isAvailable})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('[DashboardRepository] updateWorkerAvailability error: $e');
    }
  }
}
