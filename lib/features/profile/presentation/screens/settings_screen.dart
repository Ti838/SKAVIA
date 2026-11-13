import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/services/app_theme_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/account_deletion_dialog.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../app_update/data/models/app_release_model.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../navigation/presentation/widgets/legal_policies_sheet.dart';
import '../controllers/profile_controller.dart';

class SettingsScreen extends StatefulWidget {
  final AuthController? authController;
  final ProfileController? profileController;

  const SettingsScreen({
    super.key,
    this.authController,
    this.profileController,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AuthController? _ownedAuth;
  bool _isSyncing = false;

  AuthController get _auth =>
      widget.authController ?? (_ownedAuth ??= AuthController());

  ProfileController get _profileController =>
      widget.profileController ?? ProfileController.shared;

  @override
  void initState() {
    super.initState();
    _profileController.loadCurrentUserIfNeeded();
  }

  @override
  void dispose() {
    _ownedAuth?.dispose();
    super.dispose();
  }

  Future<void> _callHelpline() async {
    final uri = Uri(scheme: 'tel', path: '16524');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    } catch (_) {}
    if (mounted) {
      UiFeedbackHelper.showInfo(
        context,
        'Emergency Helpline: 16524 (24/7 SKAVIA Support)',
      );
    }
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    final processed = await OfflineSyncQueueManager.instance.processQueue();
    if (!mounted) return;
    setState(() => _isSyncing = false);
    UiFeedbackHelper.showSuccess(
      context,
      processed > 0
          ? 'Synced $processed queued offline change(s).'
          : 'All queued changes are up to date.',
    );
  }

  Future<void> _clearCache() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Clear Cached Data?',
      message:
          'This removes locally cached service catalogs and stats. Your account and pending sync items are preserved.',
      confirmText: 'Clear Cache',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      LocalCacheService.instance.clear();
      setState(() {});
      UiFeedbackHelper.showSuccess(context, 'Local cache cleared.');
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign Out of SKAVIA?',
      message: 'You will need to sign in again to manage bookings and chats.',
      confirmText: AppLanguageService.tr('logout'),
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await _auth.logout();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return ValueListenableBuilder<String>(
      valueListenable: AppLanguageService.localeNotifier,
      builder: (context, _, _) {
        final isBn = AppLanguageService.isBengali;

        return Scaffold(
          appBar: AppAppBar(
            title: isBn ? 'সেটিংস ও পছন্দসমূহ' : 'Settings & Preferences',
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              children: [
                _sectionTitle(context, isBn ? 'থিম ও ভাষা' : 'Appearance & Language'),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'অ্যাপ থিম মোড' : 'Theme Mode',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ValueListenableBuilder<ThemeMode>(
                        valueListenable: AppThemeService.themeModeNotifier,
                        builder: (context, mode, _) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              (
                                ThemeMode.system,
                                isBn ? 'অটো (সিস্টেম)' : 'Auto',
                                Icons.brightness_auto_rounded,
                              ),
                              (
                                ThemeMode.light,
                                isBn ? 'লাইট' : 'Light',
                                Icons.light_mode_rounded,
                              ),
                              (
                                ThemeMode.dark,
                                isBn ? 'ডার্ক' : 'Dark',
                                Icons.dark_mode_rounded,
                              ),
                            ].map((item) {
                              final selected = mode == item.$1;
                              return _buildOptionPill(
                                context,
                                icon: item.$3,
                                label: item.$2,
                                selected: selected,
                                onTap: () =>
                                    AppThemeService.setThemeMode(item.$1),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      Divider(color: tokens.subtleBorder, height: 22),
                      Text(
                        isBn ? 'অ্যাপের ভাষা' : 'App Language',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildOptionPill(
                            context,
                            label: 'English',
                            selected: !isBn,
                            onTap: () => AppLanguageService.setLanguage('en'),
                          ),
                          _buildOptionPill(
                            context,
                            label: 'বাংলা (Bengali)',
                            selected: isBn,
                            onTap: () => AppLanguageService.setLanguage('bn'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _sectionTitle(
                  context,
                  isBn ? 'অ্যাকাউন্ট ও নিরাপত্তা' : 'Account & Security',
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _navTile(
                        context,
                        icon: Icons.person_outline_rounded,
                        title: isBn ? 'ব্যক্তিগত তথ্য' : 'Personal Details',
                        subtitle: 'Name, birthday, emergency contact & company',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.editDetailedProfile,
                          arguments: _profileController,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.location_on_outlined,
                        title: isBn ? 'সংরক্ষিত ঠিকানা' : 'Saved Addresses',
                        subtitle: 'Home, office & default dispatch zones',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.savedAddresses,
                          arguments: _profileController,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.notifications_active_outlined,
                        title: isBn
                            ? 'নোটিফিকেশন ও শব্দ'
                            : 'Notifications, Chime & Haptics',
                        subtitle: 'Channels, custom alert chime & vibration',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.notificationPreferences,
                          arguments: _profileController,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.shield_outlined,
                        title: isBn ? 'প্রাইভেসি ও নিরাপত্তা' : 'Privacy & Security',
                        subtitle: 'Active devices, password reset & deactivation',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.privacySecurity,
                          arguments: _profileController,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.receipt_long_outlined,
                        title: isBn
                            ? 'লেনদেন ও ভ্যাট ইনভয়েস'
                            : 'Transaction History & Invoices',
                        subtitle: 'Payment receipts and escrow settlements',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.transactionHistory,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _sectionTitle(
                  context,
                  isBn ? 'অফলাইন সিঙ্ক ও স্টোরেজ' : 'Offline Sync & Storage',
                ),
                const SizedBox(height: 8),
                StreamBuilder<int>(
                  stream: OfflineSyncQueueManager.instance.pendingCountStream,
                  initialData: OfflineSyncQueueManager.instance.pendingCount,
                  builder: (context, snapshot) {
                    final pending = snapshot.data ?? 0;
                    final cachedItems = LocalCacheService.instance.count;
                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$pending pending offline item(s) • $cachedItems cached record(s)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: _isSyncing ? null : _syncNow,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _isSyncing
                                        ? const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.sync_rounded,
                                            size: 16,
                                          ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _isSyncing ? 'Syncing...' : 'Sync Now',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton(
                                onPressed: _clearCache,
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cleaning_services_outlined,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(child: Text('Clear Cache')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),
                _sectionTitle(
                  context,
                  isBn ? 'সহায়তা ও আইনি তথ্য' : 'Support, Complaints & Legal',
                ),
                const SizedBox(height: 8),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _navTile(
                        context,
                        icon: Icons.help_outline_rounded,
                        title: isBn ? 'সহায়তা ও প্রশ্নোত্তর (FAQ)' : 'Help Center & FAQ',
                        subtitle: 'Escrow rules, OTP guide & quick answers',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.supportFaq,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.report_problem_outlined,
                        title: isBn ? 'অভিযোগ জমা দিন' : 'File a Formal Complaint',
                        subtitle: 'Report quality, delay, billing or conduct issues',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.submitComplaint,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.phone_in_talk_outlined,
                        title: isBn ? '২৪/৭ হেল্পলাইন: ১৬৫২৪' : '24/7 Helpline: 16524',
                        subtitle: 'Immediate dispatch and emergency assistance',
                        onTap: _callHelpline,
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.policy_outlined,
                        title: isBn
                            ? 'আইনি নীতিমালা ও ১৫% স্বচ্ছ ফি'
                            : 'Legal Policies & 15% Fee Schedule',
                        subtitle: 'Terms, privacy & escrow protection rules',
                        onTap: () => LegalPoliciesSheet.show(context),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      AnimatedBuilder(
                        animation: AppUpdateProvider.instance,
                        builder: (context, _) {
                          final eval = AppUpdateProvider.instance.evaluation;
                          final subtitle = eval == null
                              ? 'Check for official SKAVIA Android releases'
                              : eval.updateAvailable
                                  ? 'Update ready: v${eval.latestRelease?.versionName} (${eval.latestRelease?.formattedSize ?? 'APK'})'
                                  : eval.status == AppUpdateAvailability.upToDate
                                      ? 'Up to date · v${eval.installedVersion}+${eval.installedBuild}'
                                      : 'Version check & release verification';
                          return _navTile(
                            context,
                            icon: Icons.system_update_rounded,
                            title: isBn ? 'অ্যাপ আপডেট' : 'App Updates & Releases',
                            subtitle: subtitle,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.appUpdate,
                            ),
                          );
                        },
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      _navTile(
                        context,
                        icon: Icons.info_outline_rounded,
                        title: isBn ? 'SKAVIA সম্পর্কে' : 'About SKAVIA',
                        subtitle: 'App version, 9 specialization branches & mission',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.aboutSkavia,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever_rounded,
                          color: AppColors.errorRed,
                        ),
                        title: Text(
                          AppLanguageService.tr('delete_account'),
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => AccountDeletionDialog.show(
                          context,
                          authController: _auth,
                        ),
                      ),
                      Divider(color: tokens.subtleBorder, height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.errorRed,
                        ),
                        title: Text(
                          AppLanguageService.tr('logout'),
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: _confirmSignOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildOptionPill(
    BuildContext context, {
    IconData? icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? tokens.brandAccent.withValues(alpha: 0.14)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? tokens.brandAccent : tokens.subtleBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected
                    ? tokens.brandAccent
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? tokens.brandAccent
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;
    return ListTile(
      leading: Icon(icon, color: tokens.brandAccent),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

