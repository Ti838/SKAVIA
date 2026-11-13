import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import 'earnings_metric_tile.dart';

/// Top header card displaying available wallet balance, pending escrow, and lifetime earnings.
class WorkerBalanceCard extends StatelessWidget {
  final double availableBalance;
  final double pendingEscrow;
  final double totalEarned;

  const WorkerBalanceCard({
    super.key,
    required this.availableBalance,
    required this.pendingEscrow,
    required this.totalEarned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        child: Column(
          children: [
            const Text(
              'Available Wallet Balance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '৳ ${availableBalance.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                EarningsMetricTile(
                  label: 'Pending Escrow',
                  value: '৳ ${pendingEscrow.toStringAsFixed(0)}',
                ),
                EarningsMetricTile(
                  label: 'Total Lifetime',
                  value: '৳ ${totalEarned.toStringAsFixed(0)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

