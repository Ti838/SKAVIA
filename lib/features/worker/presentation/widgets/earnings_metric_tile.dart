import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

class EarningsMetricTile extends StatelessWidget {
  final String label;
  final String value;

  const EarningsMetricTile({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class EarningsTransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const EarningsTransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final amount = (transaction['amount'] as num?)?.toDouble() ?? 0.0;
    final isCredit = transaction['transaction_type'] == 'Credit' || amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withValues(alpha: 0.14)
                  : AppColors.error.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['transaction_type']?.toString() ?? 'Job Earning',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  transaction['status']?.toString() ?? 'Completed',
                  style: AppTypography.caption.copyWith(
                    color: tokens.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${isCredit ? '+' : '-'}৳ ${amount.abs().toStringAsFixed(0)}',
              textAlign: TextAlign.end,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: isCredit ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
