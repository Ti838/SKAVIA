import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Organized 4-Grid Action Hub (Clean, organized pastel tiles)
class DashboardActionHubGrid extends StatelessWidget {
  final VoidCallback onBookService;

  const DashboardActionHubGrid({super.key, required this.onBookService});

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final tileBg = isDark ? iconColor.withValues(alpha: 0.15) : bgColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? iconColor.withValues(alpha: 0.3)
                : iconColor.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
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
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tiles = [
          _buildActionTile(
            context: context,
            icon: Icons.handyman_rounded,
            label: AppLanguageService.tr('book_service'),
            bgColor: const Color(0xFFEFF6FF), // Soft Blue
            iconColor: AppColors.primaryRoyal,
            onTap: onBookService,
          ),
          _buildActionTile(
            context: context,
            icon: Icons.post_add_rounded,
            label: AppLanguageService.tr('post_job'),
            bgColor: const Color(0xFFFFF7ED), // Soft Peach
            iconColor: AppColors.accentCoral,
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.postRequirement),
          ),
          _buildActionTile(
            context: context,
            icon: Icons.dynamic_feed_rounded,
            label: AppLanguageService.tr('live_job_feed'),
            bgColor: const Color(0xFFF0FDF4), // Soft Mint
            iconColor: AppColors.successGreen,
            onTap: () => Navigator.pushNamed(context, AppRoutes.liveJobFeed),
          ),
          _buildActionTile(
            context: context,
            icon: Icons.auto_awesome_rounded,
            label: AppLanguageService.tr('skavia_ai'),
            bgColor: const Color(0xFFF5F3FF), // Soft Violet
            iconColor: const Color(0xFF7C3AED),
            onTap: () => Navigator.pushNamed(context, AppRoutes.skaviaAi),
          ),
        ];

        final useTwoByTwo = constraints.maxWidth < 330 || textScale > 1.3;
        if (useTwoByTwo) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[1]),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: tiles[2]),
                  const SizedBox(width: 10),
                  Expanded(child: tiles[3]),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: tiles[0]),
            const SizedBox(width: 10),
            Expanded(child: tiles[1]),
            const SizedBox(width: 10),
            Expanded(child: tiles[2]),
            const SizedBox(width: 10),
            Expanded(child: tiles[3]),
          ],
        );
      },
    );
  }
}
