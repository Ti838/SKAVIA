import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_typography.dart';
import 'skavia_surface_tokens.dart';

/// Builder for SKAVIA Material 3 Light Theme.
ThemeData buildLightTheme({String languageCode = 'en'}) {
  const brightness = Brightness.light;
  final textTheme = AppTypography.buildTextTheme(
    brightness: brightness,
    languageCode: languageCode,
  );

  const colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primaryBlue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainerLight,
    onPrimaryContainer: AppColors.onPrimaryContainerLight,
    secondary: AppColors.secondaryViolet,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryContainerLight,
    onSecondaryContainer: AppColors.onSecondaryContainerLight,
    tertiary: AppColors.tertiaryTeal,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.tertiaryContainerLight,
    onTertiaryContainer: AppColors.onTertiaryContainerLight,
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.errorContainerLight,
    onErrorContainer: AppColors.onErrorContainerLight,
    surface: AppColors.sheetSurface,
    onSurface: AppColors.textDark,
    onSurfaceVariant: AppColors.textMedium,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFF1F5F9),
    surfaceContainerHigh: Color(0xFFE2E8F0),
    surfaceContainerHighest: Color(0xFFCBD5E1),
    outline: AppColors.borderInteractive,
    outlineVariant: AppColors.borderLight,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.sheetSurfaceSubtle,
    extensions: const [SkaviaSurfaceTokens.light],
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.sheetSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.textDark),
      titleTextStyle: textTheme.titleMedium?.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: AppColors.textDark,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textMedium,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.roundedSheetTop,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textDark,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
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
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
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
        foregroundColor: AppColors.textDark,
        side: const BorderSide(color: AppColors.borderInteractive, width: 1.2),
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
        foregroundColor: AppColors.primaryBlue,
        minimumSize: const Size(48, 44),
        textStyle: textTheme.labelLarge,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.textMedium;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primaryBlue;
        return AppColors.borderLight;
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryContainerLight,
      labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.textDark),
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: AppColors.borderLight),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.borderInteractive,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.borderInteractive,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: AppColors.textTertiary,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        side: const BorderSide(color: AppColors.borderLight, width: 1),
      ),
    ),
  );
}
