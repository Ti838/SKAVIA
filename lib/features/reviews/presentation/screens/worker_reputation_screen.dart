import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/models/review_model.dart';
import '../widgets/review_item_card.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class WorkerReputationScreen extends StatefulWidget {
  final String? workerProfileId;
  final String? workerName;

  const WorkerReputationScreen({
    super.key,
    this.workerProfileId,
    this.workerName,
  });

  @override
  State<WorkerReputationScreen> createState() => _WorkerReputationScreenState();
}

class _WorkerReputationScreenState extends State<WorkerReputationScreen> {
  final ReviewRemoteDataSource _reviewDataSource = ReviewRemoteDataSource();
  final AuthController _authController = AuthController();

  bool _isLoading = true;
  String _displayName = 'Specialist';
  double _averageRating = 5.0;
  int _completedJobs = 0;
  int _totalRatings = 0;
  String _badgeLevel = 'Verified Specialist';
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReputationData();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _loadReputationData() async {
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;
      String? wpId = widget.workerProfileId;
      String name = widget.workerName ?? 'Specialist';

      if (wpId == null) {
        final user = _authController.user;
        if (user != null) {
          final profile = await client
              .from('worker_profiles')
              .select('worker_profile_id, completed_jobs, rating_average')
              .eq('user_id', user.uid)
              .maybeSingle();

          if (profile != null) {
            wpId = profile['worker_profile_id'];
            name = user.displayName ?? 'My Profile';
            _completedJobs = (profile['completed_jobs'] as num?)?.toInt() ?? 0;
            _averageRating =
                (profile['rating_average'] as num?)?.toDouble() ?? 5.0;
          }
        }
      }

      if (wpId != null) {
        _displayName = name;

        // Fetch reputation
        final rep = await _reviewDataSource.getWorkerReputation(wpId);
        if (rep != null) {
          _averageRating = rep.overallScore;
          _completedJobs = rep.completedJobs > 0
              ? rep.completedJobs
              : _completedJobs;
          _totalRatings = rep.totalRatings;
          _badgeLevel = rep.badgeLevel;
        }

        // Fetch reviews
        final revs = await _reviewDataSource.getWorkerReviews(wpId);
        _reviews = revs;
        _totalRatings = revs.isNotEmpty ? revs.length : _totalRatings;
      }
    } catch (e) {
      debugPrint('[WorkerReputationScreen load Error]: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.canvasBlue,
      appBar: AppBar(
        backgroundColor: AppColors.canvasBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reputation & Ratings',
          style: const TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadReputationData,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimensions.roundedSheet,
          ),
          child: ClipRRect(
            borderRadius: AppDimensions.roundedSheet,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Reputation Card
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _displayName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySky
                                              .withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primarySky
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        child: Text(
                                          _badgeLevel,
                                          style: const TextStyle(
                                            color: AppColors.primarySky,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Score badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star_rounded,
                                          color: AppColors.warningAmber,
                                          size: 26,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _averageRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Divider(color: Colors.white12),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    '$_completedJobs',
                                    'Completed Jobs',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: Colors.white12,
                                  ),
                                  _buildStatColumn(
                                    '$_totalRatings',
                                    'Total Ratings',
                                  ),
                                  Container(
                                    width: 1,
                                    height: 32,
                                    color: Colors.white12,
                                  ),
                                  _buildStatColumn('100%', 'Authenticity'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Section Title: Verified Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Verified Client Reviews',
                              style: TextStyle(
                                fontFamily: AppTypography.headingFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBlueTint,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_reviews.length} Reviews',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primarySky,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Reviews list or honest empty state
                        if (_reviews.isEmpty)
                          const EmptyReviewsState()
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              return ReviewItemCard(
                                review: _reviews[index],
                                dateFormat: dateFormat,
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
