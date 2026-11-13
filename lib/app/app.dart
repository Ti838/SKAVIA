import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_strings.dart';
import '../core/services/app_language_service.dart';
import '../core/services/app_theme_service.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';

class SkaviaApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  const SkaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppLanguageService.localeNotifier,
          builder: (context, langCode, _) {
            final platformBrightness =
                MediaQuery.maybePlatformBrightnessOf(context) ??
                Brightness.light;
            final effectiveDark =
                themeMode == ThemeMode.dark ||
                (themeMode == ThemeMode.system &&
                    platformBrightness == Brightness.dark);

            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: effectiveDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: effectiveDark
                    ? Brightness.dark
                    : Brightness.light,
                systemNavigationBarColor: effectiveDark
                    ? const Color(0xFF0B1426)
                    : const Color(0xFFF8FAFC),
                systemNavigationBarIconBrightness: effectiveDark
                    ? Brightness.light
                    : Brightness.dark,
              ),
              child: MaterialApp(
                navigatorKey: rootNavigatorKey,
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                locale: Locale(langCode),
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRouter.onGenerateRoute,
              ),
            );
          },
        );
      },
    );
  }
}
