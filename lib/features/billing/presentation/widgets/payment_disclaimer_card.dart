import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Transparent disclaimer banner clearly separating Developer Sandbox test simulations from Cash on Completion.
class PaymentDisclaimerCard extends StatelessWidget {
  final String selectedMethod;

  const PaymentDisclaimerCard({super.key, required this.selectedMethod});

  @override
  Widget build(BuildContext context) {
    if (selectedMethod != 'Cash') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySky.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primarySky.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.science_rounded,
              color: AppColors.primaryRoyal,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Developer Sandbox: Online rails operate in test simulation. No real funds will be deducted. For real bookings, select Cash on Completion.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryRoyal,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.successGreen.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.handshake_rounded,
              color: AppColors.successGreen,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cash on Service Delivery: Pay the verified technician directly in cash only after physical inspection and full satisfaction.',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
