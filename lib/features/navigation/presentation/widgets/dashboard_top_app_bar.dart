import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/app_language_service.dart';
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
    final isBn = AppLanguageService.isBengali;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          // Row 1: Profile Avatar, SKAVIA Brand Logo, Notification Bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Avatar
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySky.withValues(alpha: 0.15),
                  backgroundImage: customAvatarUrl != null
                      ? NetworkImage(customAvatarUrl!)
                      : null,
                  child: customAvatarUrl == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: AppColors.primaryRoyal,
                        )
                      : null,
                ),
              ),

              // Centered Official SKAVIA Logo
              Image.asset(
                AppAssets.logo,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAssets.emblem,
                      height: 22,
                      width: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.engineering_rounded,
                        size: 20,
                        color: AppColors.primaryRoyal,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SKAVIA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.primaryRoyal,
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
                        color: AppColors.sheetSurfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 20,
                        color: AppColors.textDark,
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
                      color: AppColors.sheetSurfaceSubtle,
                      borderRadius: AppDimensions.roundedPill,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isLocating)
                          const SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryRoyal,
                            ),
                          )
                        else
                          Icon(
                            Icons.location_on_rounded,
                            size: 13,
                            color: isGpsVerified
                                ? AppColors.accentAqua
                                : AppColors.primaryRoyal,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          currentLocationZone,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.textMedium,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                // Mode Switcher Pill (Customer | Worker)
                Container(
                  height: 28,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.sheetSurfaceSubtle,
                    borderRadius: AppDimensions.roundedPill,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => onModeSwitch(AppRoleMode.customer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: currentMode == AppRoleMode.customer
                                ? AppColors.primaryRoyal
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
                                  : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onModeSwitch(AppRoleMode.worker),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: currentMode == AppRoleMode.worker
                                ? AppColors.primaryRoyal
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
                                  : AppColors.textMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                      color: AppColors.sheetSurfaceSubtle,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      isBn ? 'Eng' : 'বাংলা',
                      style: const TextStyle(
                        color: AppColors.textDark,
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
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 11,
                          color: Color(0xFF7C3AED),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'SKAVIA AI',
                          style: TextStyle(
                            color: Color(0xFF7C3AED),
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
