import 'package:flutter/material.dart';

/// Centralized Design Tokens for SKAVIA.
/// Perfectly combining:
/// - Official Logo: Deep Cobalt Blue (#003399) & Neon Aqua (#15E7CA)
/// - Approved Reference Theme: Vibrant Sky Blue (#3898EC), Warm Peach (#FDBA74 / #FF8A65) & Pure White Surfaces
abstract class AppColors {
  // Brand Primary & Canvas
  static const Color primarySky = Color(0xFF3898EC);
  static const Color primaryRoyal = Color(0xFF003399);
  static const Color primaryDeep = Color(0xFF0F172A);

  // Warm Peach & Coral Accents (Reference Art Accents)
  static const Color accentPeach = Color(0xFFFDBA74);
  static const Color accentCoral = Color(0xFFFF8A65);
  static const Color accentPeachSoft = Color(0xFFFFF3E0);

  // Mint & Aqua Signals (From Logo)
  static const Color accentAqua = Color(0xFF15E7CA);
  static const Color accentAquaSoft = Color(0xFFD4FAF4);

  // Background & Surface Tokens (The Signature 32dp Sheet Architecture)
  static const Color canvasBlue = Color(0xFF3898EC);
  static const Color sheetSurface = Color(0xFFFFFFFF);
  static const Color sheetSurfaceSubtle = Color(0xFFF8FAFC);
  static const Color cardPeachTint = Color(0xFFFFF2E2);
  static const Color cardBlueTint = Color(0xFFEBF5FF);

  // Typography
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Functional Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderDarkOutline = Color(0xFF1E293B);

  // Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color statusActive = success;
  static const Color statusCancelled = error;

  // Aliases for convenience
  static const Color primary = primarySky;
  static const Color primaryNavy = primaryRoyal;
  static const Color accent = accentPeach;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMedium;
  static const Color textDisabled = textMuted;
  static const Color sheetBackground = sheetSurface;
  static const Color surfaceVariant = sheetSurfaceSubtle;
  static const Color successGreen = success;
  static const Color errorRed = error;
  static const Color warningAmber = warning;

  // Gradients
  static const LinearGradient skyCanvasGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4FA8F5), Color(0xFF2E8CE4)],
  );

  static const LinearGradient logoRoyalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRoyal, Color(0xFF0244E1)],
  );

  static const LinearGradient peachStatGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
  );

  static const LinearGradient blueStatGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
  );
}
