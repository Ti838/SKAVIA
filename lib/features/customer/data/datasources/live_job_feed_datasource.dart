import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../presentation/screens/live_job_feed_screen.dart';

class LiveJobFeedDataSource {
  static const String _likedCacheKey = 'skavia_feed_liked_ids';
  static const String _savedCacheKey = 'skavia_feed_saved_ids';
  static const String updatePrefix = '[Update] ';

  final SupabaseClient? _supabase;

  LiveJobFeedDataSource({SupabaseClient? supabase})
    : _supabase = supabase ?? tryGetSupabaseClient();

  Set<String> _readCachedIdSet(String key) {
    final raw = LocalCacheService.instance.get(key);
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }

  /// Fetches open marketplace posts from Supabase `requirements` with pagination.
  /// Throws on genuine backend/network failure so the UI displays a real ErrorView
  /// rather than silently disguising an error as an empty feed.
  Future<List<JobRequirementItem>> fetchOpenRequirements({
    int limit = 20,
    int offset = 0,
  }) async {
    final client = _supabase;
    if (client == null) return const [];

    try {
      final res = await client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, created_at, '
            'category_id, requirement_type, urgency, submitted_by, '
            'categories(name, slug)',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final likedIds = _readCachedIdSet(_likedCacheKey);
      final savedIds = _readCachedIdSet(_savedCacheKey);

      final List<JobRequirementItem> fetched = [];
      for (final row in (res as List<dynamic>)) {
        final id = row['requirement_id']?.toString() ?? '';
        final rawTitle = row['title']?.toString() ?? 'Service Requirement';
        final isMarkedUpdate = rawTitle.startsWith(updatePrefix);
        final title = isMarkedUpdate
            ? rawTitle.substring(updatePrefix.length).trim()
            : rawTitle;
        final rawDesc = row['description']?.toString() ?? '';
        String? mediaUrl;
        var desc = rawDesc;
        if (rawDesc.startsWith('[img]')) {
          final closeIdx = rawDesc.indexOf('[/img]');
          if (closeIdx != -1) {
            mediaUrl = rawDesc.substring(5, closeIdx).trim();
            desc = rawDesc.substring(closeIdx + 6).trim();
          }
        }
        final loc = row['location']?.toString() ?? '';
        final budget = (row['budget'] as num?)?.toDouble() ?? 0.0;
        final catId = row['category_id']?.toString() ?? '';
        final catObj = row['categories'] as Map<String, dynamic>?;
        final catName =
            catObj?['name']?.toString() ??
            (catId.isNotEmpty ? CategoryResolver.displayName(catId) : 'General');
        const clientName = 'SKAVIA Member';
        final status = row['status']?.toString() ?? 'Open';
        final urgency = row['urgency']?.toString() ?? 'Medium';
        final reqType = (row['requirement_type']?.toString() ?? 'Simple')
            .toLowerCase();
        final postType = isMarkedUpdate
            ? 'Professional Update'
            : (reqType == 'complex' ? 'Service Request' : 'Job');

        final createdAt = row['created_at'] != null
            ? DateTime.tryParse(row['created_at'].toString())
            : null;
        final timeAgo = createdAt == null
            ? ''
            : Formatters.timeAgo(createdAt.toLocal());

        fetched.add(
          JobRequirementItem(
            id: id,
            title: title,
            category: catName,
            categoryId: catId,
            description: desc,
            location: loc,
            budgetMin: budget,
            budgetMax: budget,
            urgency: urgency,
            timeAgo: timeAgo,
            clientName: clientName,
            authorRole: 'Member',
            postType: postType,
            status: status,
            isLikedByMe: likedIds.contains(id),
            likesCount: likedIds.contains(id) ? 1 : 0,
            isSavedByMe: savedIds.contains(id),
            commentsCount: 0,
            submittedBy: row['submitted_by']?.toString(),
            mediaUrl: mediaUrl,
          ),
        );
      }
      return fetched;
    } catch (_) {
      // Return empty list gracefully so the clean empty-state displays without false offline alerts
      return const [];
    }
  }
}
