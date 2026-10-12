import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';

/// Trust, Turnkey Hub Banner, and Verified Safety widgets for Dashboard
class DashboardTrustSafetySection extends StatelessWidget {
  final String? userIdentifier;
  final VoidCallback onCallHelpline;

  const DashboardTrustSafetySection({
    super.key,
    required this.userIdentifier,
    required this.onCallHelpline,
  });

  void _showTrustDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: AppColors.textMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Understood',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Turnkey Business Solution Banner (SRS Section 2.3 & 3.1.I)
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.projectDashboard),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryRoyal, AppColors.primarySky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radius20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primarySky.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Business & Office Turnkey Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.stars_rounded,
                            color: AppColors.accentPeach,
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Full setup for Office, Showroom or IT Hub with a Dedicated Team Leader.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Trust Safety Strip
        Row(
          children: [
            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.shield_rounded,
                title: '100% NID Verified',
                color: AppColors.primaryRoyal,
                onTap: () => _showTrustDialog(
                  context,
                  'SKAVIA Trust & Verification',
                  'All skilled professionals undergo national NID identity checks, trade skill tests, and background verification before entering client premises.',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.lock_outline_rounded,
                title: 'Escrow Protected',
                color: AppColors.successGreen,
                onTap: () => _showTrustDialog(
                  context,
                  'Escrow Payment Security',
                  'Your payment is held safely in SKAVIA Escrow. Funds are released to the provider only after you confirm satisfactory completion with OTP.',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTrustItem(
                context,
                icon: Icons.support_agent_rounded,
                title: '24/7 Helpline',
                color: AppColors.accentCoral,
                onTap: onCallHelpline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// City Bank-Style KYC Trust Card (Default when no active job)
class KycTrustCard extends StatelessWidget {
  final String? userIdentifier;

  const KycTrustCard({super.key, required this.userIdentifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheetSurfaceSubtle,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primarySky.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryRoyal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: AppColors.primaryRoyal,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'SKAVIA Verified Shield',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Connected as ${userIdentifier ?? 'Active User'} • Escrow Protection Active',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
