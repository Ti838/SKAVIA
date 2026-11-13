import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/supabase_guard.dart';
import '../../../../core/utils/uuid_util.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../chat/presentation/screens/chat_room_screen.dart';
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

  @override
  void initState() {
    super.initState();
    final cached = LocalCacheService.instance.get(
      'active_job_phase_${widget.requestId}',
    );
    if (cached is int && cached >= 0 && cached <= 3) {
      _jobPhase = cached;
    }
  }

  Future<void> _persistPhase(int phase, String remoteStatus) async {
    LocalCacheService.instance.put(
      'active_job_phase_${widget.requestId}',
      phase,
    );
    final client = tryGetSupabaseClient();
    if (client != null && UuidUtil.isValidUuid(widget.requestId)) {
      try {
        await client
            .from('service_requests')
            .update({
              'status': remoteStatus,
              if (phase == 3) 'completed_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('service_request_id', widget.requestId);
      } catch (e) {
        debugPrint('[ActiveJobScreen] Phase sync notice: $e');
      }
    }
  }

  Future<void> _nextPhase() async {
    if (_jobPhase == 0) {
      setState(() => _jobPhase = 1);
      await _persistPhase(1, 'In Progress');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status updated: Heading to customer location'),
        ),
      );
    } else if (_jobPhase == 1) {
      setState(() => _jobPhase = 2);
      await _persistPhase(2, 'In Progress');
      if (!mounted) return;
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
      onOtpVerified: () async {
        setState(() => _jobPhase = 3);
        await _persistPhase(3, 'Completed');
        if (mounted) _showSuccessCelebration();
      },
    );
  }

  void _showSuccessCelebration() {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        backgroundColor: tokens.cardBg,
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
            Text(
              'Job Completed Successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '৳ ${widget.agreedPrice.toStringAsFixed(0)} completion verified for escrow settlement.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: tokens.secondaryText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: tokens.brandAccent,
                  foregroundColor: tokens.onBrandAccent,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;

    return Scaffold(
      backgroundColor: tokens.canvasBg,
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingSmall,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
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
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '৳ ${widget.agreedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.35),
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingSmall),

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

                    ActiveJobLifecycleStepper(currentPhase: _jobPhase),

                    const SizedBox(height: AppDimensions.paddingXLarge),

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
                            textAlign: TextAlign.center,
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
