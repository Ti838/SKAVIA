import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Form inputs and submission button for Email + Password authentication.
class EmailLoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPassword;
  final AuthController authController;
  final VoidCallback onLogin;

  const EmailLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPassword,
    required this.authController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final skavia = context.skavia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
        AppTextField(
          controller: emailController,
          label: 'Email Address',
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          validator: Validators.email,
        ),
        const SizedBox(height: 16),

        // Password Field
        AppTextField(
          controller: passwordController,
          label: 'Password',
          hint: '••••••••',
          isPassword: true,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Password is required';
            }
            if (val.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Remember Me & Forgot Password (Wrap prevents 320dp + 2.0x textScale overflow)
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => onRememberMeChanged(!rememberMe),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: rememberMe,
                          onChanged: (v) => onRememberMeChanged(v ?? true),
                          activeColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Remember me',
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onForgotPassword,
                child: Text(
                  'Forgot Password?',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: skavia.brandAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // Primary Sign In Button
        ListenableBuilder(
          listenable: authController,
          builder: (context, _) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.roundedPill,
                    ),
                  ),
                  child: authController.isLoading
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
