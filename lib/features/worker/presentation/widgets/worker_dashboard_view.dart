import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';
import 'worker_incoming_requests_list.dart';
import 'worker_stat_cards.dart';
import 'worker_weekly_schedule_selector.dart';

export 'worker_incoming_requests_list.dart';
export 'worker_stat_cards.dart';
export 'worker_weekly_schedule_selector.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Weekly Day Selector Pill Bar (Reference Screen 2)
        WorkerWeeklyScheduleSelector(
          selectedDay: _selectedWorkDay,
          onSelectDay: (day) => setState(() => _selectedWorkDay = day),
        ),
        const SizedBox(height: 20),

        // 2. Online / Offline Availability Radar Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isWorkerAvailable
                ? AppColors.successGreen.withValues(alpha: 0.15)
                : (isDark
                      ? colorScheme.surfaceContainerHighest
                      : AppColors.sheetSurfaceSubtle),
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
                        maxLines: 2,
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

        // 3. Dual Stat Cards (Earnings & Jobs)
        WorkerStatCards(
          workerEarnings: widget.workerEarnings,
          workerCompletedJobs: widget.workerCompletedJobs,
          workerRating: widget.workerRating,
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
              color: isDark
                  ? colorScheme.surfaceContainerHighest
                  : AppColors.primarySky.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? colorScheme.outlineVariant
                    : AppColors.primarySky.withValues(alpha: 0.3),
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
                    color: isDark
                        ? colorScheme.primary
                        : AppColors.primaryRoyal,
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

        // 5. Incoming Job Requests Section
        WorkerIncomingRequestsList(liveJobRequests: widget.liveJobRequests),
      ],
    );
  }
}
