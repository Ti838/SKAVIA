import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return AlertDialog(
      backgroundColor: tokens.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.shield_rounded, color: tokens.brandAccent, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Job Security OTP',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share this 4-digit OTP with your technician only when they arrive at your location to begin work:',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: tokens.softPeachBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.accentPeach.withValues(alpha: 0.65),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  otpCode,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: tokens.brandAccent,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Protects your Escrow deposit until work is verified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.successGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
