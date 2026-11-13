import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/category_resolver.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../presentation/screens/live_job_feed_screen.dart';

class LiveJobFeedDataSource {
  static const String _likedCacheKey = 'skavia_feed_liked_ids';
  static const String _savedCacheKey = 'skavia_feed_saved_ids';

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

  Future<List<JobRequirementItem>> fetchOpenRequirements() async {
    final client = _supabase;
    if (client == null) return const [];

    try {
      final res = await client
          .from('requirements')
          .select(
            'requirement_id, title, description, location, budget, status, created_at, category_id, requirement_type, urgency, submitted_by, categories(name, slug), users!submitted_by(full_name)',
          )
          .eq('status', 'Open')
          .order('created_at', ascending: false)
          .limit(30);

      final likedIds = _readCachedIdSet(_likedCacheKey);
      final savedIds = _readCachedIdSet(_savedCacheKey);

      final List<JobRequirementItem> fetched = [];
      for (final row in (res as List<dynamic>)) {
        final id = row['requirement_id']?.toString() ?? 'req';
        final title = row['title']?.toString() ?? 'Service Requirement';
        final desc = row['description']?.toString() ?? '';
        final loc = row['location']?.toString() ?? 'Dhaka, Bangladesh';
        final budget = (row['budget'] as num?)?.toDouble() ?? 1500.0;
        final catId = row['category_id']?.toString() ?? 'cat_electrical';
        final catObj = row['categories'] as Map<String, dynamic>?;
        final clientObj = row['users'] as Map<String, dynamic>?;
        final catName =
            catObj?['name']?.toString() ?? CategoryResolver.displayName(catId);
        final clientName =
            clientObj?['full_name']?.toString() ?? 'Verified Client';
        final status = row['status']?.toString() ?? 'Open';
        final urgency = row['urgency']?.toString() ?? 'Medium';
        final reqType = row['requirement_type']?.toString() ?? 'Simple';
        final postType =
            reqType.toLowerCase() == 'complex' ? 'Service Request' : 'Job';

        final createdAt = row['created_at'] != null
            ? DateTime.tryParse(row['created_at'].toString())
            : null;
        final timeAgo = createdAt == null
            ? 'Recently'
            : Formatters.timeAgo(createdAt.toLocal());

        fetched.add(
          JobRequirementItem(
            id: id,
            title: title,
            category: catName,
            categoryId: catId,
            description: desc,
            location: loc,
            budgetMin: budget * 0.9,
            budgetMax: budget * 1.2,
            urgency: urgency,
            timeAgo: timeAgo,
            clientName: clientName,
            authorRole: 'Client',
            postType: postType,
            status: status,
            isLikedByMe: likedIds.contains(id),
            likesCount: likedIds.contains(id) ? 1 : 0,
            isSavedByMe: savedIds.contains(id),
            commentsCount: 0,
            submittedBy: row['submitted_by']?.toString(),
          ),
        );
      }
      return fetched;
    } catch (e) {
      debugPrint('[LiveJobFeedDataSource] Fetch error: $e');
      return const [];
    }
  }
}

