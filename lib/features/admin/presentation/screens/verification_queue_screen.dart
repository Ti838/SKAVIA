import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/admin_controller.dart';

/// Screen allowing administrators to review and approve submitted credentials and NIDs.
class VerificationQueueScreen extends StatefulWidget {
  const VerificationQueueScreen({super.key});

  @override
  State<VerificationQueueScreen> createState() =>
      _VerificationQueueScreenState();
}

class _VerificationQueueScreenState extends State<VerificationQueueScreen> {
  final AdminController _controller = AdminController();

  @override
  void initState() {
    super.initState();
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleDecision(Map<String, dynamic> item, bool isApproved) async {
    final id = item['verification_id']?.toString() ?? item['id']?.toString() ?? '';
    final name = item['full_name']?.toString() ?? item['name']?.toString() ?? 'Worker';
    if (id.isNotEmpty) {
      await _controller.reviewVerification(id, isApproved);
    }
    if (!mounted) return;
    if (isApproved) {
      UiFeedbackHelper.showSuccess(
        context,
        'Approved and verified $name. Verified badge granted.',
      );
    } else {
      UiFeedbackHelper.showInfo(
        context,
        'Application rejected for $name. Specialist requested to resubmit.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Verification Review Queue',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: _controller.loadDashboard,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading && _controller.verifications.isEmpty) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final queue = _controller.verifications;
          if (queue.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 56,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.isLive
                          ? 'No Pending Verifications'
                          : 'Verification Queue Offline',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _controller.isLive
                          ? 'All submitted NID and trade license checks have been processed.'
                          : 'Connect to the live admin backend to review pending specialist submissions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: tokens.mutedText),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            itemCount: queue.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = queue[index];
              final name =
                  item['full_name']?.toString() ??
                  item['name']?.toString() ??
                  'Applicant';
              final trade =
                  item['trade']?.toString() ??
                  item['document_type']?.toString() ??
                  'Specialist Verification';
              final docType =
                  item['document_type']?.toString() ??
                  item['docType']?.toString() ??
                  'Submitted Credential';
              final nid = item['document_number']?.toString() ??
                  item['nid']?.toString() ??
                  'Pending mask check';
              final submittedAt =
                  item['submitted_at']?.toString() ??
                  item['date']?.toString() ??
                  'Pending review';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.cardBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(color: tokens.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            submittedAt,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trade,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: tokens.brandAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: tokens.subtleCardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credential: $docType',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Reference ID: $nid',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(context).scale(1);
                        final stackBtns =
                            constraints.maxWidth < 310 || textScale > 1.3;
                        final rejectBtn = OutlinedButton(
                          onPressed: () => _handleDecision(item, false),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.errorRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Reject / Resubmit',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.errorRed),
                          ),
                        );
                        final approveBtn = ElevatedButton(
                          onPressed: () => _handleDecision(item, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Approve & Verify',
                            textAlign: TextAlign.center,
                          ),
                        );
                        if (stackBtns) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              approveBtn,
                              const SizedBox(height: 8),
                              rejectBtn,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: rejectBtn),
                            const SizedBox(width: 12),
                            Expanded(child: approveBtn),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
