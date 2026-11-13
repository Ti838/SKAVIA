import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

class WorkerVerificationBanner extends StatelessWidget {
  final String verificationStatus;

  const WorkerVerificationBanner({super.key, required this.verificationStatus});

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final isVerified = verificationStatus == 'Verified';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? tokens.softMintBg : tokens.softPeachBg,
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
                  style: TextStyle(
                    fontSize: 11.5,
                    color: tokens.secondaryText,
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
    final colorScheme = context.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Documents & Identity',
          style: TextStyle(
            fontFamily: AppTypography.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final stackVertically =
                constraints.maxWidth < 300 || textScale > 1.3;

            final nidCard = _buildDocUploadCard(
              context,
              title: 'NID Card',
              isUploaded: nidUploaded,
              icon: Icons.badge_rounded,
              onTap: onToggleNid,
            );

            final certCard = _buildDocUploadCard(
              context,
              title: 'Trade License',
              isUploaded: certUploaded,
              icon: Icons.assignment_turned_in_rounded,
              onTap: onToggleCert,
            );

            if (stackVertically) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [nidCard, const SizedBox(height: 10), certCard],
              );
            }

            return Row(
              children: [
                Expanded(child: nidCard),
                const SizedBox(width: 12),
                Expanded(child: certCard),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDocUploadCard(
    BuildContext context, {
    required String title,
    required bool isUploaded,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUploaded ? tokens.softBlueBg : tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? tokens.brandAccent : tokens.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isUploaded ? Icons.check_circle_rounded : icon,
              color: isUploaded ? AppColors.statusActive : tokens.secondaryText,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.headingFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isUploaded ? 'Marked Ready' : 'Tap to Mark Ready',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isUploaded ? AppColors.statusActive : tokens.brandAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
