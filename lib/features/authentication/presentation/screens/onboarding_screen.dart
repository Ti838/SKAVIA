import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/animated_service_showcase.dart';

/// Redesigned SKAVIA Welcome / Authentication Landing Screen.
/// Clean, Linear/Apple-grade minimal aesthetic:
/// - Crisp SKAVIA header with verified brand mark
/// - Continuous Animated Service Showcase highlighting real workforce branches
/// - High-clarity typography ("Everything You Need, All in One Place.")
/// - Direct "Sign In", "Create Account", and official "Continue with Google" actions
/// - Guaranteed zero overflow across compact, standard, and large screens
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final AuthController _authController = AuthController();

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _authController.signInWithGoogle();
    if (!mounted) return;

    if (success) {
      final user = _authController.user;
      if (user != null) {
        await ProfileController.shared.loadProfile(
          user.uid,
          fallbackEmail: user.email,
          fallbackName: user.displayName,
          fallbackPhone: user.phoneNumber,
          fallbackAvatarUrl: user.photoURL,
        );

        final profile = await DashboardRepository().getUserProfileRecord(
          user.uid,
        );
        final activeMode =
            profile?['active_mode']?.toString() ??
            LocalCacheService.instance
                .get('${AppConstants.userModeStorageKey}_${user.uid}')
                ?.toString() ??
            LocalCacheService.instance
                .get(AppConstants.userModeStorageKey)
                ?.toString();

        if (activeMode != null && activeMode.isNotEmpty && mounted) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.appShell,
            arguments: {'initialMode': activeMode},
          );
          return;
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
      }
    } else if (_authController.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_authController.errorMessage!),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLegalDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final backgroundColor = isDark ? const Color(0xFF05080F) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 680;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // 1. Top Header Brand Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : const Color(0xFFF1F5F9),
                                border: Border.all(color: borderColor),
                              ),
                              child: SkaviaBrandImage(
                                assetPath: AppAssets.emblem,
                                width: 22,
                                height: 22,
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.engineering_rounded,
                                  size: 18,
                                  color: Color(0xFF003399),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.appName,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: primaryTextColor,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 20),

                        // 2. Professional SKAVIA Service Showcase (Collision-Free Dual Track)
                        AnimatedServiceShowcase(
                          height: isSmallScreen ? 155 : 180,
                        ),

                        SizedBox(height: isSmallScreen ? 14 : 22),

                        // 3. Typography: Headline & Description
                        Text(
                          'Everything You Need,\nAll in One Place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 24 : 28,
                            fontWeight: FontWeight.w800,
                            color: primaryTextColor,
                            height: 1.18,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Your trusted platform for professional services and everyday solutions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: secondaryTextColor,
                              height: 1.45,
                            ),
                          ),
                        ),

                        const Spacer(),
                        SizedBox(height: isSmallScreen ? 16 : 24),

                        // 4. Action Buttons Stack
                        // Primary: Sign In
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.login);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003399),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary: Create Account
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.register);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryTextColor,
                              side: BorderSide(color: borderColor, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Divider OR
                        Row(
                          children: [
                            Expanded(child: Divider(color: borderColor)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: borderColor)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Alternative: Continue with Google
                        ListenableBuilder(
                          listenable: _authController,
                          builder: (context, _) {
                            final isLoading = _authController.isLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: isLoading
                                    ? null
                                    : _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isDark
                                      ? colorScheme.surfaceContainerHighest
                                      : Colors.white,
                                  foregroundColor: primaryTextColor,
                                  side: BorderSide(
                                    color: borderColor,
                                    width: 1.2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF003399),
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppAssets.googleLogo,
                                            height: 20,
                                            width: 20,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                  Icons.g_mobiledata_rounded,
                                                  color: Color(0xFFEA4335),
                                                  size: 24,
                                                ),
                                          ),
                                          const SizedBox(width: 10),
                                          const Text(
                                            'Continue with Google',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.1,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 14 : 20),

                        // 5. Terms of Service & Privacy Policy Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'By continuing, you agree to our ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showLegalDialog(
                                  'Terms of Service',
                                  'By accessing or using SKAVIA, you agree to be bound by our platform service terms, verified operational procedures, escrow rules, and workplace safety standards.',
                                ),
                                child: Text(
                                  'Terms of Service',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF3898EC)
                                        : const Color(0xFF003399),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                ' and ',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showLegalDialog(
                                  'Privacy Policy',
                                  'SKAVIA collects and protects your personal data in accordance with our national data protection obligations and cryptographic access security rules.',
                                ),
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? const Color(0xFF3898EC)
                                        : const Color(0xFF003399),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Text(
                                '.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
