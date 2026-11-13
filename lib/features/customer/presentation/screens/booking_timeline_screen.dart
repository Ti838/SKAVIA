import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../data/tables/database_tables.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/booking_timeline_step.dart';
import '../widgets/job_otp_banner_card.dart';
import '../widgets/timeline_worker_card.dart';

/// Live booking timeline screen showing real-time service lifecycle and anti-fraud Job OTP.
/// Aligned with SRS Section 3.1.E (FR-H03 - FR-H05) and Section 3.1.Q.
class BookingTimelineScreen extends StatefulWidget {
  final String requestId;
  final String jobTitle;
  final String workerName;
  final String tradeTitle;
  final String scheduledSlot;
  final double totalPrice;
  final String jobOtp;
  final String address;
  final String? workerPhone;
  final String? workerProfileId;

  const BookingTimelineScreen({
    super.key,
    required this.requestId,
    required this.jobTitle,
    required this.workerName,
    required this.tradeTitle,
    required this.scheduledSlot,
    required this.totalPrice,
    required this.jobOtp,
    required this.address,
    this.workerPhone,
    this.workerProfileId,
  });

  @override
  State<BookingTimelineScreen> createState() => _BookingTimelineScreenState();
}

class _BookingTimelineScreenState extends State<BookingTimelineScreen> {
  // Current active step in lifecycle: 0 = Requested, 1 = Accepted, 2 = In Progress, 3 = Completed
  int _currentStep = 1;
  String? _resolvedWorkerProfileId;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _resolvedWorkerProfileId = widget.workerProfileId;
    _loadInitialRequestState();
  }

  Future<void> _loadInitialRequestState() async {
    if (!UuidUtil.isValidUuid(widget.requestId)) return;
    final client = tryGetSupabaseClient();
    if (client == null) return;
    try {
      final row = await client
          .from(DatabaseTables.serviceRequests)
          .select('status, worker_profile_id')
          .eq('service_request_id', widget.requestId)
          .maybeSingle();
      if (row != null && mounted) {
        final statusStr = (row['status']?.toString() ?? '').toLowerCase();
        final wpId = row['worker_profile_id']?.toString();
        setState(() {
          if (wpId != null && wpId.isNotEmpty) {
            _resolvedWorkerProfileId = wpId;
          }
          if (statusStr == 'completed') {
            _currentStep = 3;
          } else if (statusStr == 'in progress') {
            _currentStep = 2;
          } else if (statusStr == 'accepted') {
            _currentStep = 1;
          } else if (statusStr == 'requested') {
            _currentStep = 0;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _advanceStep() async {
    if (_currentStep >= 3 || _isUpdating) return;

    // For live Supabase requests, final completion requires worker 4-digit OTP
    // verification; customers refresh live state instead of self-completing.
    if (UuidUtil.isValidUuid(widget.requestId)) {
      if (_currentStep >= 2) {
        setState(() => _isUpdating = true);
        await _loadInitialRequestState();
        if (mounted) {
          setState(() => _isUpdating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Share the 4-digit OTP with your specialist to complete this job.',
              ),
            ),
          );
        }
        return;
      }

      final nextStep = _currentStep + 1;
      final client = tryGetSupabaseClient();
      if (client != null) {
        setState(() => _isUpdating = true);
        final statusLabel = switch (nextStep) {
          0 => 'Requested',
          1 => 'Accepted',
          _ => 'In Progress',
        };
        try {
          await client
              .from(DatabaseTables.serviceRequests)
              .update({'status': statusLabel})
              .eq('service_request_id', widget.requestId);
        } catch (e) {
          if (mounted) {
            setState(() => _isUpdating = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not update booking status: $e')),
            );
          }
          return;
        }
      }
      if (mounted) {
        setState(() {
          _currentStep = nextStep;
          _isUpdating = false;
        });
      }
      return;
    }

    final nextStep = _currentStep + 1;
    if (mounted) {
      setState(() {
        _currentStep = nextStep;
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Scaffold(
      backgroundColor: tokens.canvasBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          'Live Service Tracking',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Job OTP Security Card
          JobOtpBannerCard(jobOtp: widget.jobOtp),
          const SizedBox(height: AppDimensions.paddingSmall),

          // Main 32dp Curved Content Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: tokens.sheetBg,
                borderRadius: AppDimensions.roundedSheetTop,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Worker Summary Card
                    TimelineWorkerCard(
                      workerName: widget.workerName,
                      tradeTitle: widget.tradeTitle,
                      requestId: widget.requestId,
                      workerPhone: widget.workerPhone,
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Tracking Stepper
                    Text(
                      'Service Progress Lifecycle',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingMedium),

                    BookingTimelineStep(
                      stepIndex: 0,
                      currentStep: _currentStep,
                      title: '1. Request Dispatched',
                      subtitle:
                          'Sent to matched specialist on ${widget.scheduledSlot}',
                      icon: Icons.send_rounded,
                    ),
                    BookingTimelineStep(
                      stepIndex: 1,
                      currentStep: _currentStep,
                      title: '2. Request Accepted',
                      subtitle:
                          '${widget.workerName} accepted and is preparing tools',
                      icon: Icons.check_circle_rounded,
                    ),
                    BookingTimelineStep(
                      stepIndex: 2,
                      currentStep: _currentStep,
                      title: '3. Specialist On Site / In Progress',
                      subtitle: 'Active labor at ${widget.address}',
                      icon: Icons.handyman_rounded,
                    ),
                    BookingTimelineStep(
                      stepIndex: 3,
                      currentStep: _currentStep,
                      title: '4. Service Completed & Verified',
                      subtitle: 'Job OTP verified, escrow payment released',
                      icon: Icons.task_alt_rounded,
                      isLast: true,
                    ),

                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Security notice
                    Container(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.softPeachBg,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.accentCoral,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Only share the 4-digit secret OTP with the worker after inspecting and confirming the completed work.',
                              style: AppTypography.caption.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Real-Time Progression Action (Updates active service lifecycle)
                    if (_currentStep < 3)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isUpdating ? null : _advanceStep,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: tokens.brandAccent,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusRound,
                              ),
                            ),
                          ),
                          child: _isUpdating
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: tokens.brandAccent,
                                  ),
                                )
                              : Text(
                                  'Update Service Progress',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.button.copyWith(
                                    color: tokens.brandAccent,
                                  ),
                                ),
                        ),
                      ),

                    if (_currentStep == 3) ...[
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Rate & Review Specialist',
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.submitReview,
                              arguments: {
                                'workerProfileId':
                                    _resolvedWorkerProfileId ?? '',
                                'workerName': widget.workerName,
                                'serviceRequestId': widget.requestId,
                              },
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimensions.paddingLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
