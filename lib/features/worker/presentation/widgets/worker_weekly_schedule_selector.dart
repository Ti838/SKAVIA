import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/services/app_language_service.dart';

/// Weekly day selector pill bar for worker availability scheduling.
class WorkerWeeklyScheduleSelector extends StatelessWidget {
  final String selectedDay;
  final ValueChanged<String> onSelectDay;

  const WorkerWeeklyScheduleSelector({
    super.key,
    required this.selectedDay,
    required this.onSelectDay,
  });

  static const List<String> days = ['su', 'mo', 'tu', 'we', 'th', 'fr', 'sa'];

  Widget _buildDayPill(String day, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = selectedDay == day;
    final dayLabel = AppLanguageService.tr('days_$day');

    return GestureDetector(
      onTap: () => onSelectDay(day),
      child: Container(
        width: 40,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? colorScheme.primary : AppColors.primarySky)
              : (isDark
                    ? colorScheme.surfaceContainerHighest
                    : AppColors.sheetSurfaceSubtle),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? (isDark ? colorScheme.primary : AppColors.primarySky)
                : colorScheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? colorScheme.onSurfaceVariant
                      : AppColors.textMedium),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => _buildDayPill(day, context)).toList(),
    );
  }
}
