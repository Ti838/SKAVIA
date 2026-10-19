import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Deadline selection container for service request posting.
class PostRequirementDeadlineSelector extends StatelessWidget {
  final DateTime? selectedDeadline;
  final ValueChanged<DateTime> onDeadlineSelected;

  const PostRequirementDeadlineSelector({
    super.key,
    required this.selectedDeadline,
    required this.onDeadlineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deadline',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  selectedDeadline ??
                  DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) {
              onDeadlineSelected(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.sheetSurfaceSubtle,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textMedium,
                ),
                const SizedBox(width: 12),
                Text(
                  selectedDeadline != null
                      ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                      : 'Select deadline',
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDeadline != null
                        ? AppColors.textDark
                        : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

