import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/app_language_service.dart';

/// Worker Mode Dashboard View (matching Reference Screen 2 architecture)
class WorkerDashboardView extends StatefulWidget {
  final double workerEarnings;
  final int workerCompletedJobs;
  final double workerRating;
  final bool isWorkerAvailable;
  final String locationZone;
  final List<Map<String, dynamic>> liveJobRequests;
  final ValueChanged<bool> onToggleAvailability;

  const WorkerDashboardView({
    super.key,
    required this.workerEarnings,
    required this.workerCompletedJobs,
    required this.workerRating,
    required this.isWorkerAvailable,
    required this.locationZone,
    required this.liveJobRequests,
    required this.onToggleAvailability,
  });

  @override
  State<WorkerDashboardView> createState() => _WorkerDashboardViewState();
}

class _WorkerDashboardViewState extends State<WorkerDashboardView> {
  String _selectedWorkDay = 'mo';

  Widget _buildDayPill(String day, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedWorkDay == day;
    final dayLabel = AppLanguageService.tr('days_$day');
    return GestureDetector(
      onTap: () => setState(() => _selectedWorkDay = day),
      child: Container(
        width: 40,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? colorScheme.primary : AppColors.primarySky)
              : (isDark ? colorScheme.surfaceContainerHighest : AppColors.sheetSurfaceSubtle),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? (isDark ? colorScheme.primary : AppColors.primarySky)
                : colorScheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark ? colorScheme.onSurfaceVariant : AppColors.textMedium),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Weekly Day Selector Pill Bar (Reference Screen 2)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDayPill('su', context),
            _buildDayPill('mo', context),
            _buildDayPill('tu', context),
            _buildDayPill('we', context),
            _buildDayPill('th', context),
            _buildDayPill('fr', context),
            _buildDayPill('sa', context),
          ],
        ),
        const SizedBox(height: 20),

        // 2. Online / Offline Availability Radar Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isWorkerAvailable
                ? AppColors.successGreen.withValues(alpha: 0.15)
                : (isDark ? colorScheme.surfaceContainerHighest : AppColors.sheetSurfaceSubtle),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isWorkerAvailable
                  ? AppColors.successGreen.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: widget.isWorkerAvailable
                            ? AppColors.successGreen
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isWorkerAvailable
                            ? (AppLanguageService.isBengali
                                ? '${widget.locationZone} এলাকায় কাজের জন্য প্রস্তুত'
                                : 'Available for Jobs in ${widget.locationZone}')
                            : AppLanguageService.tr('offline'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: widget.isWorkerAvailable,
                activeTrackColor: AppColors.successGreen,
                onChanged: widget.onToggleAvailability,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. Dual Stat Cards (Reference Screen 2: Peach Earnings & Blue Jobs)
        Row(
          children: [
            // Peach Earnings Card
            Expanded(
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.workerEarnings),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surfaceContainerHighest : AppColors.cardPeachTint,
                    borderRadius: BorderRadius.circular(AppDimensions.radius20),
                    border: Border.all(
                      color: isDark ? colorScheme.outlineVariant : AppColors.accentPeach.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguageService.tr('earnings'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.accentCoral,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '৳ ${widget.workerEarnings.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.workerEarnings > 0
                            ? AppLanguageService.tr('verified_balance')
                            : AppLanguageService.tr('zero_balance'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.workerEarnings > 0
                              ? AppColors.successGreen
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Blue Jobs Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? colorScheme.surfaceContainerHighest : AppColors.cardBlueTint,
                  borderRadius: BorderRadius.circular(AppDimensions.radius20),
                  border: Border.all(
                    color: isDark ? colorScheme.outlineVariant : AppColors.primarySky.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLanguageService.tr('completed_jobs'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primarySky,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.workerCompletedJobs} ${AppLanguageService.tr('jobs')}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accentPeach,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${AppLanguageService.tr('rating')} ${widget.workerRating.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 4. Worker KYC & Verification Action Card (SRS Section 3.1.B & 3.1.R)
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.workerProfile,
            arguments: {'isEdit': true},
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest : AppColors.primarySky.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? colorScheme.outlineVariant : AppColors.primarySky.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageService.tr('worker_verification_bio'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        AppLanguageService.tr('worker_verification_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? colorScheme.primary : AppColors.primaryRoyal,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        // 5. Incoming Job Requests Section Title & Open Jobs Feed Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLanguageService.tr('incoming_requests'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.liveJobFeed),
              child: Row(
                children: [
                  Text(
                    AppLanguageService.tr('open_jobs_feed'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? colorScheme.primary : AppColors.primarySky,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: isDark ? colorScheme.primary : AppColors.primarySky,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (widget.liveJobRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? colorScheme.surfaceContainerHighest : AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.radar_rounded,
                  color: isDark ? colorScheme.primary : AppColors.primarySky,
                  size: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguageService.tr('no_pending_requests'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLanguageService.tr('radar_alert_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.liveJobRequests.map((req) {
            final price = (req['agreed_price'] as num?)?.toDouble() ?? 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surfaceContainerHighest : AppColors.sheetSurfaceSubtle,
                borderRadius: BorderRadius.circular(AppDimensions.radius16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surface : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: AppColors.accentCoral,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incoming Service Request',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Agreed Fare: ৳ ${price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySky,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.incomingRequests,
                    ),
                    child: const Text(
                      'Review',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
