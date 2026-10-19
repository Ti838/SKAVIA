import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
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
          prefixIcon: const Icon(
            Icons.phone_iphone_rounded,
            color: AppColors.textMedium,
            size: 20,
          ),
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
            return SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: authController.isLoading ? null : onSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarySky,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.roundedPill,
                  ),
                ),
                child: authController.isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Send Verification Code',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
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

