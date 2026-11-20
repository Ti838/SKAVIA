import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/network/offline_sync_queue_manager.dart';
import '../../../../core/services/app_language_service.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/account_deletion_dialog.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/settings_account_security_section.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/settings_storage_sync_section.dart';
import '../widgets/settings_support_legal_section.dart';

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
      UiFeedbackHelper.showInfo(context, 'Local cache cleared.');
      setState(() {});
    }
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign Out?',
      message: 'Are you sure you want to log out of your SKAVIA account?',
      confirmText: 'Log Out',
      isDestructive: true,
    );
    if (confirmed == true && mounted) {
      await _auth.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Settings & Preferences'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsAppearanceSection(),
              const SizedBox(height: 20),
              SettingsAccountSecuritySection(
                profileController: _profileController,
              ),
              const SizedBox(height: 20),
              SettingsStorageSyncSection(
                isSyncing: _isSyncing,
                onSyncNow: _syncNow,
                onClearCache: _clearCache,
              ),
              const SizedBox(height: 20),
              SettingsSupportLegalSection(
                onCallHelpline: _callHelpline,
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
                    const Divider(height: 1),
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
      ),
    );
  }
}
