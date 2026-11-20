import 'package:flutter/material.dart';

import 'app_dimensions.dart';
import 'app_typography.dart';
import 'skavia_surface_tokens.dart';

/// Builder for SKAVIA Material 3 Dark Theme (OLED-safe cool slate-navy).
ThemeData buildDarkTheme({String languageCode = 'en'}) {
  const brightness = Brightness.dark;
  final textTheme = AppTypography.buildTextTheme(
    brightness: brightness,
    languageCode: languageCode,
  );

  const darkBg = Color(0xFF070A11);
  const darkSurface = Color(0xFF0B101D);
  const darkCard = Color(0xFF101726);
  const darkSurfaceTinted = Color(0xFF151E32);
  const darkElevated = Color(0xFF1C2740);
  const darkBorderSubtle = Color(0xFF192338);
  const darkBorderInteractive = Color(0xFF546C8D);
  const darkPrimary = Color(0xFF4C86F0);
  const darkOnPrimary = Color(0xFF070A11);

  const colorScheme = ColorScheme(
    brightness: brightness,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: Color(0xFF0D2040),
    onPrimaryContainer: Color(0xFFDBEAFE),
    secondary: Color(0xFF9D7BF2),
    onSecondary: Color(0xFF070A11),
    secondaryContainer: Color(0xFF241542),
    onSecondaryContainer: Color(0xFFEDE9FE),
    tertiary: Color(0xFF25C9B3),
    onTertiary: Color(0xFF070A11),
    tertiaryContainer: Color(0xFF0B2E28),
    onTertiaryContainer: Color(0xFFCCFBF1),
    error: Color(0xFFF87171),
    onError: Color(0xFF2D0B0E),
    errorContainer: Color(0xFF2D0B0E),
    onErrorContainer: Color(0xFFFECDD3),
    surface: darkSurface,
    onSurface: Color(0xFFEDEFEF),
    onSurfaceVariant: Color(0xFF9BB0C9),
    surfaceContainerLowest: darkBg,
    surfaceContainerLow: darkSurface,
    surfaceContainer: darkCard,
    surfaceContainerHigh: darkSurfaceTinted,
    surfaceContainerHighest: darkElevated,
    outline: darkBorderInteractive,
    outlineVariant: darkBorderSubtle,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: darkBg,
    extensions: const [SkaviaSurfaceTokens.dark],
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Color(0xFFEDEFEF)),
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: const Color(0xFFEDEFEF),
        fontWeight: FontWeight.w700,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: darkBorderSubtle, width: 1),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: const Color(0xFFEDEFEF),
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF9BB0C9),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkSurface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.roundedSheetTop,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: darkBorderSubtle,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkElevated,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: const Color(0xFFEDEFEF),
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: darkBorderSubtle),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        disabledBackgroundColor: darkSurfaceTinted,
        disabledForegroundColor: const Color(0xFF7189A8),
        elevation: 0,
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        disabledBackgroundColor: darkSurfaceTinted,
        disabledForegroundColor: const Color(0xFF7189A8),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFEDEFEF),
        side: const BorderSide(color: darkBorderInteractive, width: 1.2),
        minimumSize: const Size(0, AppDimensions.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkPrimary,
        minimumSize: const Size(48, 44),
        textStyle: textTheme.labelLarge,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return darkOnPrimary;
        return const Color(0xFF9BB0C9);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return darkPrimary;
        return darkElevated;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSurfaceTinted,
      selectedColor: const Color(0xFF0D2040),
      labelStyle: textTheme.labelMedium?.copyWith(
        color: const Color(0xFFEDEFEF),
      ),
      side: const BorderSide(color: darkBorderSubtle),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: darkBorderSubtle),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceTinted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: darkBorderInteractive, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: darkBorderInteractive, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF9BB0C9),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(color: const Color(0xFF7189A8)),
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: darkBorderSubtle, width: 1),
      ),
    ),
  );
}
