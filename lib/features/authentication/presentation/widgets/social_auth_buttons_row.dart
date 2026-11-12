import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';

/// Reusable social authentication button (Google One-Tap / OAuth)
class SocialAuthButtonsRow extends StatelessWidget {
  final VoidCallback onGoogleSignIn;

  const SocialAuthButtonsRow({super.key, required this.onGoogleSignIn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // "or continue with" Divider
        Row(
          children: [
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'or continue with',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            Expanded(child: Divider(color: colorScheme.outlineVariant)),
          ],
        ),
        const SizedBox(height: 18),

        // Google Full-Width Pill Button
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onGoogleSignIn,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white,
                foregroundColor: colorScheme.onSurface,
                side: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppDimensions.roundedPill,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppAssets.googleLogo,
                    height: 20,
                    width: 20,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.g_mobiledata_rounded,
                      color: Color(0xFFEA4335),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Continue with Google',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
