import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Interactive task item card for Project Management board
class ProjectTaskItemCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final VoidCallback onToggleStatus;

  const ProjectTaskItemCard({
    super.key,
    required this.task,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    final title = task['title'] as String? ?? 'Task';
    final status = task['status'] as String? ?? 'Pending';
    final date = task['date'] as String? ?? 'Apr 24';

    final isCompleted = status == 'Completed';
    final isInProgress = status == 'In Progress';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    Color statusBg;

    if (isCompleted) {
      statusColor = const Color(0xFF10B981);
      statusBg = isDark
          ? const Color(0xFF064E3B).withValues(alpha: 0.4)
          : const Color(0xFFECFDF5);
    } else if (isInProgress) {
      statusColor = const Color(0xFF2563EB);
      statusBg = isDark
          ? const Color(0xFF1E3A8A).withValues(alpha: 0.4)
          : const Color(0xFFEFF6FF);
    } else {
      statusColor = const Color(0xFFF59E0B);
      statusBg = isDark
          ? const Color(0xFF78350F).withValues(alpha: 0.4)
          : const Color(0xFFFFFBEB);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Radio circle indicator
          GestureDetector(
            onTap: onToggleStatus,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF10B981)
                      : colorScheme.outlineVariant,
                  width: 2,
                ),
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.transparent,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
