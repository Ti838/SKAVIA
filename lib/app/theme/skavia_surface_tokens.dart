import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Adaptive semantic design tokens attached to [ThemeData] via [ThemeExtension].
/// Guarantees WCAG 2.1 AA/AAA text contrast and SC 1.4.11 non-text UI contrast
/// across both Light and Dark themes.
@immutable
class SkaviaSurfaceTokens extends ThemeExtension<SkaviaSurfaceTokens> {
  final Color canvasBg;
  final Color sheetBg;
  final Color cardBg;
  final Color subtleCardBg;
  final Color inputBg;
  final Color border;
  final Color subtleBorder;
  final Color interactiveBorder;
  final Color softBlueBg;
  final Color softPeachBg;
  final Color softMintBg;
  final Color softVioletBg;
  final Color brandAccent;
  final Color onBrandAccent;
  final Color violetAccent;
  final Color onVioletAccent;
  final Color tealAccent;
  final Color onTealAccent;
  final Color success;
  final Color successBg;
  final Color onSuccessBg;
  final Color warning;
  final Color warningBg;
  final Color onWarningBg;
  final Color error;
  final Color errorBg;
  final Color onErrorBg;
  final Color info;
  final Color infoBg;
  final Color onInfoBg;
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
    required this.interactiveBorder,
    required this.softBlueBg,
    required this.softPeachBg,
    required this.softMintBg,
    required this.softVioletBg,
    required this.brandAccent,
    required this.onBrandAccent,
    required this.violetAccent,
    required this.onVioletAccent,
    required this.tealAccent,
    required this.onTealAccent,
    required this.success,
    required this.successBg,
    required this.onSuccessBg,
    required this.warning,
    required this.warningBg,
    required this.onWarningBg,
    required this.error,
    required this.errorBg,
    required this.onErrorBg,
    required this.info,
    required this.infoBg,
    required this.onInfoBg,
    required this.mutedText,
    required this.secondaryText,
    required this.shimmerBase,
    required this.shimmerHighlight,
  });

  static const SkaviaSurfaceTokens light = SkaviaSurfaceTokens(
    canvasBg: AppColors.primaryBlue,
    sheetBg: Color(0xFFFFFFFF),
    cardBg: Color(0xFFFFFFFF),
    subtleCardBg: Color(0xFFF8FAFC),
    inputBg: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    subtleBorder: Color(0xFFF1F5F9),
    interactiveBorder: Color(0xFF8592A6),
    softBlueBg: Color(0xFFEFF6FF),
    softPeachBg: Color(0xFFFFFBEB),
    softMintBg: Color(0xFFF0FDFA),
    softVioletBg: Color(0xFFF5F3FF),
    brandAccent: AppColors.primaryBlue,
    onBrandAccent: Colors.white,
    violetAccent: AppColors.secondaryViolet,
    onVioletAccent: Colors.white,
    tealAccent: AppColors.tertiaryTeal,
    onTealAccent: Colors.white,
    success: AppColors.success,
    successBg: AppColors.successContainerLight,
    onSuccessBg: AppColors.onSuccessContainerLight,
    warning: AppColors.warning,
    warningBg: AppColors.warningContainerLight,
    onWarningBg: AppColors.onWarningContainerLight,
    error: AppColors.error,
    errorBg: AppColors.errorContainerLight,
    onErrorBg: AppColors.onErrorContainerLight,
    info: AppColors.info,
    infoBg: AppColors.infoContainerLight,
    onInfoBg: AppColors.onInfoContainerLight,
    mutedText: Color(0xFF526075),
    secondaryText: Color(0xFF475569),
    shimmerBase: Color(0xFFE2E8F0),
    shimmerHighlight: Color(0xFFF8FAFC),
  );

  static const SkaviaSurfaceTokens dark = SkaviaSurfaceTokens(
    canvasBg: Color(0xFF070A11),
    sheetBg: Color(0xFF0E1424),
    cardBg: Color(0xFF101726),
    subtleCardBg: Color(0xFF151E32),
    inputBg: Color(0xFF151E32),
    border: Color(0xFF192338),
    subtleBorder: Color(0xFF151E32),
    interactiveBorder: Color(0xFF546C8D),
    softBlueBg: Color(0xFF0D2040),
    softPeachBg: Color(0xFF331A0B),
    softMintBg: Color(0xFF0B2E28),
    softVioletBg: Color(0xFF241542),
    brandAccent: Color(0xFF4C86F0),
    onBrandAccent: Color(0xFF070A11),
    violetAccent: Color(0xFF9D7BF2),
    onVioletAccent: Color(0xFF070A11),
    tealAccent: Color(0xFF25C9B3),
    onTealAccent: Color(0xFF070A11),
    success: Color(0xFF34D399),
    successBg: Color(0xFF0B291B),
    onSuccessBg: Color(0xFF86EFAC),
    warning: Color(0xFFF59E0B),
    warningBg: Color(0xFF2E1C05),
    onWarningBg: Color(0xFFFDE68A),
    error: Color(0xFFF87171),
    errorBg: Color(0xFF2D0B0E),
    onErrorBg: Color(0xFFFECDD3),
    info: Color(0xFF38BDF8),
    infoBg: Color(0xFF082138),
    onInfoBg: Color(0xFFBAE6FD),
    mutedText: Color(0xFF7189A8),
    secondaryText: Color(0xFF9BB0C9),
    shimmerBase: Color(0xFF151E32),
    shimmerHighlight: Color(0xFF222E4A),
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
    Color? interactiveBorder,
    Color? softBlueBg,
    Color? softPeachBg,
    Color? softMintBg,
    Color? softVioletBg,
    Color? brandAccent,
    Color? onBrandAccent,
    Color? violetAccent,
    Color? onVioletAccent,
    Color? tealAccent,
    Color? onTealAccent,
    Color? success,
    Color? successBg,
    Color? onSuccessBg,
    Color? warning,
    Color? warningBg,
    Color? onWarningBg,
    Color? error,
    Color? errorBg,
    Color? onErrorBg,
    Color? info,
    Color? infoBg,
    Color? onInfoBg,
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
      interactiveBorder: interactiveBorder ?? this.interactiveBorder,
      softBlueBg: softBlueBg ?? this.softBlueBg,
      softPeachBg: softPeachBg ?? this.softPeachBg,
      softMintBg: softMintBg ?? this.softMintBg,
      softVioletBg: softVioletBg ?? this.softVioletBg,
      brandAccent: brandAccent ?? this.brandAccent,
      onBrandAccent: onBrandAccent ?? this.onBrandAccent,
      violetAccent: violetAccent ?? this.violetAccent,
      onVioletAccent: onVioletAccent ?? this.onVioletAccent,
      tealAccent: tealAccent ?? this.tealAccent,
      onTealAccent: onTealAccent ?? this.onTealAccent,
      success: success ?? this.success,
      successBg: successBg ?? this.successBg,
      onSuccessBg: onSuccessBg ?? this.onSuccessBg,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      onWarningBg: onWarningBg ?? this.onWarningBg,
      error: error ?? this.error,
      errorBg: errorBg ?? this.errorBg,
      onErrorBg: onErrorBg ?? this.onErrorBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      onInfoBg: onInfoBg ?? this.onInfoBg,
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
      interactiveBorder: Color.lerp(
        interactiveBorder,
        other.interactiveBorder,
        t,
      )!,
      softBlueBg: Color.lerp(softBlueBg, other.softBlueBg, t)!,
      softPeachBg: Color.lerp(softPeachBg, other.softPeachBg, t)!,
      softMintBg: Color.lerp(softMintBg, other.softMintBg, t)!,
      softVioletBg: Color.lerp(softVioletBg, other.softVioletBg, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      onBrandAccent: Color.lerp(onBrandAccent, other.onBrandAccent, t)!,
      violetAccent: Color.lerp(violetAccent, other.violetAccent, t)!,
      onVioletAccent: Color.lerp(onVioletAccent, other.onVioletAccent, t)!,
      tealAccent: Color.lerp(tealAccent, other.tealAccent, t)!,
      onTealAccent: Color.lerp(onTealAccent, other.onTealAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      onSuccessBg: Color.lerp(onSuccessBg, other.onSuccessBg, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      onWarningBg: Color.lerp(onWarningBg, other.onWarningBg, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      onErrorBg: Color.lerp(onErrorBg, other.onErrorBg, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      onInfoBg: Color.lerp(onInfoBg, other.onInfoBg, t)!,
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
