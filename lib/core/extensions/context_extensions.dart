import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../core/services/app_language_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../l10n/generated/app_localizations_bn.dart';
import '../../l10n/generated/app_localizations_en.dart';

/// Convenient BuildContext extensions for clean, readable UI code.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  SkaviaSurfaceTokens get skavia =>
      Theme.of(this).extension<SkaviaSurfaceTokens>() ??
      (isDarkMode ? SkaviaSurfaceTokens.dark : SkaviaSurfaceTokens.light);

  /// Centralized type-safe ARB localization accessor with zero-crash fallback
  AppLocalizations get l10n {
    try {
      final loc = Localizations.of<AppLocalizations>(this, AppLocalizations);
      if (loc != null) return loc;
    } catch (_) {}
    return isBengali ? AppLocalizationsBn() : AppLocalizationsEn();
  }

  /// Reactive locale check based on current context with zero-crash fallback
  bool get isBengali {
    try {
      final locale = Localizations.maybeLocaleOf(this);
      if (locale != null) {
        return locale.languageCode == 'bn';
      }
    } catch (_) {}
    return AppLanguageService.isBengali;
  }

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
