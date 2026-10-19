import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';

/// Card displaying order breakdown: specialist details, base amount, 15% platform commission, and total payable.
class OrderSummaryCard extends StatelessWidget {
  final String title;
  final String specialistName;
  final double baseAmount;
  final double platformFee;
  final double totalPayable;

  const OrderSummaryCard({
    super.key,
    required this.title,
    required this.specialistName,
    required this.baseAmount,
    required this.platformFee,
    required this.totalPayable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : AppColors.sheetSurfaceSubtle,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySky.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: AppColors.primarySky,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Specialist: $specialistName',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _buildCostRow(
            context,
            'Base Service Amount',
            Formatters.formatCurrency(baseAmount),
          ),
          const SizedBox(height: 8),
          _buildCostRow(
            context,
            'SKAVIA Platform Fee (15%)',
            Formatters.formatCurrency(platformFee),
            subtitle: 'Escrow guarantee & 24/7 insurance',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                Formatters.formatCurrency(totalPayable),
                style: const TextStyle(
                  fontFamily: AppTypography.headingFont,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context,
    String title,
    String amount, {
    String? subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
