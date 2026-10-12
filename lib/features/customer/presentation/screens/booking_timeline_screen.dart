import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';

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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Completion Job OTP (Secret)',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.jobOtp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Anti-Fraud',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                    Container(
                      padding: const EdgeInsets.all(
                        AppDimensions.paddingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLarge,
                        ),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
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
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.workerName,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  widget.tradeTitle,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.phone_in_talk_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Calling specialist via encrypted SKAVIA VoIP...',
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Opening live in-app messaging channel...',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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

                    _buildTimelineStep(
                      stepIndex: 0,
                      title: '1. Request Dispatched',
                      subtitle:
                          'Sent to matched specialist on ${widget.scheduledSlot}',
                      icon: Icons.send_rounded,
                    ),
                    _buildTimelineStep(
                      stepIndex: 1,
                      title: '2. Request Accepted',
                      subtitle:
                          '${widget.workerName} accepted and is preparing tools',
                      icon: Icons.check_circle_rounded,
                    ),
                    _buildTimelineStep(
                      stepIndex: 2,
                      title: '3. Specialist On Site / In Progress',
                      subtitle: 'Active labor at ${widget.address}',
                      icon: Icons.handyman_rounded,
                    ),
                    _buildTimelineStep(
                      stepIndex: 3,
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

                    // Demo Progression Button (Simulates real-time status transitions)
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
                            'Simulate Next Status',
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

  Widget _buildTimelineStep({
    required int stepIndex,
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
  }) {
    final isDone = _currentStep >= stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDone
                    ? (isCurrent ? AppColors.accent : AppColors.primary)
                    : Colors.black.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDone ? Colors.white : AppColors.textDisabled,
                size: 18,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isDone
                    ? AppColors.primary
                    : Colors.black.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDone
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDone
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
