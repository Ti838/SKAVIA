import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../widgets/active_job_client_card.dart';
import '../widgets/active_job_lifecycle_stepper.dart';
import '../widgets/worker_job_otp_sheet.dart';

/// Screen for Workers to manage an active job in real-time, progress through phases,
/// and complete the job securely by submitting the Customer's 4-Digit secret OTP.
/// Aligned with SRS Section 3.1.H (FR-H03 - FR-H05) and Section 3.1.R.
class ActiveJobScreen extends StatefulWidget {
  final String requestId;
  final String clientName;
  final String jobTitle;
  final String location;
  final double agreedPrice;
  final String expectedOtp;
  final String scheduledTime;
  final String serviceNotes;
  final String? clientPhone;

  const ActiveJobScreen({
    super.key,
    required this.requestId,
    required this.clientName,
    required this.jobTitle,
    required this.location,
    required this.agreedPrice,
    required this.expectedOtp,
    required this.scheduledTime,
    required this.serviceNotes,
    this.clientPhone,
  });

  @override
  State<ActiveJobScreen> createState() => _ActiveJobScreenState();
}

class _ActiveJobScreenState extends State<ActiveJobScreen> {
  // 0: Accepted, 1: On The Way, 2: In Progress, 3: Completed
  int _jobPhase = 0;

  void _nextPhase() {
    if (_jobPhase == 0) {
      setState(() => _jobPhase = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated: Heading to customer location'),
        ),
      );
    } else if (_jobPhase == 1) {
      setState(() => _jobPhase = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated: Arrived at site & Work in progress'),
        ),
      );
    } else if (_jobPhase == 2) {
      _showOtpModal();
    }
  }

  void _showOtpModal() {
    WorkerJobOtpSheet.show(
      context,
      expectedOtp: widget.expectedOtp,
      onOtpVerified: () {
        setState(() => _jobPhase = 3);
        _showSuccessCelebration();
      },
    );
  }

  void _showSuccessCelebration() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Job Completed Successfully',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '৳ ${widget.agreedPrice.toStringAsFixed(0)} has been credited to your SKAVIA earnings balance.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // Return to dashboard
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Active Service Dispatch',
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Earning & Price Banner
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
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Guaranteed Escrow Payout',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '৳ ${widget.agreedPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
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
                      color: AppColors.success.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Secured',
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
                    // Job & Client Details Card
                    ActiveJobClientCard(
                      jobTitle: widget.jobTitle,
                      clientName: widget.clientName,
                      location: widget.location,
                      onCallClient: () async {
                        final phone = widget.clientPhone?.isNotEmpty == true
                            ? widget.clientPhone!
                            : AppConstants.supportHelpline;
                        final uri = Uri.parse('tel:$phone');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.clientPhone?.isNotEmpty == true
                                    ? 'Dialer unavailable. Dial $phone directly.'
                                    : 'Client phone not provided. Dialing SKAVIA Support: $phone',
                              ),
                            ),
                          );
                        }
                      },
                      onChatClient: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              conversationId: 'req_${widget.requestId}',
                              otherParticipantName: widget.clientName,
                              otherParticipantId: 'client_${widget.clientName}',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingLarge),

                    // Progress Lifecycle Stepper
                    ActiveJobLifecycleStepper(currentPhase: _jobPhase),

                    const SizedBox(height: AppDimensions.paddingXLarge),

                    // Primary Phase Progression CTA
                    if (_jobPhase == 0)
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Heading to Location',
                          onPressed: _nextPhase,
                        ),
                      )
                    else if (_jobPhase == 1)
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Arrived at Site & Start Work',
                          onPressed: _nextPhase,
                        ),
                      )
                    else if (_jobPhase == 2)
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          text: 'Complete Work (Enter Job OTP)',
                          onPressed: _nextPhase,
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Job Finished & Verified',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

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
