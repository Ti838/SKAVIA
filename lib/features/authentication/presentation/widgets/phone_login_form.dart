import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

/// Form inputs and submission button for Phone OTP verification.
class PhoneLoginForm extends StatelessWidget {
  final TextEditingController phoneController;
  final AuthController authController;
  final VoidCallback onSendOtp;

  const PhoneLoginForm({
    super.key,
    required this.phoneController,
    required this.authController,
    required this.onSendOtp,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone Number Field
        AppTextField(
          controller: phoneController,
          label: 'Phone Number',
          hint: '+880 1700-000000',
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(
            Icons.phone_iphone_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          validator: Validators.bdPhone,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'A 6-digit OTP code will be sent to your mobile phone via SMS.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Send OTP Button
        ListenableBuilder(
          listenable: authController,
          builder: (context, _) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authController.isLoading ? null : onSendOtp,
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
                          'Send Verification Code',
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
