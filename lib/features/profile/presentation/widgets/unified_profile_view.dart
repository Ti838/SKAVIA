import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../customer/presentation/widgets/avatar_picker_sheet.dart';
import '../../../navigation/presentation/screens/main_scaffold_screen.dart';
import '../../data/models/user_profile_model.dart';
import '../../domain/services/profile_completion_engine.dart';
import '../controllers/profile_controller.dart';
import 'profile_completion_banner_card.dart';

/// Screen 16 Complete Unified Profile View with live stats, completion strength, and menu tiles.
class UnifiedProfileView extends StatefulWidget {
  final AuthController authController;
  final ProfileController? profileController;
  final String? customAvatarUrl;
  final String? customCoverUrl;
  final AppRoleMode currentMode;
  final VoidCallback onAvatarPick;
  final VoidCallback? onCoverPick;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenProjects;
  final VoidCallback onCallHelpline;
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const UnifiedProfileView({
    super.key,
    required this.authController,
    this.profileController,
    this.customAvatarUrl,
    this.customCoverUrl,
    required this.currentMode,
    required this.onAvatarPick,
    this.onCoverPick,
    required this.onOpenSettings,
    required this.onOpenServices,
    required this.onOpenProjects,
    required this.onCallHelpline,
    required this.onSwitchRole,
    required this.onLogout,
  });

  @override
  State<UnifiedProfileView> createState() => _UnifiedProfileViewState();
}

class _UnifiedProfileViewState extends State<UnifiedProfileView> {
  ProfileController get _profileController =>
      widget.profileController ?? ProfileController.shared;

  bool get isCustomerMode => widget.currentMode == AppRoleMode.customer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = widget.authController.user;
      _profileController.loadCurrentUserIfNeeded(
        userId: user?.uid,
        fallbackEmail: user?.email,
        fallbackName: user?.displayName,
        fallbackPhone: user?.phoneNumber,
        fallbackAvatarUrl: widget.customAvatarUrl ?? user?.photoURL,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.user;
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    final isBn = AppLanguageService.isBengali;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);

