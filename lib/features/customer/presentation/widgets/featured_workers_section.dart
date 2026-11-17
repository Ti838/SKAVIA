import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';

/// Screen 4 Featured Trade Specialist Section aligned with SRS Section 3.1.B & 3.1.C
/// Genuine dynamic data loading from Supabase with zero fake profiles.
class FeaturedWorkersSection extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const FeaturedWorkersSection({super.key, this.onSeeAll});

  @override
  State<FeaturedWorkersSection> createState() => _FeaturedWorkersSectionState();
}

class _FeaturedWorkersSectionState extends State<FeaturedWorkersSection> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedWorkers();
  }

  Future<void> _loadFeaturedWorkers() async {
    final client = tryGetSupabaseClient();
    if (client == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await client
          .from(DatabaseTables.workerProfiles)
          .select(
            'user_id, title, working_area, rating_average, total_ratings, completed_jobs, verification_status, users(full_name, avatar_url)',
          )
          .order('completed_jobs', ascending: false)
          .limit(3);

      if (mounted) {
        setState(() {
          _workers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = AppLanguageService.isBengali;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isBn ? 'শীর্ষ দক্ষ কারিগর' : 'Featured Specialists',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap:
                  widget.onSeeAll ??
                  () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
              child: Text(
                AppLanguageService.tr('see_all'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorScheme.primary
                      : AppColors.primaryRoyal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          Container(
            height: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_workers.isEmpty)
          _buildEmptySpecialistsState(context, isBn, colorScheme)
        else
          ..._workers.map((worker) => _buildWorkerCard(context, worker, isBn, colorScheme)),
      ],
    );
  }

  Widget _buildEmptySpecialistsState(
    BuildContext context,
    bool isBn,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.engineering_outlined,
              size: 28,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isBn ? 'এখনও কোনো কারিগর নেই' : 'No Specialists Yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn
                ? 'যাচাইকৃত পেশাদাররা প্ল্যাটফর্মে যুক্ত হলে এখানে প্রদর্শিত হবে।'
                : 'Verified professionals will appear here once registered.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(
    BuildContext context,
    Map<String, dynamic> worker,
    bool isBn,
    ColorScheme colorScheme,
  ) {
    final userMap = worker['users'] as Map<String, dynamic>?;
    final name = (userMap?['full_name'] as String?)?.trim() ?? (isBn ? 'কারিগর' : 'Specialist');
    final title = (worker['title'] as String?)?.trim() ?? (isBn ? 'দক্ষ কারিগর' : 'Certified Specialist');
    final location = (worker['working_area'] as String?)?.trim() ?? 'Dhaka';
    final rating = (worker['rating_average'] as num?)?.toDouble() ?? 0.0;
    final totalRatings = (worker['total_ratings'] as num?)?.toInt() ?? 0;
    final completedJobs = (worker['completed_jobs'] as num?)?.toInt() ?? 0;
    final isVerified = (worker['verification_status'] as String?) == 'verified';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.workerProfile,
          arguments: {
            'name': name,
            'title': title,
            'rating': rating,
            'reviewsCount': totalRatings,
            'completedJobs': completedJobs,
            'location': location,
          },
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.surfaceContainerHighest,
                child: const Icon(
                  Icons.engineering_rounded,
                  color: AppColors.primarySky,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.successGreen,
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isBn ? 'যাচাইকৃত' : 'Verified',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.successGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$title • $location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rating > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFF59E0B),
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            rating > 0
                                ? (isBn
                                    ? '($totalRatings রিভিউ • $completedJobs সম্পন্ন)'
                                    : '($totalRatings reviews • $completedJobs jobs)')
                                : (isBn ? 'নতুন কারিগর' : 'New Specialist'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
