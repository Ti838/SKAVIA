import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../../../shared/widgets/skavia_brand_image.dart';
import '../../../app_update/providers/app_update_provider.dart';
import '../../../navigation/data/repositories/dashboard_repository.dart';

/// Minimalist, high-performance SKAVIA startup splash screen.
/// Follows modern Material 3 and Big-Tech (Instagram/Facebook) startup architecture:
/// - Near-zero latency cold launch: synchronous local cache verification (<200ms)
/// - Atomic route replacement directly into role-based dashboard without flash
/// - Zero splash on hot app resumption
/// - Smooth brand reveal for unauthenticated users
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    _resolveStartupSession();
  }

  /// Concurrent session restoration and navigation
  Future<void> _resolveStartupSession() async {
    // 1. Non-blocking app update check
    unawaited(
      AppUpdateProvider.instance
          .checkForUpdates(trigger: 'startup')
          .then<void>((_) {}, onError: (_, _) {}),
    );

    final startTime = DateTime.now();

    String? targetRoute;
    Map<String, dynamic>? routeArgs;
    bool isReturningUser = false;

    try {
      // 2. Synchronous local auth check (already in memory from AppBootstrap)
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final supabaseSession = Supabase.instance.client.auth.currentSession;
      final supabaseUser = Supabase.instance.client.auth.currentUser;

      if (firebaseUser != null || supabaseSession != null || supabaseUser != null) {
        final uid = firebaseUser?.uid ?? supabaseSession?.user.id ?? supabaseUser?.id;
        String? activeMode;

        if (uid != null && uid.isNotEmpty) {
          // Priority 1: User-scoped in-memory cache (0ms latency!)
          activeMode = LocalCacheService.instance
              .get('${AppConstants.userModeStorageKey}_$uid')
              ?.toString();

          // Priority 2: Global active mode in-memory cache
          if (activeMode == null || activeMode.isEmpty) {
            activeMode = LocalCacheService.instance
                .get(AppConstants.userModeStorageKey)
                ?.toString();
          }

          // Priority 3: Direct persistent SharedPreferences read
          if (activeMode == null || activeMode.isEmpty) {
            try {
              final prefs = await SharedPreferences.getInstance();
              activeMode = prefs.getString('${AppConstants.userModeStorageKey}_$uid') ??
                  prefs.getString(AppConstants.userModeStorageKey);
            } catch (_) {}
          }

          // Priority 4: Fallback fetch from Supabase database with timeout
          if (activeMode == null || activeMode.isEmpty) {
            try {
              final profile = await DashboardRepository()
                  .getUserProfileRecord(uid)
                  .timeout(const Duration(milliseconds: 1500));
              activeMode = profile?['active_mode']?.toString();
            } catch (_) {}
          }
        }

        // Authenticated user resolution:
        // Returning authenticated users should NEVER be trapped in role selection.
        // If mode was not explicitly discovered, default safely to 'customer'.
        final resolvedMode = (activeMode != null && activeMode.isNotEmpty)
            ? activeMode
            : 'customer';

        if (uid != null && uid.isNotEmpty) {
          LocalCacheService.instance.put(
            '${AppConstants.userModeStorageKey}_$uid',
            resolvedMode,
          );
        }
        LocalCacheService.instance.put(
          AppConstants.userModeStorageKey,
          resolvedMode,
        );

        isReturningUser = true;
        targetRoute = AppRoutes.appShell;
        routeArgs = {'initialMode': resolvedMode};
      } else {
        targetRoute = AppRoutes.onboarding;
      }
    } catch (_) {
      targetRoute = AppRoutes.onboarding;
    }

    // 3. Instagram/Facebook launch timing:
    // Returning authenticated users get instant entry (min 200ms for smooth native-to-flutter crossfade).
    // First-time / unauthenticated users get a refined brand intro (min 600ms).
    final minDelayMs = isReturningUser ? 200 : 600;
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < minDelayMs) {
      await Future.delayed(Duration(milliseconds: minDelayMs - elapsed));
    }

    if (!mounted) return;

    // 4. Atomic, irreversible route replacement so splash cannot be popped or re-entered
    Navigator.of(context).pushReplacementNamed(
      targetRoute,
      arguments: routeArgs,
    );
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

    // Minimal, professional canvas background
    final backgroundColor = isDark ? const Color(0xFF05080F) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: backgroundColor,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: backgroundColor,
              ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official SKAVIA Emblem
                    Container(
                      width: 92,
                      height: 92,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF8FAFC),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? const Color(0xFF3898EC).withValues(alpha: 0.12)
                                : const Color(0xFF003399).withValues(alpha: 0.08),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: SkaviaBrandImage(
                        assetPath: AppAssets.emblem,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.engineering_rounded,
                            size: 48,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF003399),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Refined SKAVIA Wordmark
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: primaryTextColor,
                        letterSpacing: 4.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Brand Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'One Accountable Organization',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: secondaryTextColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