    return ListenableBuilder(
      listenable: _profileController,
      builder: (context, _) {
        final profile = _profileController.profile;
        final stats = _profileController.stats;

        final displayName = (profile?.fullName.isNotEmpty == true &&
                profile!.fullName != 'SKAVIA Member')
            ? profile.fullName
            : (user?.displayName?.isNotEmpty == true
                  ? user!.displayName!
                  : 'SKAVIA Member');

        final contactLabel = (profile?.email.isNotEmpty == true &&
                profile!.email != 'user@skavia.com')
            ? profile.email
            : (user?.email?.isNotEmpty == true
                  ? user!.email!
                  : (profile?.phone ??
                        user?.phoneNumber ??
                        'Complete your contact info'));

        final effectiveAvatarUrl =
            widget.customAvatarUrl ?? profile?.avatarUrl ?? user?.photoURL;
        final rawCoverUrl = widget.customCoverUrl ?? profile?.coverUrl;
        final effectiveCoverUrl =
            (rawCoverUrl != null &&
                rawCoverUrl.trim().isNotEmpty &&
                (rawCoverUrl.startsWith('http://') ||
                    rawCoverUrl.startsWith('https://')))
            ? rawCoverUrl.trim()
            : null;

        final effectiveProfile = profile ??
            UserProfileModel(
              id: user?.uid ?? 'guest',
              email: user?.email ?? '',
              fullName: displayName,
              avatarUrl: effectiveAvatarUrl,
              coverUrl: effectiveCoverUrl,
              phone: user?.phoneNumber,
            );

        final completionResult =
            ProfileCompletionEngine.evaluate(effectiveProfile);

        final roleLabel = widget.currentMode == AppRoleMode.worker
            ? (isBn ? 'দক্ষ কারিগর' : 'Specialist Worker')
            : (widget.currentMode == AppRoleMode.enterprise
                  ? (profile?.customerType == 'Organization'
                        ? 'Organization'
                        : (isBn ? 'কর্পোরেট ক্লায়েন্ট' : 'Business Client'))
                  : (isBn ? 'ব্যক্তিগত গ্রাহক' : 'Individual Customer'));

        final roleAccent = widget.currentMode == AppRoleMode.worker
            ? AppColors.accent
            : (widget.currentMode == AppRoleMode.enterprise
                  ? AppColors.successGreen
                  : tokens.brandAccent);

        void handleCoverTap() {
          if (widget.onCoverPick != null) {
            widget.onCoverPick!();
            return;
          }
          AvatarPickerSheet.show(
            context,
            currentAvatarUrl: effectiveCoverUrl,
            userId: user?.uid ?? profile?.id,
            slot: ProfileMediaSlot.cover,
            onAvatarSelected: (_) {
              if (mounted) setState(() {});
            },
          );
        }

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Facebook-style Cover Banner + Overlapping Circular Profile Photo
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Container(
                      height: 152,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: tokens.border),
                        gradient: effectiveCoverUrl == null
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryRoyal.withValues(alpha: 0.9),
                                  tokens.brandAccent.withValues(alpha: 0.78),
                                ],
                              )
                            : null,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (effectiveCoverUrl != null)
                            Image.network(
                              effectiveCoverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primaryRoyal.withValues(
                                        alpha: 0.9,
                                      ),
                                      tokens.brandAccent.withValues(
                                        alpha: 0.78,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.36),
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                tooltip: 'Settings',
                                onPressed: widget.onOpenSettings,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: InkWell(
                              onTap: handleCoverTap,
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.56),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      effectiveCoverUrl == null
                                          ? (isBn ? 'কভার যোগ করুন' : 'Add Cover')
                                          : (isBn ? 'কভার বদলান' : 'Edit Cover'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onAvatarPick,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: UserAvatar(
                            imageUrl: effectiveAvatarUrl,
                            name: displayName,
                            radius: 40,
                            isVerified:
                                effectiveProfile.verificationStatus == 'verified',
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: tokens.brandAccent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: tokens.onBrandAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                contactLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if ((profile?.companyName ?? '').isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  profile!.companyName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: tokens.brandAccent,
                  ),
                ),
              ],
              const SizedBox(height: 8),

              // Role Capsule Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: roleAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  roleLabel,
                  style: TextStyle(
                    color: roleAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Real Profile Activity Stats Card
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 300 || textScale > 1.45;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: tokens.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: compact
                        ? Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              _buildProfileStatColumn(
                                context,
                                '${stats.servicesCount}',
                                'Services',
                              ),
                              _buildProfileStatColumn(
                                context,
                                '${stats.projectsCount}',
                                'Projects',
                              ),
                              _buildProfileStatColumn(
                                context,
                                stats.ratingAverage.toStringAsFixed(1),
                                'Rating',
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildProfileStatColumn(
                                  context,
                                  '${stats.servicesCount}',
                                  'Services',
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: tokens.border,
                              ),
                              Expanded(
                                child: _buildProfileStatColumn(
                                  context,
                                  '${stats.projectsCount}',
                                  'Projects',
                                ),
                              ),
                              Container(
                                height: 32,
                                width: 1,
                                color: tokens.border,
                              ),
                              Expanded(
                                child: _buildProfileStatColumn(
                                  context,
                                  stats.ratingAverage.toStringAsFixed(1),
                                  'Rating',
                                ),
                              ),
                            ],
                          ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Profile Strength & Dynamic Completion Intelligence Banner
              ProfileCompletionBannerCard(
                result: completionResult,
                onActionTap: completionResult.nextRecommendedAction != null
                    ? () => Navigator.pushNamed(
                        context,
                        completionResult.nextRecommendedAction!.actionRoute,
                        arguments: _profileController,
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Menu Tiles
              _buildProfileTile(
                context: context,
                icon: Icons.edit_outlined,
                title: 'Edit Personal Details',
                subtitle: 'Name, birthday, emergency contact & organization info',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.editDetailedProfile,
                  arguments: _profileController,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.location_on_outlined,
                title: 'Saved Delivery Addresses',
                subtitle: 'Manage home, office and dispatch locations',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.savedAddresses,
                  arguments: _profileController,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.notifications_none_rounded,
                title: 'Notification Preferences',
                subtitle: 'Push alerts, audio chime, SMS & haptics',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.notificationPreferences,
                  arguments: _profileController,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.shield_outlined,
                title: 'Privacy & Security',
                subtitle: 'Device sessions, password reset & account controls',
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.privacySecurity,
                  arguments: _profileController,
                ),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.grid_view_outlined,
                title: 'My Services',
                subtitle: 'View booking history and service requests',
                onTap: widget.onOpenServices,
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.folder_outlined,
                title: 'My Projects',
                subtitle: 'Enterprise deliverables & team leader milestones',
                onTap: widget.onOpenProjects,
              ),
              const SizedBox(height: 8),
              if (widget.currentMode == AppRoleMode.worker) ...[
                _buildProfileTile(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Worker Wallet & Payouts',
                  subtitle: 'Balance, completed jobs & payout history',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.workerEarnings),
                ),
                const SizedBox(height: 8),
              ],
              _buildProfileTile(
                context: context,
                icon: Icons.receipt_long_outlined,
                title: 'Transaction History & Invoices',
                subtitle: 'Escrow settlements & itemized digital VAT receipts',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.transactionHistory),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Theme, language, offline sync & legal policies',
                onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'Help Center & FAQ',
                subtitle: 'Search guides or contact dispatch support',
                onTap: () => Navigator.pushNamed(context, AppRoutes.supportFaq),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.report_problem_outlined,
                title: 'Submit a Complaint',
                subtitle: 'Escalate quality, billing or behavior concerns',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.submitComplaint),
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.phone_in_talk_outlined,
                title: '24/7 Helpline: 16524',
                subtitle: 'Emergency dispatch support hotline',
                onTap: widget.onCallHelpline,
              ),
              const SizedBox(height: 8),
              _buildProfileTile(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'About SKAVIA',
                subtitle: 'Platform version & 9 specialization branches',
                onTap: () => Navigator.pushNamed(context, AppRoutes.aboutSkavia),
              ),
              if (!isCustomerMode) ...[
                const SizedBox(height: 8),
                _buildProfileTile(
                  context: context,
                  icon: Icons.workspace_premium_outlined,
                  title: 'Worker Reputation & Badges',
                  subtitle: 'View your verified rating, trust tier & reviews',
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.workerReputation,
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Switch Role Mode Tile
              _buildProfileTile(
                context: context,
                icon: Icons.swap_horiz_rounded,
                title: AppLanguageService.tr('switch_mode'),
                subtitle: isBn
                    ? 'ব্যক্তিগত, কর্পোরেট ও কারিগর মোড পরিবর্তন করুন'
                    : 'Toggle between Customer, Business and Specialist modes',
                onTap: widget.onSwitchRole,
              ),
              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onLogout,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.errorRed,
                      width: 1.2,
                    ),
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
      },
    );
  }

  Widget _buildProfileStatColumn(
    BuildContext context,
    String value,
    String label,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
    final tokens = context.skavia;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.errorRed.withValues(alpha: 0.06)
              : tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? AppColors.errorRed.withValues(alpha: 0.25)
                : tokens.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? AppColors.errorRed.withValues(alpha: 0.14)
                    : tokens.cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.errorRed : tokens.brandAccent,
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
                          ? AppColors.errorRed.withValues(alpha: 0.85)
                          : colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
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
