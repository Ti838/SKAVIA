import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';

/// Reusable pill switch toggle between Email and Phone OTP authentication modes.
class LoginMethodToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMethodSelected;

  const LoginMethodToggle({
    super.key,
    required this.selectedIndex,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest
            : const Color(0xFFF1F5F9),
        borderRadius: AppDimensions.roundedPill,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onMethodSelected(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selectedIndex == 0
                      ? (isDark ? colorScheme.surface : Colors.white)
                      : Colors.transparent,
                  borderRadius: AppDimensions.roundedPill,
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selectedIndex == 0
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onMethodSelected(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selectedIndex == 1
                      ? (isDark ? colorScheme.surface : Colors.white)
                      : Colors.transparent,
                  borderRadius: AppDimensions.roundedPill,
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    'Phone OTP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selectedIndex == 1
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
