import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
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
    final tokens = context.skavia;
    final isSelected = selectedDay == day;
    final dayLabel = AppLanguageService.tr('days_$day');

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: () => onSelectDay(day),
          child: Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? tokens.brandAccent : tokens.subtleCardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? tokens.brandAccent : tokens.border,
              ),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                dayLabel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? tokens.onBrandAccent
                      : tokens.secondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: days.map((day) => _buildDayPill(day, context)).toList(),
    );
  }
}
