import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';

/// Reusable social authentication buttons row (Google & GitHub)
class SocialAuthButtonsRow extends StatelessWidget {
  final VoidCallback onGoogleSignIn;

  const SocialAuthButtonsRow({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // "or continue with" Divider
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.borderLight)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.borderLight)),
          ],
        ),
        const SizedBox(height: 20),

        // Social Buttons Row (Google & GitHub)
        Row(
          children: [
            // Google Pill Button
            Expanded(
              child: OutlinedButton(
                onPressed: onGoogleSignIn,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(
                    color: AppColors.borderLight,
                    width: 1.2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.roundedPill,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppAssets.googleLogo,
                      height: 18,
                      width: 18,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.g_mobiledata_rounded,
                        color: Color(0xFFEA4335),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // GitHub / Alternative Pill Button
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GitHub authentication initiated.'),
                      backgroundColor: AppColors.primarySky,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  side: const BorderSide(
                    color: AppColors.borderLight,
                    width: 1.2,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppDimensions.roundedPill,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.code_rounded,
                      size: 19,
                      color: AppColors.textDark,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'GitHub',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
