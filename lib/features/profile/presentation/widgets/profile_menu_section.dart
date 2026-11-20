import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/enums/app_role_mode.dart';
import '../controllers/profile_controller.dart';

/// Complete menu tile section for UnifiedProfileView with navigation and action bindings.
class ProfileMenuSection extends StatelessWidget {
  final ProfileController profileController;
  final AppRoleMode currentMode;
  final VoidCallback onOpenServices;
  final VoidCallback onOpenProjects;
  final VoidCallback onCallHelpline;
  final VoidCallback onSwitchRole;
  final VoidCallback onLogout;

  const ProfileMenuSection({
    super.key,
    required this.profileController,
    required this.currentMode,
    required this.onOpenServices,
    required this.onOpenProjects,
    required this.onCallHelpline,
    required this.onSwitchRole,
    required this.onLogout,
  });

  Widget _buildTile({
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isBn = context.isBengali;

    return Column(
      children: [
        _buildTile(
          context: context,
          icon: Icons.edit_outlined,
          title: l10n.profileEditPersonalDetails,
          subtitle: isBn
              ? 'নাম, জন্মদিন, জরুরি যোগাযোগ ও প্রাতিষ্ঠানিক তথ্য'
              : 'Name, birthday, emergency contact & organization info',
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.editDetailedProfile,
            arguments: profileController,
          ),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.location_on_outlined,
          title: l10n.profileSavedAddresses,
          subtitle: isBn
              ? 'বাসা, অফিস ও ডেলিভারি অবস্থান পরিচালনা করুন'
              : 'Manage home, office and dispatch locations',
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.savedAddresses,
            arguments: profileController,
          ),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.notifications_none_rounded,
          title: l10n.settingsNotifications,
          subtitle: isBn
              ? 'পুশ অ্যালার্ট, অডিও চাইম, এসএমএস ও হ্যাপটিক্স'
              : 'Push alerts, audio chime, SMS & haptics',
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.notificationPreferences,
            arguments: profileController,
          ),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.shield_outlined,
          title: l10n.profilePrivacySecurity,
          subtitle: isBn
              ? 'ডিভাইস সেশন, পাসওয়ার্ড রিসেট ও নিরাপত্তা নিয়ন্ত্রণ'
              : 'Device sessions, password reset & account controls',
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.privacySecurity,
            arguments: profileController,
          ),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.grid_view_outlined,
          title: l10n.profileMyBookings,
          subtitle: isBn
              ? 'বুকিং ইতিহাস, সার্ভিস রিকোয়েস্ট ও ইনভয়েস দেখুন'
              : 'View booking history, service requests and invoices',
          onTap: onOpenServices,
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.folder_outlined,
          title: l10n.profileTurnkeyProjects,
          subtitle: isBn
              ? 'বাণিজ্যিক কাজ ও টিম লিডার মাইলস্টোনসমূহ'
              : 'Enterprise deliverables & team leader milestones',
          onTap: onOpenProjects,
        ),
        const SizedBox(height: 8),
        if (currentMode == AppRoleMode.worker) ...[
          _buildTile(
            context: context,
            icon: Icons.account_balance_wallet_outlined,
            title: l10n.profilePayoutAccount,
            subtitle: isBn
                ? 'ব্যালেন্স, সম্পন্ন কাজ ও টাকা তোলার হিসাব'
                : 'Balance, completed jobs & payout history',
            onTap: () => Navigator.pushNamed(context, AppRoutes.workerEarnings),
          ),
          const SizedBox(height: 8),
        ],
        _buildTile(
          context: context,
          icon: Icons.receipt_long_outlined,
          title: isBn
              ? 'লেনদেন ইতিহাস ও ইনভয়েস'
              : 'Transaction History & Invoices',
          subtitle: isBn
              ? 'এসক্রো সেটেলমেন্ট ও ডিজিটাল ভ্যাট রসিদ'
              : 'Escrow settlements & itemized digital VAT receipts',
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.transactionHistory),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.settings_outlined,
          title: l10n.profileSettings,
          subtitle: isBn
              ? 'থিম, ভাষা, অফলাইন সিঙ্ক ও নীতিসমূহ'
              : 'Theme, language, offline sync & legal policies',
          onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.help_outline_rounded,
          title: l10n.profileHelpSupport,
          subtitle: isBn
              ? 'গাইড দেখুন অথবা ডিসপ্যাচ সাপোর্টে যোগাযোগ করুন'
              : 'Search guides or contact dispatch support',
          onTap: () => Navigator.pushNamed(context, AppRoutes.supportFaq),
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.phone_in_talk_outlined,
          title: l10n.homeHelpline,
          subtitle: isBn
              ? 'জরুরি ডিসপ্যাচ সাপোর্ট হটলাইন'
              : 'Emergency dispatch support hotline',
          onTap: onCallHelpline,
        ),
        const SizedBox(height: 8),
        _buildTile(
          context: context,
          icon: Icons.info_outline_rounded,
          title: l10n.profileAboutSkavia,
          subtitle: isBn
              ? 'প্ল্যাটফর্ম সংস্করণ ও ৯টি ট্রেড স্পেশালাইজেশন'
              : 'Platform version & 9 specialization branches',
          onTap: () => Navigator.pushNamed(context, AppRoutes.aboutSkavia),
        ),
        if (currentMode == AppRoleMode.worker) ...[
          const SizedBox(height: 8),
          _buildTile(
            context: context,
            icon: Icons.workspace_premium_outlined,
            title: l10n.workerReputationTitle,
            subtitle: isBn
                ? 'আপনার যাচাইকৃত রেটিং, ট্রাস্ট টিয়ার ও রিভিউ দেখুন'
                : 'View your verified rating, trust tier & reviews',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.workerReputation,
            ),
          ),
        ],
        const SizedBox(height: 16),
        _buildTile(
          context: context,
          icon: Icons.swap_horiz_rounded,
          title: l10n.switchAccountMode,
          subtitle: isBn
              ? 'ব্যক্তিগত, বিজনেস ও কর্মী মোড পরিবর্তন করুন'
              : 'Toggle between Customer, Business and Specialist modes',
          onTap: onSwitchRole,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: onLogout,
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
              l10n.authSignOut,
              style: const TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
