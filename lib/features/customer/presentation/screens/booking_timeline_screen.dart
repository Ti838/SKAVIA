import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
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
  });

  @override
  State<BookingTimelineScreen> createState() => _BookingTimelineScreenState();
}

class _BookingTimelineScreenState extends State<BookingTimelineScreen> {
  // Current active step in lifecycle: 0 = Requested, 1 = Accepted, 2 = In Progress, 3 = Completed
  int _currentStep = 1;

  void _advanceStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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

          // Main 32dp Curved White Content Sheet
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.sheetBackground,
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
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Only share the 4-digit secret OTP with the worker after inspecting and confirming the completed work.',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
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
                          onPressed: _advanceStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusRound,
                              ),
                            ),
                          ),
                          child: Text(
                            'Update Service Progress',
                            style: AppTypography.button.copyWith(
                              color: AppColors.primary,
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
                                'workerProfileId': 'wp_worker_01',
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
