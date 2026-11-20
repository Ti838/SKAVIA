import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Centralized Material 3 Typography Scale for SKAVIA.
/// Uses Google Fonts: Plus Jakarta Sans for headings & labels, Inter for body copy.
/// Tuned for dual-script Latin + Bengali (বাংলা) legibility and tabular currency figures.
abstract class AppTypography {
  static String? get headingFont => GoogleFonts.plusJakartaSans().fontFamily;
  static String? get bodyFont => GoogleFonts.inter().fontFamily;
  static String? get banglaFont => GoogleFonts.notoSansBengali().fontFamily;

  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  static final TextTheme _lightTextThemeEn = _createTextTheme(
    Brightness.light,
    isBn: false,
  );
  static final TextTheme _darkTextThemeEn = _createTextTheme(
    Brightness.dark,
    isBn: false,
  );
  static final TextTheme _lightTextThemeBn = _createTextTheme(
    Brightness.light,
    isBn: true,
  );
  static final TextTheme _darkTextThemeBn = _createTextTheme(
    Brightness.dark,
    isBn: true,
  );

  static TextTheme buildTextTheme({
    required Brightness brightness,
    String languageCode = 'en',
  }) {
    final isBn = languageCode == 'bn';
    if (brightness == Brightness.dark) {
      return isBn ? _darkTextThemeBn : _darkTextThemeEn;
    }
    return isBn ? _lightTextThemeBn : _lightTextThemeEn;
  }

  static TextStyle _font({
    required bool isHeading,
    required bool isBn,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) {
    // Bengali conjuncts and matras break if tracking is non-zero.
    final effectiveSpacing = isBn ? 0.0 : letterSpacing;
    // Bengali vowel signs above (ী, ৈ, ৌ) & below (ু, ূ, ৃ) require safe headroom.
    final effectiveHeight = isBn
        ? (height != null ? (height * 1.08).clamp(1.35, 1.65) : 1.45)
        : height;

    if (isBn) {
      return GoogleFonts.notoSansBengali(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: effectiveHeight,
        letterSpacing: effectiveSpacing,
        fontFeatures: fontFeatures,
      );
    }

    if (isHeading) {
      return GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: effectiveHeight,
        letterSpacing: effectiveSpacing,
        fontFeatures: fontFeatures,
      );
    }

    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: effectiveHeight,
      letterSpacing: effectiveSpacing,
      fontFeatures: fontFeatures,
    );
  }

  static TextTheme _createTextTheme(Brightness brightness, {required bool isBn}) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFF8FAFC) : AppColors.textDark;
    final secondaryColor = isDark
        ? const Color(0xFFCBD5E1)
        : AppColors.textMedium;

    return TextTheme(
      displayLarge: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: isBn ? 34 : 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.25,
        color: primaryColor,
      ),
      displayMedium: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: isBn ? 28 : 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.28,
        color: primaryColor,
      ),
      displaySmall: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: isBn ? 24 : 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: primaryColor,
      ),
      headlineLarge: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: isBn ? 23 : 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.32,
        color: primaryColor,
      ),
      headlineMedium: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: isBn ? 19 : 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
        height: 1.35,
        color: primaryColor,
      ),
      headlineSmall: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.38,
        color: primaryColor,
      ),
      titleLarge: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.38,
        color: primaryColor,
      ),
      titleMedium: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.42,
        color: primaryColor,
      ),
      titleSmall: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.42,
        color: secondaryColor,
      ),
      bodyLarge: _font(
        isHeading: false,
        isBn: isBn,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primaryColor,
        height: 1.52,
      ),
      bodyMedium: _font(
        isHeading: false,
        isBn: isBn,
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.52,
      ),
      bodySmall: _font(
        isHeading: false,
        isBn: isBn,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.48,
      ),
      labelLarge: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: primaryColor,
      ),
      labelMedium: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.38,
        color: secondaryColor,
      ),
      labelSmall: _font(
        isHeading: true,
        isBn: isBn,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        height: 1.38,
        color: secondaryColor,
      ),
    );
  }

  // Standalone dynamic style builders
  static TextStyle getHeadingLarge({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.32,
    color: AppColors.textDark,
  );

  static TextStyle getHeadingMedium({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.35,
    color: AppColors.textDark,
  );

  static TextStyle getHeadingSmall({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.38,
    color: AppColors.textDark,
  );

  static TextStyle getTitleLarge({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.38,
    color: AppColors.textDark,
  );

  static TextStyle getTitleMedium({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.42,
    color: AppColors.textDark,
  );

  static TextStyle getTitleSmall({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.42,
    color: AppColors.textMedium,
  );

  static TextStyle getBodyLarge({bool isBn = false}) => _font(
    isHeading: false,
    isBn: isBn,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.52,
    color: AppColors.textDark,
  );

  static TextStyle getBodyMedium({bool isBn = false}) => _font(
    isHeading: false,
    isBn: isBn,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.52,
    color: AppColors.textMedium,
  );

  static TextStyle getBodySmall({bool isBn = false}) => _font(
    isHeading: false,
    isBn: isBn,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.48,
    color: AppColors.textMedium,
  );

  static TextStyle getButton({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.32,
    color: Colors.white,
  );

  static TextStyle getCaption({bool isBn = false}) => _font(
    isHeading: false,
    isBn: isBn,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.42,
    color: AppColors.textMedium,
  );

  static TextStyle getPrice({bool isBn = false}) => _font(
    isHeading: true,
    isBn: isBn,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    fontFeatures: tabularFigures,
    color: AppColors.textDark,
  );

  // Backward-compatible static accessors (defaulting to English, adaptable at runtime)
  static TextStyle get headingLarge => getHeadingLarge(isBn: false);
  static TextStyle get headingMedium => getHeadingMedium(isBn: false);
  static TextStyle get headingSmall => getHeadingSmall(isBn: false);
  static TextStyle get titleLarge => getTitleLarge(isBn: false);
  static TextStyle get titleMedium => getTitleMedium(isBn: false);
  static TextStyle get titleSmall => getTitleSmall(isBn: false);
  static TextStyle get bodyLarge => getBodyLarge(isBn: false);
  static TextStyle get bodyMedium => getBodyMedium(isBn: false);
  static TextStyle get bodySmall => getBodySmall(isBn: false);
  static TextStyle get button => getButton(isBn: false);
  static TextStyle get caption => getCaption(isBn: false);
  static TextStyle get price => getPrice(isBn: false);
}
