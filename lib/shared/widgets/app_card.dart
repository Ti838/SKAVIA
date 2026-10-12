import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final BorderSide? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimensions.space20),
    this.backgroundColor = Colors.white,
    this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radius24),
        side:
            border ?? const BorderSide(color: AppColors.borderLight, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primarySky.withValues(alpha: 0.1),
        highlightColor: AppColors.primarySky.withValues(alpha: 0.05),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
