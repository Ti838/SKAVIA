import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

/// Filter Chip with active state styling for TeamDiscoveryScreen.
class TeamDiscoveryFilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  const TeamDiscoveryFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? tokens.softBlueBg : tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? tokens.brandAccent : tokens.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label: $value' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isActive ? tokens.brandAccent : colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: isActive ? tokens.brandAccent : tokens.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
