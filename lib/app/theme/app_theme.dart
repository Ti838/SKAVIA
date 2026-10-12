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
      scaffoldBackgroundColor: AppColors.canvasBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
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
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppDimensions.roundedPill,
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedPill,
          borderSide: const BorderSide(
            color: AppColors.borderLight,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedPill,
          borderSide: const BorderSide(color: AppColors.primarySky, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedPill,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.roundedPill,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
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
}
