import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Form fields for RegistrationScreen (Full Name, Email, Phone, Password, Confirm Password).
class RegistrationFormFields extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const RegistrationFormFields({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        AppTextField(
          controller: fullNameController,
          label: l10n.authFullName,
          hint: l10n.authFullNameHint,
          prefixIcon: const Icon(Icons.person_outline),
          validator: (val) => val == null || val.trim().length < 3
              ? 'Name must be at least 3 characters'
              : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: emailController,
          label: l10n.authEmail,
          hint: l10n.authEmailHint,
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: phoneController,
          label: l10n.authPhone,
          hint: l10n.authPhoneHint,
          prefixIcon: const Icon(Icons.phone_outlined),
          keyboardType: TextInputType.phone,
          validator: Validators.optionalBdPhone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: passwordController,
          label: l10n.authPassword,
          hint: l10n.authPasswordHint,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (val) => val == null || val.length < 6
              ? 'Password must be at least 6 characters'
              : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: confirmPasswordController,
          label: l10n.authConfirmPassword,
          hint: l10n.authPasswordHint,
          isPassword: true,
          prefixIcon: const Icon(Icons.lock_outline),
          validator: (val) {
            if (val == null || val.isEmpty) {
              return 'Please confirm your password';
            }
            if (val != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
