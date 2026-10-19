import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_button.dart';

/// Screen displayed upon verified payment and escrow authorization.
class PaymentSuccessScreen extends StatelessWidget {
  final double amount;
  final String transactionId;
  final String paymentMethod;
  final String jobTitle;
  final String specialistName;
  final String? serviceRequestId;
  final String? projectId;
  final VoidCallback onViewInvoice;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.transactionId,
    required this.paymentMethod,
    required this.jobTitle,
    required this.specialistName,
    this.serviceRequestId,
    this.projectId,
    required this.onViewInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Celebration Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.successGreen,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                paymentMethod.toLowerCase() == 'cash'
                    ? 'Booking Confirmed — Cash on Delivery'
                    : 'Sandbox Payment Confirmed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                paymentMethod.toLowerCase() == 'cash'
                    ? 'Your booking is confirmed with $specialistName. Pay ${Formatters.formatCurrency(amount)} directly in cash upon inspection.'
                    : 'Your test transaction of ${Formatters.formatCurrency(amount)} via $paymentMethod has been processed in developer sandbox mode.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Transaction Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainerHighest
                      : AppColors.sheetSurfaceSubtle,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusLarge,
                  ),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      paymentMethod.toLowerCase() == 'cash'
                          ? 'Booking Reference'
                          : 'Sandbox TRX ID',
                      transactionId,
                      context,
                    ),
                    const Divider(height: 20),
                    _buildRow('Service / Work', jobTitle, context),
                    const Divider(height: 20),
                    _buildRow('Assigned Specialist', specialistName, context),
                    const Divider(height: 20),
                    _buildRow(
                      'Payment Rail',
                      paymentMethod.toLowerCase() == 'cash'
                          ? 'Cash on Completion'
                          : '$paymentMethod (Sandbox Test)',
                      context,
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Security notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.shield_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        paymentMethod.toLowerCase() == 'cash'
                            ? 'Consumer Protection: Inspect the completed work carefully before handing over cash to the technician.'
                            : 'Developer Sandbox Notice: No real funds were deducted. Live transactions require production gateway credentials.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Action Buttons
              OutlinedButton(
                onPressed: onViewInvoice,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primarySky,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusRound,
                    ),
                  ),
                ),
                child: const Text(
                  'View Official Invoice',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primarySky,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              AppButton(
                text: 'Return to Dashboard',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value,
    BuildContext context, {
    bool isHighlight = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.accent : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
