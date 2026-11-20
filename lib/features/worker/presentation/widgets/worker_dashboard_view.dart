import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/job_otp_util.dart';
import '../../../../shared/motion/sakuga_toggle.dart';
import '../../../../shared/widgets/skavia_badge.dart';
import 'worker_incoming_requests_list.dart';
import 'worker_stat_cards.dart';

export 'worker_incoming_requests_list.dart';
export 'worker_stat_cards.dart';
export 'worker_weekly_schedule_selector.dart';

/// Role-specific Worker Dashboard View.
/// Strictly reflects real DB availability, earnings, active job, KYC state,
/// and incoming requests with zero fabricated metrics.
class WorkerDashboardView extends StatefulWidget {
  final double workerEarnings;
  final int workerCompletedJobs;
  final double workerRating;
  final bool isWorkerAvailable;
  final String locationZone;
  final List<Map<String, dynamic>> liveJobRequests;
  final ValueChanged<bool> onToggleAvailability;
  final String verificationStatus;
  final Map<String, dynamic>? activeJob;

  const WorkerDashboardView({
    super.key,
    required this.workerEarnings,
    required this.workerCompletedJobs,
    required this.workerRating,
    required this.isWorkerAvailable,
    required this.locationZone,
    required this.liveJobRequests,
    required this.onToggleAvailability,
    this.verificationStatus = 'Unverified',
    this.activeJob,
  });

  @override
  State<WorkerDashboardView> createState() => _WorkerDashboardViewState();
}

class _WorkerDashboardViewState extends State<WorkerDashboardView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;
    final normVerif = widget.verificationStatus.trim().toLowerCase();

    final String verifTitle;
    final String verifSubtitle;
    final SkaviaBadgeTone verifTone;
    if (normVerif == 'verified') {
      verifTitle = l10n.workerVerifiedTitle;
      verifSubtitle = l10n.workerVerifiedDesc;
      verifTone = SkaviaBadgeTone.verified;
    } else if (normVerif == 'pending') {
      verifTitle = l10n.workerPendingTitle;
      verifSubtitle = l10n.workerPendingDesc;
      verifTone = SkaviaBadgeTone.warning;
    } else if (normVerif == 'rejected') {
      verifTitle = l10n.workerRejectedTitle;
      verifSubtitle = l10n.workerRejectedDesc;
      verifTone = SkaviaBadgeTone.error;
    } else {
      verifTitle = l10n.workerVerificationTitle;
      verifSubtitle = l10n.workerVerificationDesc;
      verifTone = SkaviaBadgeTone.primary;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Online / Offline Availability Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isWorkerAvailable ? tokens.softMintBg : tokens.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: widget.isWorkerAvailable
                  ? tokens.tealAccent.withValues(alpha: 0.45)
                  : tokens.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: widget.isWorkerAvailable
                      ? tokens.tealAccent
                      : tokens.mutedText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isWorkerAvailable
                          ? l10n.workerAvailableIn(widget.locationZone)
                          : l10n.workerCurrentlyOffline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.availabilityCalendar,
                      ),
                      child: Text(
                        '${l10n.workerManageSchedule} →',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SakugaToggle(
                value: widget.isWorkerAvailable,
                activeColor: tokens.tealAccent,
                semanticLabel: 'Worker availability status',
                onChanged: widget.onToggleAvailability,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Active Assigned Job Card (lets worker resume accepted/in-progress jobs anytime)
        if (widget.activeJob != null) ...[
          _buildActiveJobCard(context, widget.activeJob!, isBn),
          const SizedBox(height: 16),
        ],

        // 3. Real Worker Metrics (Earnings, Jobs, Rating — never fabricated)
        WorkerStatCards(
          workerEarnings: widget.workerEarnings,
          workerCompletedJobs: widget.workerCompletedJobs,
          workerRating: widget.workerRating,
        ),
        const SizedBox(height: 16),

        // 4. Honest KYC & Worker Profile Card
        Material(
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
              arguments: {'isEdit': true},
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      color: colorScheme.onTertiaryContainer,
                      size: 20,
                    ),
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
                              verifTitle,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SkaviaBadge(
                              label: widget.verificationStatus,
                              tone: verifTone,
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          verifSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, color: tokens.mutedText),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // 5. Incoming Job Requests
        WorkerIncomingRequestsList(liveJobRequests: widget.liveJobRequests),
      ],
    );
  }

  Widget _buildActiveJobCard(
    BuildContext context,
    Map<String, dynamic> job,
    bool isBn,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final reqId = job['service_request_id']?.toString() ?? '';
    final title = job['title']?.toString() ?? 'Active Job';
    final clientName = job['client_name']?.toString() ?? 'Client';
    final location = job['location']?.toString() ?? 'Dhaka';
    final status = job['status']?.toString() ?? 'Accepted';
    final price = (job['agreed_price'] as num?)?.toDouble() ?? 0.0;
    final notes = job['service_notes']?.toString() ?? '';
    final otp = JobOtpUtil.extractOtp(notes, fallbackRequestId: reqId);

    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.activeJob,
          arguments: {
            'requestId': reqId,
            'clientName': clientName,
            'jobTitle': title,
            'location': location,
            'agreedPrice': price,
            'expectedOtp': otp,
            'scheduledTime': job['scheduled_at']?.toString() ?? '',
            'serviceNotes': notes,
            'clientPhone': job['client_phone']?.toString(),
          },
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                color: colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkaviaBadge(
                      label: context.l10n.workerActiveJobBadge(status),
                      tone: SkaviaBadgeTone.primary,
                      compact: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$clientName · $location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
