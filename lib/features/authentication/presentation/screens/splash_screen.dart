import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';

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
    // Wait for the smooth logo intro animation to play
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    try {
      // 1. Check if an active session exists in Firebase Auth or Supabase
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final supabaseSession = Supabase.instance.client.auth.currentSession;

      if (firebaseUser != null || supabaseSession != null) {
        // Authenticated -> Navigate directly to Main App Shell
        Navigator.of(context).pushReplacementNamed(AppRoutes.appShell);
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF071228),
              Color(0xFF0B1D47),
              Color(0xFF0F3277),
              Color(0xFF1E40AF),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
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
                            color: Colors.white.withValues(alpha: 0.08),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3898EC)
                                    .withValues(alpha: 0.25),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppAssets.emblem,
                            width: 88,
                            height: 88,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.engineering_rounded,
                                size: 64,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        AppStrings.appName,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.appTagline,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
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
                  opacity: 0.9,
                  child: Image.asset(
                    AppAssets.techniciansConsole,
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
    );
  }
}
