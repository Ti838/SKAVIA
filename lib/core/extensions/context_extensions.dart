import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Convenient BuildContext extensions for clean, readable UI code.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  SkaviaSurfaceTokens get skavia =>
      Theme.of(this).extension<SkaviaSurfaceTokens>() ??
      (isDarkMode ? SkaviaSurfaceTokens.dark : SkaviaSurfaceTokens.light);

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  void pop<T extends Object?>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }
}
