import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';

/// Itemized breakdown rows, total amount, and escrow compliance note for InvoiceScreen.
class InvoiceBreakdownSection extends StatelessWidget {
  final String serviceTitle;
  final String specialistName;
  final double baseAmount;
  final double platformFee;
  final double totalAmount;
  final String paymentMethod;

  const InvoiceBreakdownSection({
    super.key,
    required this.serviceTitle,
    required this.specialistName,
    required this.baseAmount,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
  });

  Widget _buildItem(
    BuildContext context,
    String title,
    String subtitle,
    String amount,
  ) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: tokens.mutedText),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Itemized Breakdown',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        _buildItem(
          context,
          serviceTitle,
          'Certified execution by $specialistName',
          Formatters.formatCurrency(baseAmount),
        ),
        Divider(height: 20, color: tokens.border),
        _buildItem(
          context,
          'SKAVIA Platform & Trust Escrow (15%)',
          'Insurance protection, dispute mediation & Job OTP verification',
          Formatters.formatCurrency(platformFee),
        ),
        Divider(height: 24, color: tokens.border),

        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Total Paid ($paymentMethod)',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Formatters.formatCurrency(totalAmount),
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: tokens.brandAccent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.softBlueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: tokens.brandAccent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This invoice is digitally signed and compliant with the SKAVIA Marketplace Services Standard. Escrow balance is settled upon Job OTP verification.',
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.secondaryText,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
