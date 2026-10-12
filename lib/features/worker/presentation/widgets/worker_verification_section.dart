import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';

class WorkerVerificationBanner extends StatelessWidget {
  final String verificationStatus;

  const WorkerVerificationBanner({super.key, required this.verificationStatus});

  @override
  Widget build(BuildContext context) {
    final isVerified = verificationStatus == 'Verified';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFDCFCE7) : AppColors.cardPeachTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVerified ? AppColors.statusActive : AppColors.accentPeach,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
            color: isVerified ? AppColors.statusActive : AppColors.accentCoral,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'Verified Specialist' : 'Verification in Review',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isVerified
                        ? AppColors.statusActive
                        : AppColors.accentCoral,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isVerified
                      ? 'Your NID and certifications are authenticated by SKAVIA Operations.'
                      : 'NID documents submitted. Verified workers get priority matching & instant payouts.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMedium,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkerDocumentUploadSection extends StatelessWidget {
  final bool nidUploaded;
  final VoidCallback onToggleNid;
  final bool certUploaded;
  final VoidCallback onToggleCert;

  const WorkerDocumentUploadSection({
    super.key,
    required this.nidUploaded,
    required this.onToggleNid,
    required this.certUploaded,
    required this.onToggleCert,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Documents & Identity',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDocUploadCard(
                title: 'NID Card',
                isUploaded: nidUploaded,
                icon: Icons.badge_rounded,
                onTap: onToggleNid,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocUploadCard(
                title: 'Trade License',
                isUploaded: certUploaded,
                icon: Icons.assignment_turned_in_rounded,
                onTap: onToggleCert,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocUploadCard({
    required String title,
    required bool isUploaded,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.cardBlueTint
              : AppColors.sheetSurfaceSubtle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.primarySky : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle_rounded : icon,
              color: isUploaded ? AppColors.statusActive : AppColors.textMedium,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTypography.headingFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isUploaded ? 'Uploaded' : 'Tap to Upload',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUploaded
                    ? AppColors.statusActive
                    : AppColors.primarySky,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
