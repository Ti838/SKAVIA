import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../controllers/admin_controller.dart';

/// Platform Governance & Operations Dashboard for SKAVIA Administrators.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminController _controller = AdminController();

  @override
  void initState() {
    super.initState();
    _controller.loadDashboard();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: tokens.sheetBg,
      appBar: AppAppBar(
        title: 'Admin & Governance Hub',
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: _controller.loadDashboard,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final totalUsers = (_controller.metrics['totalUsers'] as num?)?.toInt() ?? 0;
          final activeRequests =
              (_controller.metrics['activeRequests'] as num?)?.toInt() ?? 0;
          final totalVolume =
              (_controller.metrics['totalVolume'] as num?)?.toDouble() ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_controller.isLoading && !_controller.isLive) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tokens.softPeachBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Live admin backend offline or unavailable. Showing verified local counts (0 until synced).',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final stackKpis =
                        constraints.maxWidth < 340 || textScale > 1.3;
                    if (stackKpis) {
                      return Column(
                        children: [
                          _buildMetricTile(
                            'Total Verified Users',
                            '$totalUsers',
                            Icons.people_rounded,
                            tokens.brandAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricTile(
                            'Active Service Jobs',
                            '$activeRequests',
                            Icons.handyman_rounded,
                            AppColors.accent,
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            'Total Verified Users',
                            '$totalUsers',
                            Icons.people_rounded,
                            tokens.brandAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            'Active Service Jobs',
                            '$activeRequests',
                            Icons.handyman_rounded,
                            AppColors.accent,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildMetricTile(
                  'Gross Platform Volume',
                  Formatters.formatCurrency(totalVolume),
                  Icons.account_balance_rounded,
                  AppColors.successGreen,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppDimensions.paddingLarge),

                Text(
                  'Operations & Moderation Workflows',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingMedium),

                _buildActionCard(
                  context,
                  title: 'Worker Verification Queue',
                  subtitle:
                      'Review government NID, trade licenses, and certificates',
                  icon: Icons.verified_user_rounded,
                  color: tokens.brandAccent,
                  badgeCount: _controller.verifications.length,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.verificationQueue),
                ),
                const SizedBox(height: 12),

                _buildActionCard(
                  context,
                  title: 'Escrow Dispute Resolution',
                  subtitle:
                      'Mediate client-worker claims, cancellations, and refunds',
                  icon: Icons.gavel_rounded,
                  color: AppColors.errorRed,
                  badgeCount: _controller.disputes.length,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.disputeResolution),
                ),
                const SizedBox(height: 12),

                _buildActionCard(
                  context,
                  title: 'Turnkey Team Assembly',
                  subtitle:
                      'Form cross-functional specialized trade units for enterprise clients',
                  icon: Icons.group_work_rounded,
                  color: AppColors.accent,
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.teamAssembly),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.03),
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
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: tokens.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFont,
                    fontWeight: FontWeight.w800,
                    fontSize: isFullWidth ? 18 : 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: tokens.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (badgeCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: tokens.mutedText),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: tokens.mutedText),
          ],
        ),
      ),
    );
  }
}
