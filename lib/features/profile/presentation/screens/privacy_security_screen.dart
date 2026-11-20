import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/ui_feedback_helper.dart';
import '../../../../shared/dialogs/account_deletion_dialog.dart';
import '../../../../shared/dialogs/confirmation_dialog.dart';
import '../../../../shared/widgets/app_app_bar.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/privacy_controls_card.dart';
import '../widgets/security_auth_recovery_card.dart';
import '../widgets/security_danger_zone_section.dart';
import '../widgets/security_sessions_section.dart';

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
      message: 'Your profile will be hidden from service dispatches immediately. You can sign back in anytime to reactivate.',
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
    return Scaffold(
      appBar: const AppAppBar(title: 'Privacy & Security'),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final privacy = widget.controller.profile?.privacySettings ?? {};

            return ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingLarge),
              children: [
                PrivacyControlsCard(
                  controller: widget.controller,
                  privacy: privacy,
                ),
                const SizedBox(height: 22),
                SecurityAuthRecoveryCard(
                  isSendingReset: _isSendingReset,
                  onSendPasswordReset: _sendPasswordReset,
                ),
                const SizedBox(height: 22),
                SecuritySessionsSection(
                  controller: widget.controller,
                  isRevokingAll: _isRevokingAll,
                  onRevokeAllOtherSessions: _revokeOtherSessions,
                ),
                SecurityDangerZoneSection(
                  onDeactivate: _handleDeactivateAccount,
                  onDelete: _showAccountDeletionDialog,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
