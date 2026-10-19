import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../controllers/auth_controller.dart';

/// 32dp Curved Bottom Sheet with Google 1-tap, Email/Phone Sign in, and Create Account actions.
class OnboardingAuthSheet extends StatelessWidget {
  const OnboardingAuthSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? colorScheme.surface : Colors.white,
            borderRadius: AppDimensions.roundedSheet,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(26, 26, 26, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Continue with Google (Instant 1-Tap Auth)
              InkWell(
                onTap: () async {
                  final authController = AuthController();
                  try {
                    final success = await authController.loginWithGoogle();
                    if (success && context.mounted) {
                      final user = authController.user;
                      if (user != null) {
                        final profile = await DashboardRepository()
                            .getUserProfileRecord(user.uid);
                        final activeMode = profile?['active_mode']?.toString();
                        if (activeMode != null &&
                            activeMode.isNotEmpty &&
                            context.mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            AppRoutes.appShell,
                            arguments: {'initialMode': activeMode},
                          );
                          return;
                        }
                      }
                      if (context.mounted) {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.roleSelection);
                      }
                    } else if (context.mounted) {
                      final errorMsg = authController.errorMessage;
                      if (errorMsg != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  } finally {
                    authController.dispose();
                  }
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outlineVariant
                          : AppColors.borderLight,
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.2 : 0.05,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.googleLogo,
                        height: 22,
                        width: 22,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.g_mobiledata_rounded,
                          color: Color(0xFFEA4335),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. Sign In with Email / Phone
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.login);
                },
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.primary
                        : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Sign in with Email / Phone',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Secondary Navigation: Register / Create Account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to SKAVIA? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.register);
                    },
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? colorScheme.primary
                            : AppColors.primaryRoyal,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Potted plant decoration at bottom right (Authentic Reference Art)
        Positioned(
          right: 22,
          bottom: 22,
          child: Image.asset(
            AppAssets.pottedPlant,
            height: 50,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
