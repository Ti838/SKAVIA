import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/constants/app_strings.dart';
import '../core/services/app_language_service.dart';
import '../core/services/app_theme_service.dart';
import '../l10n/generated/app_localizations.dart';
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
                    ? const Color(0xFF0B1120)
                    : const Color(0xFFFFFFFF),
                systemNavigationBarIconBrightness: effectiveDark
                    ? Brightness.light
                    : Brightness.dark,
              ),
              child: MaterialApp(
                navigatorKey: rootNavigatorKey,
                title: AppStrings.appName,
                debugShowCheckedModeBanner: false,
                locale: Locale(langCode, langCode == 'bn' ? 'BD' : null),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: AppTheme.getTheme(
                  brightness: Brightness.light,
                  languageCode: langCode,
                ),
                darkTheme: AppTheme.getTheme(
                  brightness: Brightness.dark,
                  languageCode: langCode,
                ),
                themeMode: themeMode,
                themeAnimationDuration: Duration.zero,
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
