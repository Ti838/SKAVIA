import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../screens/main_scaffold_screen.dart';
import 'role_switch_bottom_sheet.dart';
import 'theme_picker_sheet.dart';

/// Global SKAVIA top header with true-centered brand emblem, synchronized user
/// avatar, accessible theme/notification controls, and a zero-overflow
/// responsive utility bar (Location · Role · Language).
class DashboardTopAppBar extends StatelessWidget {
  final String? customAvatarUrl;
  final String userName;
  final bool hasUnreadNotifications;
  final int unreadNotificationCount;
  final String currentLocationZone;
  final bool isLocating;
  final bool isGpsVerified;
  final AppRoleMode currentMode;
  final String? customerTypeLabel;
  final Set<AppRoleMode>? authorizedModes;
  final VoidCallback onAvatarTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onLocationTap;
  final ValueChanged<AppRoleMode> onModeSwitch;
  final ValueChanged<AppRoleMode>? onSetupRole;

  const DashboardTopAppBar({
    super.key,
    required this.customAvatarUrl,
    this.userName = '',
    required this.hasUnreadNotifications,
    this.unreadNotificationCount = 0,
    required this.currentLocationZone,
    required this.isLocating,
    required this.isGpsVerified,
    required this.currentMode,
    this.customerTypeLabel,
    this.authorizedModes,
    required this.onAvatarTap,
    required this.onNotificationsTap,
    required this.onLocationTap,
    required this.onModeSwitch,
    this.onSetupRole,
  });

  String _roleLabel(AppLocalizations l10n) {
    switch (currentMode) {
      case AppRoleMode.customer:
        return l10n.roleClientShort;
      case AppRoleMode.enterprise:
        if (customerTypeLabel?.toLowerCase().contains('org') == true) {
          return l10n.roleOrganization;
        }
        return l10n.roleBusinessShort;
      case AppRoleMode.worker:
        return l10n.roleWorkerShort;
    }
  }

  IconData _roleIcon() {
    switch (currentMode) {
      case AppRoleMode.customer:
        return Icons.person_outline_rounded;
      case AppRoleMode.enterprise:
        return Icons.business_center_outlined;
      case AppRoleMode.worker:
        return Icons.handyman_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;
    final l10n = context.l10n;
    final isBn = context.isBengali;

    final Color roleBg;
    final Color roleFg;
    switch (currentMode) {
      case AppRoleMode.customer:
        roleBg = colorScheme.primaryContainer;
        roleFg = colorScheme.onPrimaryContainer;
        break;
      case AppRoleMode.enterprise:
        roleBg = colorScheme.secondaryContainer;
        roleFg = colorScheme.onSecondaryContainer;
        break;
      case AppRoleMode.worker:
        roleBg = colorScheme.tertiaryContainer;
        roleFg = colorScheme.onTertiaryContainer;
        break;
    }

    final showUnread = hasUnreadNotifications || unreadNotificationCount > 0;

    return Material(
      color: colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: tokens.border, width: 1)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Synchronized User Avatar, True-Centered Logo, Theme & Bell
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: UserAvatar(
                        imageUrl: customAvatarUrl,
                        name: userName,
                        radius: 18,
                        onTap: onAvatarTap,
                      ),
                    ),
                    SkaviaBrandImage(
                      assetPath: AppAssets.logo,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SkaviaBrandImage(
                            assetPath: AppAssets.emblem,
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.engineering_rounded,
                              size: 20,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SKAVIA',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: AppThemeService.themeModeNotifier,
                            builder: (context, mode, _) {
                              final IconData themeIcon;
                              final String themeTooltip;
                              switch (mode) {
                                case ThemeMode.light:
                                  themeIcon = Icons.light_mode_outlined;
                                  themeTooltip = isBn
                                      ? 'লাইট মোড'
                                      : 'Light Mode';
                                  break;
                                case ThemeMode.dark:
                                  themeIcon = Icons.dark_mode_outlined;
                                  themeTooltip = isBn
                                      ? 'ডার্ক মোড'
                                      : 'Dark Mode';
                                  break;
                                case ThemeMode.system:
                                  themeIcon = Icons.brightness_auto_outlined;
                                  themeTooltip = isBn
                                      ? 'সিস্টেম থিম'
                                      : 'System Theme';
                                  break;
                              }

                              return Tooltip(
                                message: themeTooltip,
                                child: InkWell(
                                  onTap: () => ThemePickerSheet.show(context),
                                  onLongPress: () =>
                                      AppThemeService.cycleThemeMode(),
                                  borderRadius: AppDimensions.roundedPill,
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: tokens.subtleCardBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: tokens.border),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      themeIcon,
                                      size: 19,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: l10n.headerNotificationsTooltip,
                            child: InkWell(
                              onTap: onNotificationsTap,
                              borderRadius: AppDimensions.roundedPill,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: tokens.subtleCardBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: tokens.border),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.notifications_none_rounded,
                                      size: 20,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  if (showUnread)
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        width: 9,
                                        height: 9,
                                        decoration: BoxDecoration(
                                          color: tokens.error,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: colorScheme.surface,
                                            width: 1.5,
                                          ),
                                        ),
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
              ),
              const SizedBox(height: 8),

              // Row 2: Zero-Overflow Responsive Utility Bar (Location | Role | Lang)
              LayoutBuilder(
                builder: (context, constraints) {
                  final textScale = MediaQuery.textScalerOf(context).scale(1.0);
                  final compact =
                      constraints.maxWidth < 310 || textScale > 1.35;

                  final locationPill = InkWell(
                    onTap: onLocationTap,
                    borderRadius: AppDimensions.roundedPill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.subtleCardBg,
                        borderRadius: AppDimensions.roundedPill,
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLocating)
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            )
                          else
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: isGpsVerified
                                  ? tokens.tealAccent
                                  : colorScheme.primary,
                            ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentLocationZone,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: tokens.secondaryText,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  );

                  final rolePill = InkWell(
                    onTap: () => RoleSwitchBottomSheet.show(
                      context,
                      currentMode: currentMode,
                      authorizedModes: authorizedModes,
                      onRoleSelected: onModeSwitch,
                      onSetupRole: onSetupRole,
                    ),
                    borderRadius: AppDimensions.roundedPill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: roleBg,
                        borderRadius: AppDimensions.roundedPill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_roleIcon(), size: 14, color: roleFg),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 88),
                            child: Text(
                              _roleLabel(l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: roleFg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.swap_horiz_rounded,
                            size: 14,
                            color: roleFg,
                          ),
                        ],
                      ),
                    ),
                  );

                  final langPill = InkWell(
                    onTap: AppLanguageService.toggleLanguage,
                    borderRadius: AppDimensions.roundedPill,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.subtleCardBg,
                        borderRadius: AppDimensions.roundedPill,
                        border: Border.all(color: tokens.border),
                      ),
                      child: Text(
                        isBn ? 'EN' : 'বাংলা',
                        maxLines: 1,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );

                  if (compact) {
                    return SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [locationPill, rolePill, langPill],
                      ),
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: locationPill,
                        ),
                      ),
                      const SizedBox(width: 8),
                      rolePill,
                      const SizedBox(width: 6),
                      langPill,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
