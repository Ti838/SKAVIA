import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/onboarding_auth_sheet.dart';
import '../widgets/platform_info_sheet.dart';

/// Screen 1 of SKAVIA Approved Reference UI (skavia_exact_reference_ui.png).
/// Pixel-perfect, World-Class Enterprise First Screen featuring:
/// - Signature Sky Blue canvas (#3898EC)
/// - Top Pill Brand Emblem Badge + Menu Action
/// - Bold Display Headline: "Skilled Workforce Solutions"
/// - Bespoke Technicians Artwork with Computer/Rocket console
/// - 32dp Curved Bottom Sheet with Auth Actions
/// - Guaranteed Zero Layout Overflow via Responsive LayoutBuilder
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
                              onPressed: () => PlatformInfoSheet.show(context),
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

                      // Signature 32dp Curved Bottom Sheet with Auth Actions
                      const OnboardingAuthSheet(),
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
