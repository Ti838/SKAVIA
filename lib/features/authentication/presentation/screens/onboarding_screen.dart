import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/auth_controller.dart';

/// Screen 1 of SKAVIA Approved Reference UI (skavia_exact_reference_ui.png).
/// Pixel-perfect, World-Class Enterprise First Screen featuring:
/// - Signature Sky Blue canvas (#3898EC)
/// - Top Pill Brand Emblem Badge + Menu Action
/// - Bold Display Headline: "Skilled Workforce Solutions"
/// - Bespoke Technicians Artwork with Computer/Rocket console
/// - 32dp Curved Bottom Sheet with "Sign in" Pill Button
/// - Bottom Right Potted Plant vector art
/// - Guaranteed Zero Layout Overflow via Responsive LayoutBuilder
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _showInfoDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surface : Colors.white,
          borderRadius: AppDimensions.roundedSheet,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Image.asset(
                      AppAssets.emblem,
                      height: 28,
                      width: 28,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.engineering_rounded,
                        size: 28,
                        color: AppColors.primarySky,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'SKAVIA Platform Ecosystem',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'A solution-oriented service & workforce platform connecting customers and enterprises with verified trade specialists across Dhaka.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.electric_bolt_rounded,
                  title: '8 Certified Trade Taxonomies',
                  desc: 'Electrical, HVAC, Plumbing, Carpentry, IT and more.',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.verified_user_rounded,
                  title: 'Police & NID KYC Verification',
                  desc: 'Every master technician is vetted for maximum trust.',
                ),
                _buildDrawerItem(
                  context: context,
                  icon: Icons.security_rounded,
                  title: 'Transparent Escrow & Dual OTP',
                  desc:
                      'Funds safely held in escrow until completion handshake.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySky,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppDimensions.roundedPill,
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Got it',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.primaryContainer
                  : AppColors.cardBlueTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDark ? colorScheme.primary : AppColors.primarySky,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1426) : AppColors.canvasBlue,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar: Pill Logo + Hamburger Menu
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pill Logo Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.surfaceContainerHighest
                                    : Colors.white,
                                borderRadius: AppDimensions.roundedPill,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: isDark ? 0.3 : 0.08,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AppAssets.emblem,
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.engineering_rounded,
                                      size: 20,
                                      color: AppColors.primarySky,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppStrings.appName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? colorScheme.primary
                                          : AppColors.primaryRoyal,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Hamburger Menu Icon
                            IconButton(
                              onPressed: () => _showInfoDrawer(context),
                              icon: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                              tooltip: 'Platform Menu',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Hero Typography
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Skilled\nWorkforce\nSolutions',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Connect in real-time with verified master electricians, HVAC specialists, plumbers, and turnkey corporate project teams across Dhaka.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Technicians Artwork
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Image.asset(
                              AppAssets.techniciansConsole,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.engineering_rounded,
                                size: 72,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Signature 32dp Curved Bottom Sheet with Plant Decoration & Auth Actions
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark ? colorScheme.surface : Colors.white,
                              borderRadius: AppDimensions.roundedSheet,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.35 : 0.08,
                                  ),
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
                                      final success =
                                          await authController.loginWithGoogle();
                                      if (success && context.mounted) {
                                        Navigator.of(context)
                                            .pushReplacementNamed(
                                              AppRoutes.appShell,
                                            );
                                      } else if (context.mounted) {
                                        final errorMsg =
                                            authController.errorMessage;
                                        if (errorMsg != null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(errorMsg),
                                              backgroundColor:
                                                  AppColors.error,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    Navigator.of(context)
                                        .pushNamed(AppRoutes.login);
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
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
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
                                        Navigator.of(context)
                                            .pushNamed(AppRoutes.register);
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
                              errorBuilder: (_, _, _) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ],
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
