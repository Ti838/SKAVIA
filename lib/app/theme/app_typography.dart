import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized Material 3 Typography Scale for SKAVIA.
/// Configured using Google Fonts: Plus Jakarta Sans for confident headings,
/// and Inter for crisp, legible body text.
abstract class AppTypography {
  static const String headingFont = 'PlusJakartaSans';
  static const String bodyFont = 'Inter';

  static final TextTheme _lightTextTheme = _createTextTheme(Brightness.light);
  static final TextTheme _darkTextTheme = _createTextTheme(Brightness.dark);

  static TextTheme buildTextTheme({required Brightness brightness}) =>
      brightness == Brightness.dark ? _darkTextTheme : _lightTextTheme;

  static TextTheme _createTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textLight : AppColors.textDark;
    final secondaryColor = isDark
        ? const Color(0xFF94A3B8)
        : AppColors.textMedium;

    return TextTheme(
      // Display: Hero brand titles & large promotional headers
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 38,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primaryColor,
      ),

      // Headline: Prominent screen titles
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Title: Card titles, section headers, dialog titles
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),

      // Body: General content & descriptions
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.45,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),

      // Label: Button text, chips, badges, tabs
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
    );
  }

  // Cached Standalone Style Accessors (Theme-Adaptive - inherits ambient color)
  static final TextStyle headingLarge =
      GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800);

  static final TextStyle headingMedium =
      GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w700);

  static final TextStyle headingSmall =
      GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w600);

  static final TextStyle titleLarge =
      GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700);

  static final TextStyle titleMedium =
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600);

  static final TextStyle titleSmall =
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600);

  static final TextStyle bodyLarge =
      GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5);

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static final TextStyle bodySmall =
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400);

  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle caption =
      GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500);
}
