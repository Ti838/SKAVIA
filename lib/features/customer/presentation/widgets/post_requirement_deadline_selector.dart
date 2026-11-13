import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';

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
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deadline',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: tokens.subtleCardBg,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDeadline != null
                          ? '${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}'
                          : 'Select deadline',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: selectedDeadline != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

