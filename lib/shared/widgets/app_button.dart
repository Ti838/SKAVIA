import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';
import '../motion/sakuga_physics.dart';
import '../motion/sakuga_pressable.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  whitePill,
  destructive,
  ghost,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final AppButtonVariant variant;
  final double? width;
  final double height;
  final SakugaIntensity? motionIntensity;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.motionIntensity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;

    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colorScheme.primaryContainer;
        foregroundColor = colorScheme.onPrimaryContainer;
        break;
      case AppButtonVariant.whitePill:
        backgroundColor = tokens.cardBg;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: tokens.interactiveBorder, width: 1.2);
        break;
      case AppButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.onSurface;
        borderSide = BorderSide(color: tokens.interactiveBorder, width: 1.2);
        break;
      case AppButtonVariant.destructive:
        backgroundColor = colorScheme.error;
        foregroundColor = colorScheme.onError;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
    }

    final resolvedIntensity =
        motionIntensity ??
        (variant == AppButtonVariant.primary ||
                variant == AppButtonVariant.destructive
            ? SakugaIntensity.medium
            : SakugaIntensity.subtle);
    final isEnabled = !isLoading && onPressed != null;

    return SakugaPressable(
      enabled: isEnabled,
      intensity: resolvedIntensity,
      emitVfx: variant == AppButtonVariant.primary,
      vfxColor: colorScheme.primary,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: colorScheme.surfaceContainerHigh,
            disabledForegroundColor: tokens.mutedText,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                variant == AppButtonVariant.whitePill
                    ? AppDimensions.radiusPill
                    : AppDimensions.radiusMd,
              ),
              side: borderSide,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Flexible(
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isEnabled ? foregroundColor : tokens.mutedText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
