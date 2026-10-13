import 'package:flutter/material.dart';

/// Standard Dimensions and Spacing Tokens for SKAVIA.
/// Features the signature 32dp Sheet Curvature and Full Pill geometry.
abstract class AppDimensions {
  // Padding & Margin Spacing
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Corner Radii
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius14 = 14.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radiusSheetTop = 32.0; // The Signature Curved Sheet
  static const double radiusPill = 9999.0; // Signature Pill Buttons & Inputs

  // Semantic Aliases
  static const double paddingSmall = space8;
  static const double paddingMedium = space16;
  static const double paddingLarge = space24;
  static const double paddingXLarge = space32;

  static const double radiusSmall = radius8;
  static const double radiusMedium = radius16;
  static const double radiusLarge = radius24;
  static const double radiusRound = radiusPill;

  // Border Radius Objects
  static const BorderRadius roundedSmall = BorderRadius.all(
    Radius.circular(radius8),
  );
  static const BorderRadius roundedMedium = BorderRadius.all(
    Radius.circular(radius16),
  );
  static const BorderRadius roundedLarge = BorderRadius.all(
    Radius.circular(radius24),
  );
  static const BorderRadius roundedSheet = BorderRadius.only(
    topLeft: Radius.circular(radiusSheetTop),
    topRight: Radius.circular(radiusSheetTop),
  );
  static const BorderRadius roundedSheetTop = roundedSheet;
  static const BorderRadius roundedPill = BorderRadius.all(
    Radius.circular(radiusPill),
  );

  // Component Heights
  static const double buttonHeight = 54.0;
  static const double inputHeight = 54.0;
}
