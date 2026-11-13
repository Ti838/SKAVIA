import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/review_remote_datasource.dart';
import '../../data/models/review_model.dart';
import '../widgets/review_item_card.dart';

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
    _displayName = widget.workerName ?? 'Specialist';
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
      final client = tryGetSupabaseClient();
      if (client == null) {
        return;
      }

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
            wpId = profile['worker_profile_id']?.toString();
            name = user.displayName ?? 'My Profile';
            _completedJobs = (profile['completed_jobs'] as num?)?.toInt() ?? 0;
            _averageRating =
                (profile['rating_average'] as num?)?.toDouble() ?? 5.0;
          }
        }
      }

      if (wpId != null) {
        _displayName = name;

        final rep = await _reviewDataSource.getWorkerReputation(wpId);
        if (rep != null) {
          _averageRating = rep.overallScore;
          _completedJobs = rep.completedJobs > 0
              ? rep.completedJobs
              : _completedJobs;
          _totalRatings = rep.totalRatings;
          _badgeLevel = rep.badgeLevel;
        }

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
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Reputation & Ratings',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: _loadReputationData,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Reputation Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySky.withValues(
                                          alpha: 0.25,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primarySky
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        _badgeLevel,
                                        style: const TextStyle(
                                          color: Color(0xFF93C5FD),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.warningAmber,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Colors.white12),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatColumn(
                                  '$_completedJobs',
                                  'Completed Jobs',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.white12,
                              ),
                              Expanded(
                                child: _buildStatColumn(
                                  '$_totalRatings',
                                  'Total Ratings',
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: Colors.white12,
                              ),
                              Expanded(
                                child: _buildStatColumn(
                                  '100%',
                                  'Verified',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Verified Client Reviews',
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: tokens.softBlueBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_reviews.length} Reviews',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: tokens.brandAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (_reviews.isEmpty)
                      const EmptyReviewsState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
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
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
