import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';
import 'app_dimensions.dart';

/// Centralized Material 3 Theme Builder for SKAVIA.
/// Configures light and dark mode with pure tonal surface elevation,
/// smooth pill buttons, and responsive inputs.
abstract class AppTheme {
  static ThemeData get lightTheme {
    const brightness = Brightness.light;
    final textTheme = AppTypography.buildTextTheme(brightness: brightness);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primarySky,
      onPrimary: Colors.white,
      primaryContainer: AppColors.cardBlueTint,
      onPrimaryContainer: AppColors.primaryRoyal,
      secondary: AppColors.accentPeach,
      onSecondary: AppColors.textDark,
      secondaryContainer: AppColors.cardPeachTint,
      onSecondaryContainer: AppColors.accentCoral,
      tertiary: AppColors.accentAqua,
      onTertiary: AppColors.textDark,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.sheetSurface,
      onSurface: AppColors.textDark,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.sheetSurfaceSubtle,
      surfaceContainer: const Color(0xFFF1F5F9),
      surfaceContainerHigh: const Color(0xFFE2E8F0),
      outline: AppColors.borderLight,
      outlineVariant: const Color(0xFFCBD5E1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMedium,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.roundedSheetTop,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.sheetSurface,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedPill,
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.primarySky, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius24),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
    );
  }

  /// Full Material 3 dark theme for SKAVIA.
  /// Automatically applied when system is in dark mode.
  static ThemeData get darkTheme {
    const brightness = Brightness.dark;
    final textTheme = AppTypography.buildTextTheme(brightness: brightness);

    // Dark surface palette
    const darkSurface = Color(0xFF0F172A);
    const darkSurfaceContainer = Color(0xFF1E293B);
    const darkSurfaceHigh = Color(0xFF334155);
    const darkBorder = Color(0xFF334155);
    const darkBorderSubtle = Color(0xFF1E293B);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primarySky,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1A3A5C),
      onPrimaryContainer: const Color(0xFFBAE6FD),
      secondary: AppColors.accentPeach,
      onSecondary: const Color(0xFF0F172A),
      secondaryContainer: const Color(0xFF4A3428),
      onSecondaryContainer: AppColors.accentPeach,
      tertiary: AppColors.accentAqua,
      onTertiary: const Color(0xFF0F172A),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
      surface: darkSurface,
      onSurface: const Color(0xFFE2E8F0),
      surfaceContainerLowest: const Color(0xFF0A0F1E),
      surfaceContainerLow: const Color(0xFF131B2E),
      surfaceContainer: darkSurfaceContainer,
      surfaceContainerHigh: darkSurfaceHigh,
      outline: darkBorder,
      outlineVariant: darkBorderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF0B1426),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFFE2E8F0)),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: const Color(0xFFE2E8F0),
          fontWeight: FontWeight.w700,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: const Color(0xFFE2E8F0),
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF94A3B8),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.roundedSheetTop,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorderSubtle,
        thickness: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkSurfaceContainer,
          foregroundColor: const Color(0xFFE2E8F0),
          elevation: 0,
          minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedPill,
          ),
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: AppColors.primarySky, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius14),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF64748B),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius24),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
    );
  }
}
