import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';
import '../../core/extensions/context_extensions.dart';

enum SkaviaBadgeTone {
  primary,
  violet,
  verified,
  success,
  warning,
  error,
  info,
  neutral,
}

/// Accessible semantic pill badge using verified Light & Dark container pairs.
/// Always pairs readable text with an optional icon so meaning never relies
/// on hue alone (color-vision deficiency safe).
class SkaviaBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final SkaviaBadgeTone tone;
  final bool compact;

  const SkaviaBadge({
    super.key,
    required this.label,
    this.icon,
    this.tone = SkaviaBadgeTone.primary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tokens = context.skavia;

    final Color bg;
    final Color fg;

    switch (tone) {
      case SkaviaBadgeTone.primary:
        bg = colorScheme.primaryContainer;
        fg = colorScheme.onPrimaryContainer;
        break;
      case SkaviaBadgeTone.violet:
        bg = colorScheme.secondaryContainer;
        fg = colorScheme.onSecondaryContainer;
        break;
      case SkaviaBadgeTone.verified:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        break;
      case SkaviaBadgeTone.success:
        bg = tokens.successBg;
        fg = tokens.onSuccessBg;
        break;
      case SkaviaBadgeTone.warning:
        bg = tokens.warningBg;
        fg = tokens.onWarningBg;
        break;
      case SkaviaBadgeTone.error:
        bg = tokens.errorBg;
        fg = tokens.onErrorBg;
        break;
      case SkaviaBadgeTone.info:
        bg = tokens.infoBg;
        fg = tokens.onInfoBg;
        break;
      case SkaviaBadgeTone.neutral:
        bg = colorScheme.surfaceContainer;
        fg = colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 13 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
