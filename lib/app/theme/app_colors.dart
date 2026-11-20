import 'package:flutter/material.dart';

/// Centralized Human-Psychology & WCAG 2.1 Verified Design Tokens for SKAVIA.
///
/// Palette Identity:
/// - Trust Cobalt Blue (#1D4ED8 light / #60A5FA dark) for primary actions (6.70:1 / 7.41:1)
/// - Brand Anchor Royal (#003399) honoring the official SKAVIA emblem
/// - Subtle Violet (#6D28D9 light / #A78BFA dark) for SKAVIA AI, Business & Organization
/// - Operational Teal (#0F766E light / #2DD4BF dark) for KYC verification & active availability
/// - Clean White & Cool Slate Neutrals (#FFFFFF / #F8FAFC light, #0B1120 / #162032 dark)
abstract class AppColors {
  // Primary Trust Blue Hierarchy
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color primaryPressed = Color(0xFF1E40AF);
  static const Color primaryRoyal = Color(0xFF003399);
  static const Color primaryDeep = Color(0xFF0F172A);
  static const Color primaryContainerLight = Color(0xFFEFF6FF);
  static const Color onPrimaryContainerLight = Color(0xFF1E3A8A);

  // Backward-compatible primary aliases (mapped to WCAG AA Trust Blue)
  static const Color primarySky = primaryBlue;
  static const Color primary = primaryBlue;
  static const Color primaryNavy = primaryRoyal;

  // Secondary Subtle Violet (AI, Business Client, Organization)
  static const Color secondaryViolet = Color(0xFF6D28D9);
  static const Color secondaryVioletDeep = Color(0xFF5B21B6);
  static const Color secondaryContainerLight = Color(0xFFF5F3FF);
  static const Color onSecondaryContainerLight = Color(0xFF4C1D95);

  // Tertiary Operational Teal (KYC Verified, Live Online Status)
  static const Color tertiaryTeal = Color(0xFF0F766E);
  static const Color tertiaryContainerLight = Color(0xFFF0FDFA);
  static const Color onTertiaryContainerLight = Color(0xFF115E59);

  // Legacy accent aliases migrated safely to accessible semantic tokens
  static const Color accentAqua = tertiaryTeal;
  static const Color accentAquaSoft = tertiaryContainerLight;
  static const Color accentPeach = Color(0xFFB45309); // Accessible warm amber-bronze (5.02:1 with white)
  static const Color accentCoral = Color(0xFF92400E);
  static const Color accentPeachSoft = Color(0xFFFFFBEB);
  static const Color accent = tertiaryTeal;

  // Light Backgrounds & Surfaces (88% Clean White / Cool Slate)
  static const Color canvasBlue = primaryBlue;
  static const Color sheetSurface = Color(0xFFFFFFFF);
  static const Color sheetSurfaceSubtle = Color(0xFFF8FAFC);
  static const Color surfaceTintedLight = Color(0xFFF1F5F9);
  static const Color cardBlueTint = primaryContainerLight;
  static const Color cardPeachTint = accentPeachSoft;
  static const Color cardVioletTint = secondaryContainerLight;
  static const Color sheetBackground = sheetSurface;
  static const Color surfaceVariant = sheetSurfaceSubtle;

  // Typography Ink Hierarchy (Bengali + Latin WCAG AA/AAA)
  static const Color textDark = Color(0xFF0F172A); // 17.85:1 on white
  static const Color textMedium = Color(0xFF475569); // 7.58:1 on white
  static const Color textTertiary = Color(0xFF526075); // 6.40:1 on white, 5.66:1 on tinted
  static const Color textMuted = textTertiary;
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textPrimary = textDark;
  static const Color textSecondary = textMedium;

  // Functional Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderInteractive = Color(0xFF8592A6); // 3.15:1 on white (WCAG 1.4.11)
  static const Color borderDarkOutline = Color(0xFF243247);
  static const Color borderDarkInteractive = Color(0xFF64748B); // 3.43:1 on dark card

  // Semantic Status Colors (Light Solid & Containers — all >= 5.0:1)
  static const Color success = Color(0xFF15803D);
  static const Color successContainerLight = Color(0xFFF0FDF4);
  static const Color onSuccessContainerLight = Color(0xFF166534);

  static const Color warning = Color(0xFFB45309);
  static const Color warningContainerLight = Color(0xFFFFFBEB);
  static const Color onWarningContainerLight = Color(0xFF92400E);

  static const Color error = Color(0xFFB91C1C);
  static const Color errorContainerLight = Color(0xFFFEF2F2);
  static const Color onErrorContainerLight = Color(0xFF991B1B);

  static const Color info = Color(0xFF0369A1);
  static const Color infoContainerLight = Color(0xFFF0F9FF);
  static const Color onInfoContainerLight = Color(0xFF075985);

  static const Color statusActive = success;
  static const Color statusCancelled = error;
  static const Color successGreen = success;
  static const Color errorRed = error;
  static const Color warningAmber = warning;

  // Subtle Brand Gradients (kept minimal for auth canvas & brand marks only)
  static const LinearGradient skyCanvasGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF)],
  );

  static const LinearGradient logoRoyalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRoyal, primaryBlue],
  );

  static const LinearGradient peachStatGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
  );

  static const LinearGradient blueStatGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );
}
