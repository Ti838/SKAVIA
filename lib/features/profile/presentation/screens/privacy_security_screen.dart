import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/account_deletion_dialog.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/session_device_card.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final ProfileController controller;

  const PrivacySecurityScreen({super.key, required this.controller});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final AuthController _authController = AuthController();
  bool _isSendingReset = false;
  bool _isRevokingAll = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await widget.controller.loadCurrentUserIfNeeded();
    await widget.controller.loadSessions();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordReset() async {
    final email = widget.controller.profile?.email.trim() ?? '';
    if (email.isEmpty || !email.contains('@')) {
      UiFeedbackHelper.showError(
        context,
        'Add a valid email address in Personal Details first.',
      );
      return;
    }
    setState(() => _isSendingReset = true);
    final ok = await _authController.sendPasswordResetEmail(email);
    if (!mounted) return;
    setState(() => _isSendingReset = false);
    if (ok) {
      UiFeedbackHelper.showSuccess(
        context,
        'Password reset link sent to $email',
      );
    } else {
      UiFeedbackHelper.showError(
        context,
        _authController.errorMessage ?? 'Unable to send reset email.',
      );
    }
  }

  Future<void> _revokeOtherSessions() async {
    setState(() => _isRevokingAll = true);
    final ok = await widget.controller.revokeAllOtherSessions();
    if (!mounted) return;
    setState(() => _isRevokingAll = false);
    if (ok) {
      UiFeedbackHelper.showSuccess(
        context,
        'All other remote sessions revoked.',
      );
    } else {
      UiFeedbackHelper.showError(context, 'Failed to revoke remote sessions.');
    }
  }

  Future<void> _handleDeactivateAccount() async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Temporarily Deactivate Account?',
      message:
          'Your profile will be hidden from service dispatches immediately. You can sign back in anytime to reactivate.',
      confirmText: 'Deactivate',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    await widget.controller.deactivateAccount('User requested deactivation');
    await _authController.logout();
    if (!mounted) return;
    UiFeedbackHelper.showInfo(
      context,
      'Your account has been temporarily deactivated.',
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
  }

  Future<void> _showAccountDeletionDialog() {
    return AccountDeletionDialog.show(
      context,
      authController: _authController,
      showReasonField: true,
      postLogoutRoute: AppRoutes.login,
      onConfirmedDeletion: (reason) =>
          widget.controller.requestAccountDeletion(reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.skavia;

    return Scaffold(
      appBar: const AppAppBar(title: 'Privacy & Security'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final privacy = widget.controller.profile?.privacySettings ?? {};
            final sharePhone =
                privacy['share_phone_with_assigned_specialist'] as bool? ?? true;
            final dataConsent =
                privacy['data_sharing_consent'] as bool? ?? true;
            final visibility =
                privacy['profile_visibility']?.toString() ?? 'public';
            final sessions = widget.controller.sessions;

            return ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              children: [
                Text(
                  'Privacy Controls',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Directory Visibility',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ('public', 'Public'),
                          ('verified_only', 'Verified Users'),
                          ('private', 'Private'),
                        ].map((entry) {
                          final active = visibility == entry.$1;
                          return InkWell(
                            onTap: () {
                              final next = Map<String, dynamic>.from(privacy);
                              next['profile_visibility'] = entry.$1;
                              widget.controller.updatePrivacySettings(next);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: active
                                    ? tokens.brandAccent.withValues(alpha: 0.16)
                                    : colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active
                                      ? tokens.brandAccent
                                      : tokens.subtleBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (active) ...[
                                    Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: tokens.brandAccent,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Flexible(
                                    child: Text(
                                      entry.$2,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: active
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: active
                                            ? tokens.brandAccent
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Divider(color: tokens.subtleBorder, height: 22),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Share Phone with Assigned Specialist',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Allows your technician to call upon dispatch confirmation',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: sharePhone,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: (val) {
                          final next = Map<String, dynamic>.from(privacy);
                          next['share_phone_with_assigned_specialist'] = val;
                          widget.controller.updatePrivacySettings(next);
                        },
                      ),
                      Divider(color: tokens.subtleBorder, height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Service Quality & Analytics Consent',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Helps SKAVIA improve branch dispatch matching accuracy',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: dataConsent,
                        activeThumbColor: tokens.brandAccent,
                        onChanged: (val) {
                          final next = Map<String, dynamic>.from(privacy);
                          next['data_sharing_consent'] = val;
                          widget.controller.updatePrivacySettings(next);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Text(
                  'Account Authentication & Recovery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tokens.softBlueBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            color: tokens.brandAccent,
                          ),
                        ),
                        title: Text(
                          'Reset Account Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          'Send a password reset email via Firebase Auth',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: _isSendingReset
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.chevron_right_rounded),
                        onTap: _isSendingReset ? null : _sendPasswordReset,
                      ),
                      Divider(color: tokens.subtleBorder, height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 18,
                            color: tokens.mutedText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'SMS Phone OTP & Job PIN Verification protect bookings. Hardware/TOTP MFA is managed through Firebase Phone/Google sign-in.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Active Devices & Sessions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: widget.controller.isSessionsLoading
                          ? null
                          : () => widget.controller.loadSessions(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (widget.controller.isSessionsLoading && sessions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ...sessions.map(
                    (session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SessionDeviceCard(
                        session: session,
                        onRevoke: () =>
                            widget.controller.revokeSession(session.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isRevokingAll ? null : _revokeOtherSessions,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isRevokingAll)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          const Icon(Icons.logout, size: 16),
                        const SizedBox(width: 8),
                        const Flexible(
                          child: Text(
                            'Log Out of All Other Devices',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 36),
                Text(
                  'Danger Zone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.errorRed.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deactivating temporarily hides your account and pauses active notifications. Deleting requests irreversible erasure after a 30-day grace period.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleDeactivateAccount,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.warning),
                      foregroundColor: AppColors.warning,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pause_circle_outline_rounded,
                          color: AppColors.warning,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Deactivate Account Temporarily',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showAccountDeletionDialog,
                    child: const Text(
                      'Request Account Deletion',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
