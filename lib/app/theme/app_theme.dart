import 'package:flutter/material.dart';

import 'app_theme_dark.dart';
import 'app_theme_light.dart';

export 'skavia_surface_tokens.dart';

/// Centralized Material 3 Theme Builder for SKAVIA.
/// Implements the WCAG 2.1 AA/AAA Cobalt-Blue + Subtle Violet + Operational Teal
/// palette on clean white / cool-slate surfaces in Light and Dark modes.
abstract class AppTheme {
  static final ThemeData lightTheme = buildLightTheme(languageCode: 'en');
  static final ThemeData darkTheme = buildDarkTheme(languageCode: 'en');

  static final ThemeData lightThemeBn = buildLightTheme(languageCode: 'bn');
  static final ThemeData darkThemeBn = buildDarkTheme(languageCode: 'bn');

  static ThemeData getTheme({
    required Brightness brightness,
    String languageCode = 'en',
  }) {
    final isBn = languageCode == 'bn';
    if (brightness == Brightness.dark) {
      return isBn ? darkThemeBn : darkTheme;
    }
    return isBn ? lightThemeBn : lightTheme;
  }
}
