import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/admin_controller.dart';

/// Screen allowing administrators to mediate disputes and execute partial/full escrow settlements.
class DisputeResolutionScreen extends StatefulWidget {
  const DisputeResolutionScreen({super.key});

  @override
  State<DisputeResolutionScreen> createState() =>
      _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends State<DisputeResolutionScreen> {
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

  Future<void> _resolve(Map<String, dynamic> dispute, String resolution) async {
    final id = dispute['dispute_id']?.toString() ?? dispute['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      await _controller.resolveDispute(id, resolution);
    }
    if (!mounted) return;
    UiFeedbackHelper.showSuccess(
      context,
      'Dispute resolved: $resolution. Escrow ledger updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Escrow Dispute Mediation',
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
          if (_controller.isLoading && _controller.disputes.isEmpty) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final disputes = _controller.disputes;
          if (disputes.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 56,
                      color: AppColors.successGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _controller.isLive
                          ? 'No Pending Escrow Disputes'
                          : 'Dispute Queue Offline',
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
                          ? 'All client and specialist escrow claims are currently settled.'
                          : 'Connect to the live admin backend to load active escrow mediation cases.',
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
            itemCount: disputes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final d = disputes[index];
              final title = d['title']?.toString() ?? 'Escrow Dispute Case';
              final escrowAmount =
                  (d['escrow_amount'] as num?)?.toDouble() ??
                  (d['escrowAmount'] as num?)?.toDouble() ??
                  0.0;
              final claim =
                  d['reason']?.toString() ??
                  d['claim']?.toString() ??
                  'Dispute details pending review.';
              final client = d['client_name']?.toString() ?? d['client']?.toString() ?? 'Client';
              final worker = d['worker_name']?.toString() ?? d['worker']?.toString() ?? 'Specialist';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.cardBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.35),
                  ),
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
                        runSpacing: 6,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '৳ ${escrowAmount.toStringAsFixed(0)} Escrow',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Client: $client • Specialist: $worker',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: tokens.mutedText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      claim,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final textScale = MediaQuery.textScalerOf(context).scale(1);
                        final stackBtns =
                            constraints.maxWidth < 310 || textScale > 1.3;
                        final refundBtn = OutlinedButton(
                          onPressed: () =>
                              _resolve(d, 'Full Refund to Client'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.errorRed),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Refund Client',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.errorRed,
                              fontSize: 12,
                            ),
                          ),
                        );
                        final releaseBtn = ElevatedButton(
                          onPressed: () =>
                              _resolve(d, 'Release Escrow to Specialist'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tokens.brandAccent,
                            foregroundColor: tokens.onBrandAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Release Escrow',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                        if (stackBtns) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              releaseBtn,
                              const SizedBox(height: 8),
                              refundBtn,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: refundBtn),
                            const SizedBox(width: 8),
                            Expanded(child: releaseBtn),
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
