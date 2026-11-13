import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/extensions/context_extensions.dart';

/// 3-segment pill tab selector (Overview | Tasks | Members) for project dashboard.
class ProjectTopTabSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const ProjectTopTabSelector({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.skavia;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: tokens.subtleBorder),
        ),
        child: Row(
          children: [
            _buildTabItem(context, 0, 'Overview'),
            _buildTabItem(context, 1, 'Tasks'),
            _buildTabItem(context, 2, 'Members'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String title) {
    final tokens = context.skavia;
    final colorScheme = context.colorScheme;
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? tokens.cardBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFont,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                  color: isSelected
                      ? colorScheme.onSurface
                      : tokens.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

