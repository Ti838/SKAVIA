import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import '../../../../shared/widgets/user_avatar.dart';

/// Featured Trade Specialists Section backed strictly by live Supabase `worker_profiles`.
/// Zero fabricated ratings, badges, or demo profiles.
class FeaturedWorkersSection extends StatefulWidget {
  final VoidCallback? onSeeAll;

  const FeaturedWorkersSection({super.key, this.onSeeAll});

  @override
  State<FeaturedWorkersSection> createState() => _FeaturedWorkersSectionState();
}

class _FeaturedWorkersSectionState extends State<FeaturedWorkersSection> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _workers = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedWorkers();
  }

  Future<void> _loadFeaturedWorkers() async {
    final client = tryGetSupabaseClient();
    if (client == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Query RLS-safe public marketplace projection first (avoids cross-user
      // public.users RLS blocks), with fallback to worker_profiles.
      List<dynamic> response;
      try {
        response = await client
            .from(DatabaseTables.marketplacePublicProfiles)
            .select(
              'worker_profile_id, user_id, display_name, avatar_url, title, '
              'location, expected_rate, rating_average, completed_jobs, '
              'verification_status',
            )
            .eq('is_available', true)
            .order('completed_jobs', ascending: false)
            .limit(3);
      } catch (_) {
        response = await client
            .from(DatabaseTables.workerProfiles)
            .select(
              'worker_profile_id, user_id, title, location, expected_rate, '
              'rating_average, total_reviews, completed_jobs, verification_status, '
              'users(full_name, avatar_url)',
            )
            .eq('is_available', true)
            .order('completed_jobs', ascending: false)
            .limit(3);
      }

      if (mounted) {
        setState(() {
          _workers = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.homeAvailableSpecialists,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed:
                  widget.onSeeAll ??
                  () => Navigator.pushNamed(context, AppRoutes.teamDiscovery),
              child: Text(l10n.commonSeeAll),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          Container(
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_hasError)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_off_rounded, color: tokens.error, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.homeCouldNotLoadSpecialists,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _loadFeaturedWorkers,
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          )
        else if (_workers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.engineering_outlined,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.homeNoSpecialistsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeNoSpecialistsSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
          )
        else
          ..._workers.map((worker) => _buildWorkerCard(context, worker, isBn)),
      ],
    );
  }

  Widget _buildWorkerCard(
    BuildContext context,
    Map<String, dynamic> worker,
    bool isBn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final tokens = context.skavia;
    final userMap = worker['users'] as Map<String, dynamic>?;
    final rawName =
        (worker['display_name'] as String?)?.trim().isNotEmpty == true
        ? (worker['display_name'] as String).trim()
        : (userMap?['full_name'] as String?)?.trim() ?? '';
    final name = rawName.isNotEmpty
        ? rawName
        : (isBn ? 'দক্ষ কারিগর' : 'Specialist');
    final avatarUrl =
        (worker['avatar_url'] as String?)?.trim().isNotEmpty == true
        ? (worker['avatar_url'] as String).trim()
        : (userMap?['avatar_url'] as String?)?.trim() ?? '';
    final title = (worker['title'] as String?)?.trim().isNotEmpty == true
        ? (worker['title'] as String).trim()
        : (isBn ? 'টেকনিশিয়ান' : 'Technician');
    final location = (worker['location'] as String?)?.trim() ?? '';
    final expectedRate = (worker['expected_rate'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (worker['total_reviews'] as num?)?.toInt() ?? 0;
    final rawRating = (worker['rating_average'] as num?)?.toDouble() ?? 0.0;
    final rating = totalReviews > 0 ? rawRating : 0.0;
    final completedJobs = (worker['completed_jobs'] as num?)?.toInt() ?? 0;
    final isVerified =
        (worker['verification_status'] as String?)?.toLowerCase() == 'verified';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: tokens.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(color: tokens.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.workerProfile,
            arguments: {
              'workerProfileId': worker['worker_profile_id']?.toString(),
              'name': name,
              'title': title,
              'rating': rating,
              'reviewsCount': totalReviews,
              'completedJobs': completedJobs,
              'location': location.isNotEmpty ? location : 'Dhaka, Bangladesh',
              'hourlyRate': expectedRate > 0
                  ? '৳ ${expectedRate.toStringAsFixed(0)}/hr'
                  : '৳ 0/hr',
              'avatarUrl': avatarUrl,
              'isVerified': isVerified,
            },
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
                  name: name,
                  radius: 22,
                  isVerified: isVerified,
                ),
                const SizedBox(width: 12),
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
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isVerified)
                            SkaviaBadge(
                              label: l10n.commonVerified,
                              icon: Icons.verified_rounded,
                              tone: SkaviaBadgeTone.verified,
                              compact: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.isNotEmpty ? '$title · $location' : title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (totalReviews > 0) ...[
                            Icon(
                              Icons.star_rounded,
                              color: tokens.warning,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${rating.toStringAsFixed(1)} ($totalReviews)',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              completedJobs > 0
                                  ? l10n.workerJobsCompletedCount(completedJobs)
                                  : l10n.workerNewlyRegistered,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: tokens.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
