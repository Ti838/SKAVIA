import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/match_result_entity.dart';
import '../../domain/services/matching_scoring_engine.dart';

/// State Controller managing candidate matches evaluation and ranking
/// for Customer & Business Client requirements (SRS Section 3.1.G).
/// Queries ONLY real registered workers from the Supabase database.
class MatchingController extends ChangeNotifier {
  List<MatchResultEntity> _matches = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentRequirementId;

  List<MatchResultEntity> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get currentRequirementId => _currentRequirementId;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Evaluates and ranks genuine candidate workers from the database for a given requirement.
  Future<void> findMatches({
    required String requirementId,
    required String requirementZone,
    required double clientBudget,
    String? categoryId,
    String? categoryName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentRequirementId = requirementId;
    _matches = [];
    notifyListeners();

    try {
      final List<Map<String, dynamic>> rawWorkers = [];

      final client = _supabase;
      if (client != null) {
        List<dynamic> response;
        if (categoryId == null || categoryId.isEmpty) {
          try {
            response = await client
                .from('marketplace_public_profiles')
                .select(
                  'worker_profile_id, user_id, display_name, avatar_url, title, '
                  'bio, location, expected_rate, verification_status, '
                  'rating_average, completed_jobs, is_available',
                )
                .eq('is_available', true)
                .limit(50);
          } catch (_) {
            response = await client
                .from('worker_profiles')
                .select(
                  'worker_profile_id, user_id, title, bio, location, working_area, '
                  'expected_rate, verification_status, rating_average, total_reviews, '
                  'completed_jobs, is_available, users ( full_name, avatar_url )',
                )
                .eq('is_available', true)
                .limit(50);
          }
        } else {
          response = await client
              .from('worker_profiles')
              .select(
                'worker_profile_id, user_id, title, bio, location, working_area, '
                'expected_rate, verification_status, rating_average, total_reviews, '
                'completed_jobs, is_available, users ( full_name, avatar_url )',
              )
              .eq('is_available', true)
              .eq('category_id', categoryId)
              .limit(50);
        }

        if (response.isNotEmpty) {
          for (final row in response) {
            final usersData = row['users'] as Map<String, dynamic>?;
            final totalReviews = (row['total_reviews'] as num?)?.toInt() ?? 0;
            final rawRating =
                (row['rating_average'] as num?)?.toDouble() ?? 0.0;
            final verificationStatus =
                row['verification_status']?.toString() ?? 'Unverified';
            final fullName =
                (row['display_name'] as String?)?.trim().isNotEmpty == true
                ? (row['display_name'] as String).trim()
                : (usersData?['full_name']?.toString() ?? 'Worker');
            final avatarUrl =
                (row['avatar_url'] as String?)?.trim().isNotEmpty == true
                ? (row['avatar_url'] as String).trim()
                : usersData?['avatar_url'];
            rawWorkers.add({
              'worker_profile_id': row['worker_profile_id'],
              'user_id': row['user_id'],
              'full_name': fullName,
              'avatar_url': avatarUrl,
              'title': row['title'] ?? 'Worker',
              'location': row['location'] ?? row['working_area'] ?? 'Dhaka',
              'expected_rate':
                  (row['expected_rate'] as num?)?.toDouble() ?? 0.0,
              'verification_status': verificationStatus,
              'rating_average': totalReviews > 0 ? rawRating : 0.0,
              'total_reviews': totalReviews,
              'completed_jobs': (row['completed_jobs'] as num?)?.toInt() ?? 0,
              'is_verified': verificationStatus.toLowerCase() == 'verified',
            });
          }
        }
      }

      // If no workers are registered in this category/zone, do NOT fabricate data
      if (rawWorkers.isNotEmpty) {
        // Run algorithmic matching engine on real workers
        _matches = MatchingScoringEngine.rankCandidates(
          requirementId: requirementId,
          requirementZone: requirementZone,
          clientBudget: clientBudget,
          rawWorkers: rawWorkers,
        );

        // Persist match audit log to Supabase
        if (client != null && _matches.isNotEmpty) {
          _persistMatchesSilently(
            client,
            requirementId,
            _matches.take(5).toList(),
          );
        }
      } else {
        _matches = [];
      }
    } catch (e) {
      _errorMessage = 'Error retrieving matching specialists: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _persistMatchesSilently(
    SupabaseClient client,
    String reqId,
    List<MatchResultEntity> topMatches,
  ) async {
    try {
      final records = topMatches
          .map(
            (m) => {
              'requirement_id': reqId,
              'worker_profile_id': m.workerProfileId,
              'match_score': m.matchScore,
              'rank_position': m.rankPosition,
              'skill_score': m.skillScore,
              'distance_score': m.distanceScore,
              'rating_score': m.ratingScore,
              'rate_score': m.rateScore,
            },
          )
          .toList();
      await client.from('match_results').insert(records);
    } catch (_) {
      // Best-effort audit logging
    }
  }
}
