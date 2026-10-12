import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Modal dialog displaying 4-digit job security OTP for Escrow release.
class JobOtpDialog extends StatelessWidget {
  final String bookingId;
  final String otpCode;

  const JobOtpDialog({
    super.key,
    required this.bookingId,
    required this.otpCode,
  });

  static void show(
    BuildContext context, {
    required String bookingId,
    required String otpCode,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => JobOtpDialog(bookingId: bookingId, otpCode: otpCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.shield_rounded, color: AppColors.primaryRoyal, size: 24),
          SizedBox(width: 8),
          Text(
            'Job Security OTP',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share this 4-digit OTP with your technician only when they arrive at your location to begin work:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardPeachTint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accentPeach),
            ),
            child: Text(
              otpCode,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
                color: AppColors.primaryRoyal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Protects your Escrow deposit until work is verified.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.successGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Dismiss',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
