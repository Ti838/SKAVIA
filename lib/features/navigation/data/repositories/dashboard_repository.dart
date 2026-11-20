import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../customer/data/models/requirement_model.dart';
import '../models/dashboard_stats_models.dart';

export '../models/dashboard_stats_models.dart';

/// Repository responsible for dashboard data aggregation across roles, active bookings,
/// worker metrics, business operations, live requirement feeds, and notification badges.
class DashboardRepository {
  final SupabaseClient? _injectedClient;

  DashboardRepository({SupabaseClient? client}) : _injectedClient = client;

  SupabaseClient? get _client => _injectedClient ?? tryGetSupabaseClient();

  /// Loads the most recent active service request for the client (Requested, Accepted, In Progress).
  Future<Map<String, dynamic>?> getActiveClientBooking(String userId) async {
    final client = _client;
    if (client == null) return null;
    try {
      final res = await client
          .from('service_requests')
          .select(
            'service_request_id, agreed_price, service_notes, scheduled_at, status, '
            'worker_profiles ( title, rating_average, total_reviews, users ( full_name, phone, avatar_url ) )',
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

  /// Fetches basic user profile record (full_name, avatar, cover, active role mode, location).
  Future<Map<String, dynamic>?> getUserProfileRecord(String userId) async {
    final client = _client;
    if (client == null) return null;
    try {
      final res = await client
          .from('users')
          .select('full_name, avatar_url, cover_url, active_mode, location')
          .eq('user_id', userId)
          .maybeSingle();

      if (res != null && res['active_mode'] != null) {
        final mode = res['active_mode'].toString();
        LocalCacheService.instance.put(
          '${AppConstants.userModeStorageKey}_$userId',
          mode,
        );
        LocalCacheService.instance.put(AppConstants.userModeStorageKey, mode);
      }
      return res;
    } catch (e) {
      debugPrint('[DashboardRepository] getUserProfileRecord error: $e');
      return null;
    }
  }

  /// Resolves which customer-facing workspaces this user has legitimately enrolled in.
  Future<AuthorizedRoleSummary> getAuthorizedRoles(String userId) async {
    final client = _client;
    if (client == null) {
      return const AuthorizedRoleSummary();
    }

    bool hasCustomer = true;
    bool hasEnterprise = false;
    bool hasWorker = false;
    String? customerType;

    try {
      final rolesRes = await client
          .from('user_roles')
          .select('roles(role_name)')
          .eq('user_id', userId);
      for (final row in (rolesRes as List)) {
        final name = (row['roles'] as Map?)?['role_name']?.toString() ?? '';
        if (name == 'Worker') hasWorker = true;
        if (name == 'Business Client' || name == 'Organization') {
          hasEnterprise = true;
          customerType ??= name;
        }
        if (name == 'Individual Customer') hasCustomer = true;
      }
    } catch (_) {}

    try {
      final cust = await client
          .from('customer_profiles')
          .select('customer_type, company_name')
          .eq('user_id', userId)
          .maybeSingle();
      if (cust != null) {
        final cType = cust['customer_type']?.toString();
        if (cType != null && cType.isNotEmpty) {
          customerType = cType;
          if (cType == 'Business Client' || cType == 'Organization') {
            hasEnterprise = true;
          }
        }
      }
    } catch (_) {}

    try {
      final wp = await client
          .from('worker_profiles')
          .select('worker_profile_id, title, verification_status')
          .eq('user_id', userId)
          .maybeSingle();
      if (wp != null) {
        // Count as enrolled worker if explicitly configured (custom title or verified/submitted)
        final title = wp['title']?.toString().trim() ?? '';
        final status = wp['verification_status']?.toString() ?? '';
        if (status == 'Verified' ||
            (title.isNotEmpty && title != 'Skilled Technician')) {
          hasWorker = true;
        }
      }
    } catch (_) {}

    return AuthorizedRoleSummary(
      hasCustomer: hasCustomer,
      hasEnterprise: hasEnterprise,
      hasWorker: hasWorker,
      customerType: customerType,
    );
  }

  /// Fetches real Business Client / Organization operational stats.
  Future<DashboardBusinessStats> getBusinessStats(String userId) async {
    final client = _client;
    if (client == null) return const DashboardBusinessStats();

    String customerType = 'Business Client';
    String? companyName;
    List<Map<String, dynamic>> projects = [];
    int openReqCount = 0;

    try {
      final cust = await client
          .from('customer_profiles')
          .select('customer_type, company_name')
          .eq('user_id', userId)
          .maybeSingle();
      if (cust != null) {
        customerType = cust['customer_type']?.toString() ?? customerType;
        companyName = cust['company_name']?.toString();
      }
    } catch (_) {}

    try {
      final projRes = await client
          .from('projects')
          .select('project_id, title, status, total_budget, created_at')
          .eq('client_id', userId)
          .order('created_at', ascending: false)
          .limit(5);
      projects = List<Map<String, dynamic>>.from(projRes);
    } catch (_) {}

    try {
      final reqRes = await client
          .from('requirements')
          .select('requirement_id')
          .eq('submitted_by', userId)
          .eq('status', 'Open');
      openReqCount = (reqRes as List).length;
    } catch (_) {}

    return DashboardBusinessStats(
      customerType: customerType,
      companyName: companyName,
      activeProjectsCount: projects
          .where((p) => (p['status']?.toString() ?? '') != 'Completed')
          .length,
      openRequirementsCount: openReqCount,
      projects: projects,
    );
  }

  /// Fetches worker metrics including completed jobs, verified reviews, earnings,
  /// active job, and live incoming requests.
  Future<DashboardWorkerStats> getWorkerStats(String userId) async {
    final client = _client;
    if (client == null) return DashboardWorkerStats.empty();
    try {
      final workerProfile = await client
          .from('worker_profiles')
          .select(
            'worker_profile_id, completed_jobs, rating_average, total_reviews, '
            'is_available, verification_status',
          )
          .eq('user_id', userId)
          .maybeSingle();

      if (workerProfile == null) {
        return DashboardWorkerStats.empty();
      }

      final wpId = workerProfile['worker_profile_id'];
      final jobs = (workerProfile['completed_jobs'] as num?)?.toInt() ?? 0;
      final totalReviews =
          (workerProfile['total_reviews'] as num?)?.toInt() ?? 0;
      final rawRating =
          (workerProfile['rating_average'] as num?)?.toDouble() ?? 0.0;
      // Strict Real Data Policy: never expose a rating when 0 verified reviews exist
      final rating = totalReviews > 0 ? rawRating : 0.0;
      final available = workerProfile['is_available'] as bool? ?? false;
      final verificationStatus =
          workerProfile['verification_status']?.toString() ?? 'Unverified';

      double earningsSum = 0.0;
      try {
        final earningsRes = await client
            .from('worker_earnings')
            .select('amount')
            .eq('worker_profile_id', wpId)
            .inFilter('status', ['Available', 'Withdrawn']);

        for (final row in earningsRes) {
          earningsSum += (row['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {}

      List<Map<String, dynamic>> requests = [];
      try {
        final requestsRes = await client
            .from('service_requests')
            .select(
              'service_request_id, agreed_price, service_notes, scheduled_at, status, '
              'requirements(location, title), users!client_id(location, full_name, phone)',
            )
            .eq('worker_profile_id', wpId)
            .eq('status', 'Requested')
            .order('scheduled_at', ascending: false)
            .limit(5);
        requests = List<Map<String, dynamic>>.from(requestsRes).map((row) {
          final normalized = Map<String, dynamic>.from(row);
          final reqMap = row['requirements'] as Map<String, dynamic>?;
          final userMap = row['users'] as Map<String, dynamic>?;
          normalized['location'] =
              reqMap?['location']?.toString() ??
              userMap?['location']?.toString() ??
              '';
          normalized['title'] =
              reqMap?['title']?.toString() ?? 'Service Request';
          normalized['client_name'] =
              userMap?['full_name']?.toString() ?? 'Client';
          normalized['client_phone'] = userMap?['phone']?.toString();
          return normalized;
        }).toList();
      } catch (e) {
        debugPrint('[DashboardRepository] incoming requests notice: $e');
      }

      Map<String, dynamic>? activeJob;
      try {
        final activeRes = await client
            .from('service_requests')
            .select(
              'service_request_id, agreed_price, service_notes, scheduled_at, status, '
              'requirements(location, title), users!client_id(location, full_name, phone)',
            )
            .eq('worker_profile_id', wpId)
            .inFilter('status', ['Accepted', 'In Progress'])
            .order('scheduled_at', ascending: false)
            .limit(1)
            .maybeSingle();
        if (activeRes != null) {
          final reqMap = activeRes['requirements'] as Map<String, dynamic>?;
          final userMap = activeRes['users'] as Map<String, dynamic>?;
          activeJob = {
            ...activeRes,
            'location':
                reqMap?['location']?.toString() ??
                userMap?['location']?.toString() ??
                '',
            'title': reqMap?['title']?.toString() ?? 'Active Job',
            'client_name': userMap?['full_name']?.toString() ?? 'Client',
            'client_phone': userMap?['phone']?.toString(),
          };
        }
      } catch (_) {}

      return DashboardWorkerStats(
        completedJobs: jobs,
        totalReviews: totalReviews,
        ratingAverage: rating,
        isAvailable: available,
        verificationStatus: verificationStatus,
        totalEarnings: earningsSum,
        incomingRequests: requests,
        activeJob: activeJob,
      );
    } catch (e) {
      debugPrint('[DashboardRepository] getWorkerStats error: $e');
      return DashboardWorkerStats.empty();
    }
  }

  /// Fetches open job requirements for customer dashboard preview.
  Future<List<JobRequirementItem>> getOpenRequirements({int limit = 5}) async {
    final client = _client;
    if (client == null) return [];
    try {
      final reqRes = await client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, '
            'urgency, requirement_type, created_at, category_id, submitted_by, '
            'categories(name, slug), users!submitted_by(full_name)',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .limit(limit);

      final List<JobRequirementItem> items = [];
      for (final row in reqRes) {
        final catMap = row['categories'] as Map<String, dynamic>?;
        final userMap = row['users'] as Map<String, dynamic>?;
        final rawCatId = row['category_id']?.toString() ?? '';
        final catName =
            catMap?['name']?.toString() ??
            (rawCatId.isNotEmpty
                ? CategoryResolver.displayName(rawCatId)
                : 'General');
        final rawUrgency = row['urgency']?.toString() ?? 'Medium';
        final urgency = rawUrgency == 'Medium' ? 'Standard' : rawUrgency;
        final reqType = (row['requirement_type']?.toString() ?? 'Simple')
            .toLowerCase();
        final budget = (row['budget'] as num?)?.toDouble() ?? 0.0;
        final createdAt = DateTime.tryParse(
          row['created_at']?.toString() ?? '',
        );

        items.add(
          JobRequirementItem(
            id: row['requirement_id']?.toString() ?? '',
            title: row['title']?.toString() ?? 'Requirement',
            category: catName,
            categoryId: rawCatId,
            description: row['description']?.toString() ?? '',
            location: row['location']?.toString() ?? '',
            budgetMin: budget,
            budgetMax: budget,
            urgency: urgency,
            postType: reqType == 'update'
                ? 'Professional Update'
                : (reqType == 'complex' ? 'Service Request' : 'Job'),
            timeAgo: createdAt != null ? Formatters.timeAgo(createdAt) : '',
            clientName: userMap?['full_name']?.toString() ?? 'SKAVIA Member',
          ),
        );
      }
      return items;
    } catch (e) {
      debugPrint('[DashboardRepository] getOpenRequirements error: $e');
      return [];
    }
  }

  /// Checks if current user has any unread notifications.
  Future<bool> hasUnreadNotifications(String userId) async {
    final client = _client;
    if (client == null) return false;
    try {
      final notifRes = await client
          .from('notifications')
          .select('notification_id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .limit(1);
      if ((notifRes as List).isNotEmpty) return true;
      final userNotifRes = await client
          .from('user_notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false)
          .limit(1);
      return (userNotifRes as List).isNotEmpty;
    } catch (e) {
      debugPrint('[DashboardRepository] hasUnreadNotifications error: $e');
      return false;
    }
  }

  /// Updates active user mode ('customer' / 'enterprise' / 'worker') in database.
  Future<void> updateActiveMode(String userId, String mode) async {
    await LocalCacheService.instance.putPersisted(
      '${AppConstants.userModeStorageKey}_$userId',
      mode,
    );
    await LocalCacheService.instance.putPersisted(
      AppConstants.userModeStorageKey,
      mode,
    );
    final client = _client;
    if (client == null || userId.isEmpty) return;
    try {
      await client
          .from('users')
          .update({'active_mode': mode})
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('[DashboardRepository] updateActiveMode error: $e');
    }
  }

  /// Toggles worker online availability. Returns `true` if persisted cleanly.
  Future<bool> updateWorkerAvailability(String userId, bool isAvailable) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client
          .from('worker_profiles')
          .update({'is_available': isAvailable})
          .eq('user_id', userId);
      return true;
    } catch (e) {
      debugPrint('[DashboardRepository] updateWorkerAvailability error: $e');
      return false;
    }
  }
}
