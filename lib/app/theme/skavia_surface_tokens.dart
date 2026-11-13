import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Adaptive semantic design tokens attached to [ThemeData] via [ThemeExtension].
/// Replaces hardcoded light-mode hex values so every surface, card, chip,
/// sheet, border, and brand accent renders with accessible contrast in Light
/// and Dark modes.
@immutable
class SkaviaSurfaceTokens extends ThemeExtension<SkaviaSurfaceTokens> {
  final Color canvasBg;
  final Color sheetBg;
  final Color cardBg;
  final Color subtleCardBg;
  final Color inputBg;
  final Color border;
  final Color subtleBorder;
  final Color softBlueBg;
  final Color softPeachBg;
  final Color softMintBg;
  final Color softVioletBg;
  final Color brandAccent;
  final Color onBrandAccent;
  final Color mutedText;
  final Color secondaryText;
  final Color shimmerBase;
  final Color shimmerHighlight;

  const SkaviaSurfaceTokens({
    required this.canvasBg,
    required this.sheetBg,
    required this.cardBg,
    required this.subtleCardBg,
    required this.inputBg,
    required this.border,
    required this.subtleBorder,
    required this.softBlueBg,
    required this.softPeachBg,
    required this.softMintBg,
    required this.softVioletBg,
    required this.brandAccent,
    required this.onBrandAccent,
    required this.mutedText,
    required this.secondaryText,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const SkaviaSurfaceTokens light = SkaviaSurfaceTokens(
    canvasBg: AppColors.canvasBlue,
    sheetBg: Color(0xFFFFFFFF),
    cardBg: Color(0xFFFFFFFF),
    subtleCardBg: Color(0xFFF8FAFC),
    inputBg: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    subtleBorder: Color(0xFFF1F5F9),
    softBlueBg: Color(0xFFEBF5FF),
    softPeachBg: Color(0xFFFFF3E0),
    softMintBg: Color(0xFFD4FAF4),
    softVioletBg: Color(0xFFEDE9FE),
    brandAccent: AppColors.primaryRoyal,
    onBrandAccent: Colors.white,
    mutedText: Color(0xFF64748B),
    secondaryText: Color(0xFF475569),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
  );

  static const SkaviaSurfaceTokens dark = SkaviaSurfaceTokens(
    canvasBg: Color(0xFF0A1428),
    sheetBg: Color(0xFF0F172A),
    cardBg: Color(0xFF1E293B),
    subtleCardBg: Color(0xFF162033),
    inputBg: Color(0xFF1E293B),
    border: Color(0xFF334155),
    subtleBorder: Color(0xFF1E293B),
    softBlueBg: Color(0xFF132A4A),
    softPeachBg: Color(0xFF3B2416),
    softMintBg: Color(0xFF0D3330),
    softVioletBg: Color(0xFF2B214A),
    brandAccent: Color(0xFF60A5FA),
    onBrandAccent: Color(0xFF0B1426),
    mutedText: Color(0xFF94A3B8),
    secondaryText: Color(0xFFCBD5E1),
    shimmerBase: Color(0xFF1E293B),
    shimmerHighlight: Color(0xFF334155),
  );

  @override
  SkaviaSurfaceTokens copyWith({
    Color? canvasBg,
    Color? sheetBg,
    Color? cardBg,
    Color? subtleCardBg,
    Color? inputBg,
    Color? border,
    Color? subtleBorder,
    Color? softBlueBg,
    Color? softPeachBg,
    Color? softMintBg,
    Color? softVioletBg,
    Color? brandAccent,
    Color? onBrandAccent,
    Color? mutedText,
    Color? secondaryText,
    Color? shimmerBase,
    Color? shimmerHighlight,
  }) {
    return SkaviaSurfaceTokens(
      canvasBg: canvasBg ?? this.canvasBg,
      sheetBg: sheetBg ?? this.sheetBg,
      cardBg: cardBg ?? this.cardBg,
      subtleCardBg: subtleCardBg ?? this.subtleCardBg,
      inputBg: inputBg ?? this.inputBg,
      border: border ?? this.border,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      softBlueBg: softBlueBg ?? this.softBlueBg,
      softPeachBg: softPeachBg ?? this.softPeachBg,
      softMintBg: softMintBg ?? this.softMintBg,
      softVioletBg: softVioletBg ?? this.softVioletBg,
      brandAccent: brandAccent ?? this.brandAccent,
      onBrandAccent: onBrandAccent ?? this.onBrandAccent,
      mutedText: mutedText ?? this.mutedText,
      secondaryText: secondaryText ?? this.secondaryText,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    );
  }

  @override
  SkaviaSurfaceTokens lerp(
    covariant ThemeExtension<SkaviaSurfaceTokens>? other,
    double t,
  ) {
    if (other is! SkaviaSurfaceTokens) return this;
    return SkaviaSurfaceTokens(
      canvasBg: Color.lerp(canvasBg, other.canvasBg, t)!,
      sheetBg: Color.lerp(sheetBg, other.sheetBg, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      subtleCardBg: Color.lerp(subtleCardBg, other.subtleCardBg, t)!,
      inputBg: Color.lerp(inputBg, other.inputBg, t)!,
      border: Color.lerp(border, other.border, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      softBlueBg: Color.lerp(softBlueBg, other.softBlueBg, t)!,
      softPeachBg: Color.lerp(softPeachBg, other.softPeachBg, t)!,
      softMintBg: Color.lerp(softMintBg, other.softMintBg, t)!,
      softVioletBg: Color.lerp(softVioletBg, other.softVioletBg, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      onBrandAccent: Color.lerp(onBrandAccent, other.onBrandAccent, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
    );
  }
}

