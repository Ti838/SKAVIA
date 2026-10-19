import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../navigation/presentation/screens/main_scaffold_screen.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/domain/services/profile_completion_engine.dart';
import '../../../profile/presentation/widgets/profile_completion_banner_card.dart';

/// Screen 16 Complete Unified Profile View with 3 stats and menu tiles
class UnifiedProfileView extends StatelessWidget {
  final AuthController authController;
  final String? customAvatarUrl;
  final AppRoleMode currentMode;
  final VoidCallback onAvatarPick;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenProjects;
  final VoidCallback onCallHelpline;
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const UnifiedProfileView({
    super.key,
    required this.authController,
    this.customAvatarUrl,
    required this.currentMode,
    required this.onAvatarPick,
    required this.onOpenSettings,
    required this.onOpenServices,
    required this.onOpenProjects,
    required this.onCallHelpline,
    required this.onSwitchRole,
    required this.onLogout,
  });

  bool get isCustomerMode => currentMode == AppRoleMode.customer;

  @override
  Widget build(BuildContext context) {
    final user = authController.user;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top right settings gear icon
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
                onPressed: onOpenSettings,
              ),
            ],
          ),

          // 1. Identity Avatar with camera editor
          GestureDetector(
            onTap: onAvatarPick,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primarySky.withValues(alpha: 0.15),
                  backgroundImage: customAvatarUrl != null
                      ? NetworkImage(customAvatarUrl!)
                      : null,
                  child: customAvatarUrl == null
                      ? const Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: AppColors.primaryRoyal,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryRoyal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user?.displayName ?? 'Timon Biswas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.email ?? 'timon.biswas@gmail.com',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // Role Capsule Pill matching Screen 16
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRoyal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              currentMode == AppRoleMode.worker
                  ? (AppLanguageService.isBengali ? 'দক্ষ কারিগর' : 'Specialist Worker')
                  : (currentMode == AppRoleMode.enterprise
                        ? (AppLanguageService.isBengali ? 'কর্পোরেট ক্লায়েন্ট' : 'Corporate Client')
                        : (AppLanguageService.isBengali ? 'ব্যক্তিগত গ্রাহক' : 'Individual Customer')),
              style: TextStyle(
                color: currentMode == AppRoleMode.worker
                    ? AppColors.accent
                    : (currentMode == AppRoleMode.enterprise
                          ? AppColors.successGreen
                          : AppColors.primaryRoyal),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Screen 16 Stats Row: 3 Services | 2 Projects | 4.8 Rating
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStatColumn(context, '3', 'Services'),
                Container(
                  height: 32,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                _buildProfileStatColumn(context, '2', 'Projects'),
                Container(
                  height: 32,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                _buildProfileStatColumn(context, '4.8', 'Rating'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Profile Strength & Dynamic Completion Intelligence Banner
          Builder(
            builder: (context) {
              final result = ProfileCompletionEngine.evaluate(
                UserProfileModel(
                  id: user?.uid ?? 'guest',
                  email: user?.email ?? '',
                  fullName: user?.displayName ?? 'SKAVIA Member',
                  avatarUrl: customAvatarUrl,
                  phone: user?.phoneNumber,
                ),
              );
              return ProfileCompletionBannerCard(result: result);
            },
          ),
          const SizedBox(height: 16),

          // Screen 16 Menu Items
          _buildProfileTile(
            context: context,
            icon: Icons.edit_outlined,
            title: 'Edit Personal Details',
            subtitle: 'Update your name, birthday & emergency contact',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.editDetailedProfile),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Saved Delivery Addresses',
            subtitle: 'Manage home, office and dispatch locations',
            onTap: () => Navigator.pushNamed(context, AppRoutes.savedAddresses),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'Notification Preferences',
            subtitle: 'Push alerts, SMS text, email receipts & gifts',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.notificationPreferences),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'Device sessions, data consent & account controls',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.privacySecurity),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.grid_view_outlined,
            title: 'My Services',
            subtitle: 'View booking history and services',
            onTap: onOpenServices,
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.folder_outlined,
            title: 'My Projects',
            subtitle: 'Enterprise deliverables & team leader milestones',
            onTap: onOpenProjects,
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet & Payment',
            subtitle: 'Automated payout & payment methods',
            onTap: () => Navigator.pushNamed(context, AppRoutes.workerEarnings),
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Preferences, theme & language options',
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 8),
          _buildProfileTile(
            context: context,
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Call emergency dispatch support line: 16524',
            onTap: onCallHelpline,
          ),
          if (!isCustomerMode) ...[
            const SizedBox(height: 8),
            _buildProfileTile(
              context: context,
              icon: Icons.workspace_premium_outlined,
              title: 'Worker Reputation & Badges',
              subtitle: 'View your verified rating, trust tier & reviews',
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.workerReputation),
            ),
          ],
          const SizedBox(height: 16),

          // Switch Role Mode Tile
          _buildProfileTile(
            context: context,
            icon: Icons.swap_horiz_rounded,
            title: AppLanguageService.tr('switch_mode'),
            subtitle: AppLanguageService.isBengali
                ? 'ব্যক্তিগত, কর্পোরেট ও কারিগর মোড পরিবর্তন করুন'
                : 'Toggle between Customer, Business and Specialist modes',
            onTap: onSwitchRole,
          ),
          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onLogout,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorRed, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: Text(
                AppLanguageService.tr('logout'),
                style: const TextStyle(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatColumn(
    BuildContext context,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.errorRed.withValues(alpha: 0.05)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? AppColors.errorRed.withValues(alpha: 0.2)
                : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorRed.withValues(alpha: 0.12)
                    : colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? AppColors.errorRed
                    : AppColors.primarySky,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDestructive
                          ? AppColors.errorRed
                          : colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDestructive
                          ? AppColors.errorRed.withValues(alpha: 0.8)
                          : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: isDestructive
                  ? AppColors.errorRed
                  : colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
