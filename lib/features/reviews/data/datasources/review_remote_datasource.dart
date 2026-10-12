import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../data/tables/database_tables.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final SupabaseClient _supabase;

  ReviewRemoteDataSource({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Submits an authentic review and recalculates worker reputation metrics (SRS 3.1.M)
  Future<bool> submitReview({
    required String workerProfileId,
    required String clientId,
    required int rating,
    String? comment,
    String? serviceRequestId,
    String? projectId,
  }) async {
    final now = DateTime.now().toIso8601String();
    try {
      // 1. Insert review into reviews table
      await _supabase.from(DatabaseTables.reviews).insert({
        'worker_profile_id': workerProfileId,
        'client_id': clientId,
        'rating': rating,
        'comment': comment?.trim(),
        'service_request_id': ?serviceRequestId,
        'project_id': ?projectId,
        'created_at': now,
      });

      // 2. Fetch all reviews for this worker to calculate accurate real average
      final allReviews = await _supabase
          .from(DatabaseTables.reviews)
          .select('rating')
          .eq('worker_profile_id', workerProfileId);

      int totalRatings = (allReviews as List).length;
      double sum = 0.0;
      for (final r in allReviews) {
        sum += (r['rating'] as num?)?.toDouble() ?? 5.0;
      }
      final double averageRating = totalRatings > 0
          ? (sum / totalRatings)
          : 5.0;

      // 3. Update worker_profiles table
      await _supabase
          .from(DatabaseTables.workerProfiles)
          .update({
            'rating_average': double.parse(averageRating.toStringAsFixed(2)),
          })
          .eq('worker_profile_id', workerProfileId);

      // 4. Update or Upsert into reputations table
      String badge = 'Verified Specialist';
      if (averageRating >= 4.8 && totalRatings >= 5) {
        badge = 'Top Rated Elite';
      } else if (averageRating >= 4.5) {
        badge = 'Top Rated Specialist';
      }

      await _supabase.from(DatabaseTables.reputations).upsert({
        'worker_profile_id': workerProfileId,
        'overall_score': double.parse(averageRating.toStringAsFixed(2)),
        'total_ratings': totalRatings,
        'badge_level': badge,
        'updated_at': now,
      }, onConflict: 'worker_profile_id');

      return true;
    } catch (e) {
      debugPrint('[ReviewRemoteDataSource submitReview Error]: $e');
      rethrow;
    }
  }

  /// Fetches real reviews for a specific worker profile
  Future<List<ReviewModel>> getWorkerReviews(String workerProfileId) async {
    try {
      final res = await _supabase
          .from(DatabaseTables.reviews)
          .select('''
            review_id,
            worker_profile_id,
            service_request_id,
            project_id,
            client_id,
            rating,
            comment,
            created_at
          ''')
          .eq('worker_profile_id', workerProfileId)
          .order('created_at', ascending: false);

      final List<ReviewModel> reviews = [];

      for (final raw in (res as List)) {
        final map = Map<String, dynamic>.from(raw as Map);
        final clientId = map['client_id'] as String? ?? '';

        String clientName = 'Verified Client';
        String? clientAvatar;

        try {
          final userRes = await _supabase
              .from(DatabaseTables.users)
              .select('full_name, avatar_url')
              .eq('user_id', clientId)
              .maybeSingle();

          if (userRes != null) {
            clientName = userRes['full_name'] as String? ?? 'Verified Client';
            clientAvatar = userRes['avatar_url'] as String?;
          }
        } catch (_) {}

        map['client_name'] = clientName;
        map['client_avatar'] = clientAvatar;

        reviews.add(ReviewModel.fromJson(map));
      }

      return reviews;
    } catch (e) {
      debugPrint('[ReviewRemoteDataSource getWorkerReviews Error]: $e');
      return [];
    }
  }

  /// Fetches reputation scorecard for a worker
  Future<ReputationModel?> getWorkerReputation(String workerProfileId) async {
    try {
      final res = await _supabase
          .from(DatabaseTables.reputations)
          .select()
          .eq('worker_profile_id', workerProfileId)
          .maybeSingle();

      if (res != null) {
        return ReputationModel.fromJson(Map<String, dynamic>.from(res));
      }
    } catch (e) {
      debugPrint('[ReviewRemoteDataSource getWorkerReputation Error]: $e');
    }
    return null;
  }
}
