import 'package:flutter/material.dart';

import '../../app/theme/app_typography.dart';

/// Global branded AppBar for SKAVIA with back navigation and customizable actions.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBg =
        backgroundColor ?? (isDark ? colorScheme.surface : Colors.white);
    final effectiveFg = foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.headingFont,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: effectiveFg,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: effectiveBg,
      foregroundColor: effectiveFg,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading:
          leading ??
          (Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }
}
