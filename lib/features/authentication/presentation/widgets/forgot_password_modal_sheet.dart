import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Modal bottom sheet for resetting account password via Supabase Auth
class ForgotPasswordModalSheet extends StatefulWidget {
  final String initialEmail;
  final AuthController authController;

  const ForgotPasswordModalSheet({
    super.key,
    required this.initialEmail,
    required this.authController,
  });

  static void show(
    BuildContext context, {
    required String initialEmail,
    required AuthController authController,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => ForgotPasswordModalSheet(
        initialEmail: initialEmail,
        authController: authController,
      ),
    );
  }

  @override
  State<ForgotPasswordModalSheet> createState() =>
      _ForgotPasswordModalSheetState();
}

class _ForgotPasswordModalSheetState extends State<ForgotPasswordModalSheet> {
  late final TextEditingController _resetEmailController;
  bool _isResetting = false;

  @override
  void initState() {
    super.initState();
    _resetEmailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _resetEmailController.text.trim();
    if (email.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isResetting = true);
    final success = await widget.authController.sendPasswordResetEmail(email);
    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Password reset link sent to $email'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      setState(() => _isResetting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.authController.errorMessage ??
                'Password reset failed. Please verify email.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppDimensions.roundedSheet,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Reset Account Password',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your registered email address to receive password reset instructions.',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _resetEmailController,
              label: 'Account Email',
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.primarySky,
                size: 20,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySky,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.roundedPill,
                  ),
                  elevation: 0,
                ),
                onPressed: _isResetting ? null : _handleReset,
                child: _isResetting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
