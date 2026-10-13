import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../core/services/app_theme_service.dart';

class SkaviaApp extends StatelessWidget {
  const SkaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeService.themeModeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
