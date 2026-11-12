import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Trigger non-blocking startup release check immediately during splash
    unawaited(
      AppUpdateProvider.instance
          .checkForUpdates(trigger: 'startup')
          .then<void>((_) {}, onError: (_, _) {}),
    );

    // Wait for the smooth logo intro animation to play
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      // 1. Check if an active session exists in Firebase Auth or Supabase
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final supabaseSession = Supabase.instance.client.auth.currentSession;

      if (firebaseUser != null || supabaseSession != null) {
        final uid = firebaseUser?.uid ?? supabaseSession?.user.id;
        String? activeMode;
        if (uid != null) {
          final profile =
              await DashboardRepository().getUserProfileRecord(uid);
          activeMode = profile?['active_mode']?.toString();
        }
        if (!mounted) return;
        if (activeMode != null && activeMode.isNotEmpty) {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.appShell,
            arguments: {'initialMode': activeMode},
          );
        } else {
          // If no role mode configured yet, prompt deliberate role selection
          Navigator.of(context).pushReplacementNamed(AppRoutes.roleSelection);
        }
      } else {
        // No session -> Navigate to Onboarding
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    } catch (_) {
      // Fallback to onboarding if session check encounters error
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF071228),
                      Color(0xFF0B1D47),
                      Color(0xFF0F3277),
                      Color(0xFF1E40AF),
                    ]
                  : const [
                      Color(0xFFF8FAFC),
                      Color(0xFFEFF6FF),
                      Color(0xFFDBEAFE),
                      Color(0xFFBFDBFE),
                    ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Official SKAVIA Emblem / Logo
                        Hero(
                          tag: 'app_logo',
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0xFF3898EC)
                                            .withValues(alpha: 0.25)
                                      : const Color(0xFF2563EB)
                                            .withValues(alpha: 0.20),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: SkaviaBrandImage(
                              assetPath: AppAssets.emblem,
                              width: 88,
                              height: 88,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.engineering_rounded,
                                  size: 64,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1D4ED8),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            letterSpacing: 3.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.appTagline,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : const Color(0xFF334155),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Bottom Modern Workforce Illustration from Assets
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Opacity(
                    opacity: isDark ? 0.9 : 0.95,
                    child: SkaviaBrandImage(
                      assetPath: AppAssets.techniciansConsole,
                      height: 180,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
