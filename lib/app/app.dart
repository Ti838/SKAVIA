import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'router/app_routes.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_strings.dart';

class SkaviaApp extends StatelessWidget {
  const SkaviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
