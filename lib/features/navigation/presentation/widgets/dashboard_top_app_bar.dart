import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../screens/main_scaffold_screen.dart';

/// Top App Bar matching Reference Board: User Avatar, SKAVIA Brand Logo,
/// Notification Bell, and responsive header pills (GPS, Mode switcher, Lang, AI).
class DashboardTopAppBar extends StatelessWidget {
  final String? customAvatarUrl;
  final bool hasUnreadNotifications;
  final String currentLocationZone;
  final bool isLocating;
  final bool isGpsVerified;
  final AppRoleMode currentMode;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onLocationTap;
  final ValueChanged<AppRoleMode> onModeSwitch;

  const DashboardTopAppBar({
    super.key,
    required this.customAvatarUrl,
    required this.hasUnreadNotifications,
    required this.currentLocationZone,
    required this.isLocating,
    required this.isGpsVerified,
    required this.currentMode,
    required this.onAvatarTap,
    required this.onNotificationsTap,
    required this.onLocationTap,
    required this.onModeSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isBn = AppLanguageService.isBengali;

    final pillBg = isDark
        ? colorScheme.surfaceContainerHighest
        : AppColors.sheetSurfaceSubtle;
    final pillBorder = colorScheme.outlineVariant;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Row 1: Profile Avatar, SKAVIA Brand Logo, Notification Bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Avatar
              UserAvatar(
                imageUrl: customAvatarUrl,
                name: 'SKAVIA',
                radius: 18,
                onTap: onAvatarTap,
              ),

              // Centered Official SKAVIA Logo
              SkaviaBrandImage(
                assetPath: AppAssets.logo,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SkaviaBrandImage(
                      assetPath: AppAssets.emblem,
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.engineering_rounded,
                        size: 20,
                        color: AppColors.primarySky,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SKAVIA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.primaryRoyal,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification Bell Icon with Badge
              GestureDetector(
                onTap: onNotificationsTap,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: pillBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: pillBorder),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (hasUnreadNotifications)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Location Chip, Mode Switcher, Language Toggle, and SKAVIA AI Pill
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                // GPS Location Pill
                GestureDetector(
                  onTap: onLocationTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: AppDimensions.roundedPill,
                      border: Border.all(color: pillBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocating)
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        else
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: isGpsVerified
                                ? AppColors.accentAqua
                                : colorScheme.primary,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          currentLocationZone,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Mode Switcher Pill (Customer | Business | Worker)
                Container(
                  height: 28,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius: AppDimensions.roundedPill,
                    border: Border.all(color: pillBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Client
                      GestureDetector(
                        onTap: () => onModeSwitch(AppRoleMode.customer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: currentMode == AppRoleMode.customer
                                ? (isDark
                                      ? colorScheme.primary
                                      : AppColors.primaryRoyal)
                                : Colors.transparent,
                            borderRadius: AppDimensions.roundedPill,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguageService.tr('client'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: currentMode == AppRoleMode.customer
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      // 2. Business / Corporate
                      GestureDetector(
                        onTap: () => onModeSwitch(AppRoleMode.enterprise),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: currentMode == AppRoleMode.enterprise
                                ? (isDark
                                      ? colorScheme.primary
                                      : AppColors.successGreen)
                                : Colors.transparent,
                            borderRadius: AppDimensions.roundedPill,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguageService.tr('business'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: currentMode == AppRoleMode.enterprise
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      // 3. Worker
                      GestureDetector(
                        onTap: () => onModeSwitch(AppRoleMode.worker),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: currentMode == AppRoleMode.worker
                                ? (isDark
                                      ? colorScheme.primary
                                      : AppColors.accent)
                                : Colors.transparent,
                            borderRadius: AppDimensions.roundedPill,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppLanguageService.tr('worker'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: currentMode == AppRoleMode.worker
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Live Feed Shortcut Pill
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.liveJobFeed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: pillBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dynamic_feed_rounded,
                          size: 11,
                          color: isDark
                              ? colorScheme.primary
                              : AppColors.primaryRoyal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isBn ? 'ফিড' : 'Feed',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Language Switcher
                GestureDetector(
                  onTap: AppLanguageService.toggleLanguage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: pillBorder),
                    ),
                    child: Text(
                      isBn ? 'Eng' : 'বাংলা',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // SKAVIA AI Pill
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.skaviaAi),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: context.skavia.softVioletBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF6B21A8)
                            : const Color(0xFFDDD6FE),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: isDark
                              ? const Color(0xFFC084FC)
                              : const Color(0xFF7C3AED),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'SKAVIA AI',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFC084FC)
                                : const Color(0xFF7C3AED),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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
