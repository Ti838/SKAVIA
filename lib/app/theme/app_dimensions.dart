import 'package:flutter/material.dart';

/// Standard Dimensions and Spacing Tokens for SKAVIA.
/// Follows an 8pt spacing grid and a unified 5-step corner radius scale:
/// 8dp (sm) · 12dp (md) · 16dp (lg) · 24dp (xl/sheet) · pill (9999dp).
abstract class AppDimensions {
  // Padding & Margin Spacing (8pt grid)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Standardized 5-Step Corner Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 9999.0;

  // Backward-compatible numeric aliases mapped to canonical steps
  static const double radius8 = radiusSm;
  static const double radius12 = radiusMd;
  static const double radius14 = radiusMd;
  static const double radius16 = radiusLg;
  static const double radius20 = radiusLg;
  static const double radius24 = radiusLg;
  static const double radiusSheetTop = radiusXl;

  // Semantic Aliases
  static const double paddingSmall = space8;
  static const double paddingMedium = space16;
  static const double paddingLarge = space24;
  static const double paddingXLarge = space32;

  static const double radiusSmall = radiusSm;
  static const double radiusMedium = radiusLg;
  static const double radiusLarge = radiusLg;
  static const double radiusRound = radiusPill;

  // Border Radius Objects
  static const BorderRadius roundedSmall = BorderRadius.all(
    Radius.circular(radiusSm),
  );
  static const BorderRadius roundedControl = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius roundedMedium = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius roundedLarge = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius roundedSheet = BorderRadius.only(
    topLeft: Radius.circular(radiusSheetTop),
    topRight: Radius.circular(radiusSheetTop),
  );
  static const BorderRadius roundedSheetTop = roundedSheet;
  static const BorderRadius roundedPill = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  // Component Heights & Touch Targets (WCAG / Material minimum >= 48dp)
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 50.0;
  static const double inputHeight = 50.0;
}
